pragma ever-solidity >= 0.62.0;

import "./libraries/MsgFlag.sol";

import "tip3/contracts/interfaces/ITokenRoot.tsol";
import "tip3/contracts/interfaces/ITransferableOwnership.tsol";
import "tip3/contracts/interfaces/ITransferTokenRootOwnershipCallback.tsol";
import "tip3/contracts/structures/ICallbackParamsStructure.tsol";

import "./interfaces/ITokenFactory.sol";
import "./interfaces/ITokenRootDeployedCallback.sol";
import "./interfaces/IRoot.sol";

import "./libraries/Errors.sol";
import "./libraries/Constants.sol";

contract DexVaultLpTokenPendingV2 is
    ITokenRootDeployedCallback,
    ITransferTokenRootOwnershipCallback
{
    string LP_TOKEN_SYMBOL_PREFIX = "FlatQube-LP-";
    string LP_TOKEN_SYMBOL_SEPARATOR = "-";
    uint8 LP_TOKEN_DECIMALS = 9;

    uint32 static _nonce;

    address static root;
    address static pool;
    address[] static roots;
    mapping(address => uint8) token_index;

    address token_factory;

    address lp_token_root;

    address send_gas_to;

    uint8 pending_messages;

    string[] root_symbols;
    bool[] root_symbols_received;
    uint8 root_symbols_amt;

    uint8 N_COINS;

    modifier onlyRoot {
        require(msg.sender == root, Errors.NOT_ROOT);
        _;
    }

    modifier onlyTokenFactory {
        require(msg.sender == token_factory, Errors.NOT_TOKEN_FACTORY);
        _;
    }

    modifier onlyExpectedToken {
        require(isSenderExpectedToken(), Errors.NOT_EXPECTED_TOKEN);
        _;
    }

    constructor(address token_factory_, address send_gas_to_) public onlyRoot {
        token_factory = token_factory_;
        send_gas_to = send_gas_to_;

        N_COINS = uint8(roots.length);

        root_symbols = new string[](N_COINS);
        root_symbols_received = new bool[](N_COINS);

        for (uint8 i = 0; i < N_COINS; i++) {
            token_index[roots[i]] = i;
        }

        for (uint8 i = 0; i < N_COINS; i++) {
            ITokenRoot(roots[i]).symbol{
                value: Constants.GET_TOKEN_DETAILS_VALUE,
                flag: MsgFlag.SENDER_PAYS_FEES,
                callback: onSymbol
            }();
        }
        pending_messages+=N_COINS;
    }

    function terminate() public view {
        require(msg.sender == send_gas_to, Errors.NOT_MY_OWNER);
        tvm.accept();
        _onLiquidityTokenNotDeployed();
    }

    function onSymbol(string symbol) public onlyExpectedToken {
        pending_messages--;

        uint8 i = token_index[msg.sender];

        root_symbols[i] = symbol;
        if (!root_symbols_received[i]) {
            root_symbols_amt += 1;
            root_symbols_received[i] = true;

            if (root_symbols_amt == N_COINS) {
                createLpTokenAndWallets();
            }
        }
        terminateIfEmptyQueue();
    }

    function onTokenRootDeployed(
        uint32 /*answer_id*/,
        address token_root
    ) override public onlyTokenFactory {
        lp_token_root = token_root;

        TvmCell empty;
        mapping(address => ICallbackParamsStructure.CallbackParams) callbacks;
        callbacks[address(this)] = ICallbackParamsStructure.CallbackParams(0, empty);
        ITransferableOwnership(token_root).transferOwnership{
            value: Constants.TRANSFER_ROOT_OWNERSHIP_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES
        }(pool, address(this), callbacks);
    }

    function onTransferTokenRootOwnership(
        address oldOwner,
        address newOwner,
        address,
        TvmCell
    ) external override {
        require(msg.sender.value != 0 && msg.sender == lp_token_root, Errors.NOT_LP_TOKEN_ROOT);

        pending_messages--;

        if (oldOwner == address(this) && newOwner == pool) {
            IRoot(root)
                .onLiquidityTokenDeployed{
                    value: 0,
                    flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.DESTROY_IF_ZERO,
                    bounce: false
                }(
                    _nonce,
                    pool,
                    roots,
                    lp_token_root,
                    send_gas_to
                );
        } else {
            _onLiquidityTokenNotDeployed();
        }
    }

    function _onLiquidityTokenNotDeployed() private inline view {
        IRoot(root)
            .onLiquidityTokenNotDeployed{
                value: 0,
                flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.DESTROY_IF_ZERO,
                bounce: false
            }(
                _nonce,
                pool,
                roots,
                lp_token_root,
                send_gas_to
            );
    }

    function createLpTokenAndWallets() private {
        string lp_token_symbol = lpTokenSymbol(root_symbols);
        deployLpToken(lp_token_symbol, LP_TOKEN_DECIMALS);
    }

    function deployLpToken(bytes symbol, uint8 decimals) private {
        pending_messages++;
        ITokenFactory(token_factory).createToken{
            value: Constants.CREATE_TOKEN_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES
        }(
            0,
            symbol,
            symbol,
            decimals,
            address(0),
            0,
            0,
            false,
            false,
            false,
            address(0)
        );
    }

    function lpTokenSymbol(string[] symbols) private view returns (string) {
        string name = LP_TOKEN_SYMBOL_PREFIX;
        name.append(symbols[0]);
        for (uint8 i = 1; i < N_COINS; i++) {
            name.append(LP_TOKEN_SYMBOL_SEPARATOR);
            name.append(symbols[i]);
        }

        return name;
    }

    function isSenderExpectedToken() private view returns (bool) {
        for (uint8 i = 0; i < N_COINS; i++) {
            if (msg.sender == roots[i]) return true;
        }
        return false;
    }

    function terminateIfEmptyQueue() private inline view {
        if (pending_messages == 0) {
            _onLiquidityTokenNotDeployed();
        }
    }

    onBounce(TvmSlice /*body*/) external {
        if (isSenderExpectedToken() || msg.sender == token_factory || msg.sender == lp_token_root) {
            pending_messages--;
            terminateIfEmptyQueue();
        }
    }

    receive() external pure {}
}
