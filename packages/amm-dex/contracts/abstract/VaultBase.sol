pragma ever-solidity >= 0.62.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "tip3/contracts/interfaces/ITokenRoot.sol";
import "tip3/contracts/interfaces/IBurnableTokenWallet.sol";
import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.sol";

import "../external/RandomNonce.sol";
import "../external/CheckPubKey.sol";
import "../external/InternalOwner.sol";
import "../external/ErrorCodes.sol";


/**
    @title For for Wrapped VENOM.
    Stores VENOMS. Exchanges VENOMs for WVENOMs 1:1 and backwards.
    Receives VENOMS and mints wVENOMs.
    Receives wVENOMs, burns it and releases VENOMS
*/
abstract contract VaultBase is
    IAcceptTokensTransferCallback,
    RandomNonce,
    CheckPubKey,
    InternalOwner
{
    struct Configuration {
        address root_tunnel;
        address root;
        uint128 receive_safe_fee;
        uint128 settings_deploy_wallet_grams;
        uint128 initial_balance;
    }

    Configuration public configuration;

    // Fields bellow derives automatically
    address public token_wallet;
    uint128 public total_wrapped;

    constructor(
        address owner_,
        address root,
        address root_tunnel,
        uint128 receive_safe_fee,
        uint128 settings_deploy_wallet_grams,
        uint128 initial_balance
    ) public checkPubKey {
        tvm.accept();

        setOwnership(owner_);

        configuration.root = root;
        configuration.root_tunnel = root_tunnel;
        configuration.receive_safe_fee = receive_safe_fee;
        configuration.settings_deploy_wallet_grams = settings_deploy_wallet_grams;
        configuration.initial_balance = initial_balance;

        setUpTokenWallet();
    }

    /**
        @notice Creates vault token wallet according to the configuration root token
    */
    function setUpTokenWallet() internal view {
        // Deploy vault's token wallet
        ITokenRoot(configuration.root).deployWallet{
            value: 1 ever,
            callback: VaultBase.receiveTokenWalletAddress
        }(
            address(this),
            configuration.settings_deploy_wallet_grams
        );
    }

    /**
        @notice Save Vault's token wallet address
        @dev Only root can call with correct params
        @param wallet Vault's token wallet
    */
    function receiveTokenWalletAddress(
        address wallet
    ) external {
        require(msg.sender == configuration.root, ErrorCodes.WRONG_ROOT);

        token_wallet = wallet;
    }

    /**
        @notice Drain odd VENOMs
        @dev Can be called only by owner
        @param receiver Address to send odd VENOMs to
    */
    function drain(
        address receiver
    ) onlyOwner view public {
        tvm.rawReserve(total_wrapped + configuration.initial_balance, 2);

        receiver.transfer({ value: 0, flag: 129 });
    }

    /**
        @notice Updates configuration
        @dev Can be called only by owner
        @param _configuration New configuration
    */
    function setConfiguration(
        Configuration _configuration
    ) external onlyOwner {
        address previous_root = configuration.root;

        configuration = _configuration;

        if (configuration.root != previous_root) {
            setUpTokenWallet();
        }
    }

    /**
        @notice Withdraw VENOMs from the vault
        @dev Can be called only by owner
        @dev VENOMs are send to the owner wallet
        @param amount How much VENOMs to withdraw
    */
    function withdraw(
        uint128 amount
    ) external onlyOwner {
        updateTotalWrapped(-amount);

        tvm.rawReserve(total_wrapped + configuration.initial_balance, 2);

        owner.transfer({ value: 0, flag: 128 });
    }

    /**
        @notice Send VENOMs to the vault without issuing VENOMs
        @dev Increases initial balance value
        so the granted VENOMs won't be withdrawn on the wrapping / unwrapping
        @dev Be careful! Since you don't have WVENOM tokens, you can't redeem granted VENOMs
    */
    function grant(
        uint128 amount
    ) external {
        require(amount <= msg.value + 1 ever, ErrorCodes.MSG_VALUE_TOO_LOW);

        updateTotalWrapped(amount);

        tvm.rawReserve(total_wrapped + configuration.initial_balance, 2);

        msg.sender.transfer({ value: 0, flag: 128 });
    }


    /**
        @notice Receive VENOMs to wrap them into wTON.
        Allows to simply mint wVENOMs by sending them directly to vault.
        @dev msg.value should be > receive_safe_fee
        @dev Amount of minted tokens = msg.value - receive_safe_fee
        @dev Rest of the VENOMs will be sent back
    */
    receive() external {
        require(msg.value > configuration.receive_safe_fee, ErrorCodes.MSG_VALUE_TOO_LOW);

        uint128 tokens = msg.value - configuration.receive_safe_fee;

        updateTotalWrapped(tokens);

        tvm.rawReserve(total_wrapped + configuration.initial_balance, 2);

        TvmCell empty;

        ITokenRoot(configuration.root_tunnel).mint{ value: 0, flag: 128 }(
            tokens,
            msg.sender,
            configuration.settings_deploy_wallet_grams,
            msg.sender,
            true,
            empty
        );
    }

    /**
        @notice Updates total wrapped amount
        @param change Change amount
    */
    function updateTotalWrapped(uint128 change) internal {
        total_wrapped += change;
    }

    /**
        @notice Internal function for minting wVENOMs
        @dev Works since Vault is authorized for minting tokens
        @param tokens How much tokens to mint
        @param owner_address Token wallet owner address
        @param gas_back_address Address to send change
    */

    function wrap(
        uint128 tokens,
        address owner_address,
        address gas_back_address,
        TvmCell payload
    ) external {
        require(
            msg.value >= tokens + configuration.receive_safe_fee,
            ErrorCodes.MSG_VALUE_TOO_LOW
        );

        updateTotalWrapped(tokens);

        tvm.rawReserve(total_wrapped + configuration.initial_balance, 2);

        ITokenRoot(configuration.root_tunnel).mint{ value: 0, flag: 128 }(
            tokens,
            owner_address,
            configuration.settings_deploy_wallet_grams,
            gas_back_address,
            true,
            payload
        );
    }

    /**
        @notice Receive wVENOMs to burn them and release VENOMs
        @dev Callback function from vault token wallet
        @dev VENOMs will be sent to tokens sender
    */
    function onAcceptTokensTransfer(
        address tokenRoot,
        uint128 amount,
        address sender,
        address senderWallet,
        address remainingGasTo,
        TvmCell payload
    ) override external {
        require(tokenRoot == configuration.root, ErrorCodes.WRONG_ROOT);
        require(msg.sender == token_wallet, ErrorCodes.WRONG_TOKEN_WALLET);

        updateTotalWrapped(-amount);

        tvm.rawReserve(total_wrapped + configuration.initial_balance, 2);

        // Burn wVENOMs
        IBurnableTokenWallet(token_wallet).burn{value: 0, flag: 128}(
            amount,
            remainingGasTo,
            sender,
            payload
        );
    }
}