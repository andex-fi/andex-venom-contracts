pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;


import "tip3/contracts/interfaces/ITokenRoot.sol";
import "tip3/contracts/interfaces/ITokenWallet.sol";
import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.sol";

import "./interfaces/IUpgradableByRequest.sol";
import "./interfaces/IRoot.sol";
import "./interfaces/IAccount.sol";
import "./interfaces/IBasePool.sol";
import "./interfaces/ITokenVault.sol";
import "./interfaces/IResetGas.sol";
import "./interfaces/IAccountOwner.sol";

import "./libraries/PlatformTypes.sol";
import "./libraries/Errors.sol";
import "./libraries/Constants.sol";
import "./libraries/MsgFlag.sol";

import "./abstract/ContractBase.sol";

import "./Platform.sol";

contract SwapAccount is
    ContractBase,
    IAccount,
    IAcceptTokensTransferCallback,
    IUpgradableByRequest,
    IResetGas
{
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // BASE DATA

    address private _root;
    address private _vault;
    uint32 private _currentVersion;
    address private _owner;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // CUSTOM

    // root -> wallet
    mapping(address => address) private _wallets;
    // root -> balance
    mapping(address => uint128) private _balances;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // OPERATIONS TEMPORARY DATA

    // call_id -> Operation[]
    mapping(uint64 => Operation) private _tmpOperations;
    // token_root -> send_gas_to
    mapping(address => address) private _tmpDeployingWallets;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // MODIFIERS

    modifier onlyOwner() {
        require(_owner.value != 0 && msg.sender == _owner, Errors.NOT_OWNER);
        _;
    }

    modifier onlyRoot() {
        require(_root.value != 0 && msg.sender == _root, Errors.NOT_ROOT);
        _;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // BASE FUNCTIONS

    // Cant be deployed directly
    constructor() public {
        revert();
    }

    // Prevent manual transfers
    receive() external pure {
        revert();
    }

    // Prevent undefined functions call, need for bounce future Pair/Root functions calls, when not upgraded
    fallback() external pure {
        revert();
    }

    // ...and allow user to get surplus gas
    function resetGas(address receiver) override external view onlyOwner {
        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        receiver.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED,
            bounce: false
        });
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // GETTERS

    function getRoot() override external view responsible returns (address) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _root;
    }

    function getOwner() override external view responsible returns (address) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _owner;
    }

    function getVersion() override external view responsible returns (uint32) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _currentVersion;
    }

    function getVault() override external view responsible returns (address) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _vault;
    }

    function getWalletData(address token_root) override external view responsible returns (
        address wallet,
        uint128 balance
    ) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } (
            _wallets.exists(token_root) ? _wallets.at(token_root) : address.makeAddrStd(0, 0),
            _balances.exists(token_root) ? _balances.at(token_root) : 0
        );
    }

    function getWallets() external view returns (mapping(address => address)) {
        return _wallets;
    }

    function getBalances() external view returns (mapping(address => uint128)) {
        return _balances;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // CALLBACKS

    function onAcceptTokensTransfer(
        address _tokenRoot,
        uint128 _tokensAmount,
        address /* _senderAddress */,
        address _senderWallet,
        address _originalGasTo,
        TvmCell _payload
    ) override external {
        require(msg.value >= Constants.DEPOSIT_TO_ACCOUNT_MIN_VALUE, Errors.VALUE_TOO_LOW);
        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        TvmSlice payloadSlice = _payload.toSlice();
        bool notifyCancel = payloadSlice.refs() >= 1;
        TvmCell cancelPayload;

        if (notifyCancel) {
            cancelPayload = payloadSlice.loadRef();
        }

        if (
            _wallets.exists(_tokenRoot) &&
            msg.sender == _wallets[_tokenRoot]
        ) {
            if(_balances.exists(_tokenRoot)) {
                _balances[_tokenRoot] += _tokensAmount;
            } else {
                _balances[_tokenRoot] = _tokensAmount;
            }

            emit TokensReceived(
                _tokenRoot,
                _tokensAmount,
                _balances[_tokenRoot],
                _senderWallet
            );

            TvmCell empty;

            address tokenVault = _expectedTokenVaultAddress(_tokenRoot);

            ITokenWallet(msg.sender)
                .transfer{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                (
                    _tokensAmount,
                    tokenVault,
                    0,
                    _originalGasTo,
                    false,
                    empty
                );
        } else {
            ITokenWallet(msg.sender)
                .transferToWallet{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                (
                    _tokensAmount,
                    _senderWallet,
                    _originalGasTo,
                    notifyCancel,
                    cancelPayload
                );
        }
    }

    function checkPoolCallback(
        address[] _roots,
        address _lpRoot
    ) override external onlyPool(_roots) {
        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        for (address tokenRoot : _roots) {
            if (!_wallets.exists(tokenRoot)) {
                _deployWallet(tokenRoot, _owner);
            }
        }

        if (!_wallets.exists(_lpRoot)) {
            _deployWallet(_lpRoot, _owner);
        }

        _owner.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS
        });
    }

    function successCallback(uint64 _callId) override external {
        require(_tmpOperations.exists(_callId), Errors.INVALID_CALLBACK);

        Operation operation = _tmpOperations[_callId];

        require(operation.expected_callback_sender == msg.sender, Errors.INVALID_CALLBACK_SENDER);

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        delete _tmpOperations[_callId];

        if (operation.send_gas_to == _owner) {
            IAccountOwner(_owner)
                .dexAccountOnSuccess{
                    value: 0,
                    flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
                    bounce: false
                }(_callId);
        } else {
            IAccountOwner(_owner)
                .dexAccountOnSuccess{
                    value: Constants.OPERATION_CALLBACK_BASE,
                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS
                }(_callId);

            operation.send_gas_to.transfer({
                value: 0,
                flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
                bounce: false
            });
        }
    }

    function onTokenWallet(address _wallet) external {
        require(
            _tmpDeployingWallets.exists(msg.sender) &&
            !_wallets.exists(msg.sender),
            Errors.TODO
        );

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 2);

        address remainingGasTo = _tmpDeployingWallets[msg.sender];

        _wallets[msg.sender] = _wallet;

        if(!_balances.exists(msg.sender)) {
            _balances[msg.sender] = 0;
        }

        delete _tmpDeployingWallets[msg.sender];

        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS
        });
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ACCOUNT OPERATIONS

    function withdraw(
        uint64  call_id,
        uint128 amount,
        address token_root,
        address recipient_address,
        uint128 deploy_wallet_grams,
        address send_gas_to
    ) override external onlyOwner {
        require(!_tmpOperations.exists(call_id), Errors.OPERATION_ALREADY_IN_PROGRESS);
        require(amount > 0, Errors.AMOUNT_TOO_LOW);
        require(recipient_address.value != 0, Errors.WRONG_RECIPIENT);
        require(msg.value >= Constants.WITHDRAW_MIN_VALUE_BASE + deploy_wallet_grams, Errors.VALUE_TOO_LOW);
        require(_wallets.exists(token_root) && _balances.exists(token_root), Errors.UNKNOWN_TOKEN_ROOT);
        require(_balances[token_root] >= amount, Errors.NOT_ENOUGH_FUNDS);

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        _balances[token_root] -= amount;

        emit WithdrawTokens(token_root, amount, _balances[token_root]);

        address send_gas_to_ = send_gas_to.value == 0 ? _owner : send_gas_to;

        address tokenVault = _expectedTokenVaultAddress(token_root);

        _tmpOperations[call_id] = Operation(
            [TokenOperation(amount, token_root)],
            send_gas_to_,
            tokenVault
        );

        ITokenVault(tokenVault)
        .withdraw{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: true }
        (
            call_id,
            amount,
            recipient_address,
            deploy_wallet_grams,
            _owner,
            _currentVersion,
            send_gas_to
        );
    }

    function transfer(
        uint64 call_id,
        uint128 amount,
        address token_root,
        address recipient,
        bool willing_to_deploy,
        address send_gas_to
    ) override external onlyOwner {
        require(!_tmpOperations.exists(call_id), Errors.OPERATION_ALREADY_IN_PROGRESS);
        require(amount > 0, Errors.AMOUNT_TOO_LOW);
        require(msg.value >= Constants.TRANSFER_MIN_VALUE, Errors.VALUE_TOO_LOW);
        require(_wallets.exists(token_root) && _balances.exists(token_root), Errors.UNKNOWN_TOKEN_ROOT);
        require(_balances[token_root] >= amount, Errors.NOT_ENOUGH_FUNDS);

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        _balances[token_root] -= amount;

        emit TransferTokens(
            token_root,
            amount,
            _balances[token_root]
        );

        address remainingGasTo = send_gas_to.value == 0 ? _owner : send_gas_to;

        address recipientAccount = address(
            tvm.hash(
                _buildInitData(
                    PlatformTypes.Account,
                    _buildAccountParams(recipient)
                )
            )
        );

        _tmpOperations[call_id] = Operation(
            [TokenOperation(amount, token_root)],
            remainingGasTo,
            recipientAccount
        );

        IAccount(recipientAccount)
            .internalAccountTransfer{ value: 0, bounce: true, flag: MsgFlag.ALL_NOT_RESERVED }
            (
                call_id,
                amount,
                token_root,
                _owner,
                willing_to_deploy,
                remainingGasTo
            );
    }

    function internalAccountTransfer(
        uint64 call_id,
        uint128 amount,
        address token_root,
        address sender_owner,
        bool willing_to_deploy,
        address send_gas_to
    ) override external onlyAccount(sender_owner) {
        require(
            willing_to_deploy ||
            _wallets.exists(token_root) ||
            _tmpDeployingWallets.exists(token_root),
            Errors.UNKNOWN_TOKEN_ROOT
        );

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        if(_balances.exists(token_root)) {
            _balances[token_root] += amount;
        } else {
            _balances[token_root] = amount;
        }

        emit TokensReceivedFromAccount(
            token_root,
            amount,
            _balances[token_root],
            sender_owner
        );

        if (
            willing_to_deploy &&
            !_wallets.exists(token_root) &&
            !_tmpDeployingWallets.exists(token_root)
        ) {
            _deployWallet(token_root, send_gas_to);
        }

        IAccount(msg.sender)
            .successCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
            (call_id);
    }

    function internalPoolTransfer(
        uint128 _amount,
        address _tokenRoot,
        address[] _roots,
        address _remainingGasTo
    ) override external onlyPool(_roots) {
        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        if(_balances.exists(_tokenRoot)) {
            _balances[_tokenRoot] += _amount;
        } else {
            _balances[_tokenRoot] = _amount;
        }

        emit TokensReceivedFromPool(
            _tokenRoot,
            _amount,
            _balances[_tokenRoot],
            _roots
        );

        _remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS
        });
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // SWAP

    function exchange(
        uint64 call_id,
        uint128 spent_amount,
        address spent_token_root,
        address receive_token_root,
        uint128 expected_amount,
        address send_gas_to
    ) override external onlyOwner {
        _exchangeInternal(
            call_id,
            TokenOperation(spent_amount, spent_token_root),
            TokenOperation(expected_amount, receive_token_root),
            [spent_token_root, receive_token_root],
            send_gas_to
        );
    }

    function exchangeV2(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation _expected,
        address[] _roots,
        address _remainingGasTo
    ) override external onlyOwner {
        _exchangeInternal(
            _callId,
            _operation,
            _expected,
            _roots,
            _remainingGasTo
        );
    }

    function _exchangeInternal(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation _expected,
        address[] _roots,
        address _remainingGasTo
    ) private {
        require(!_tmpOperations.exists(_callId), Errors.OPERATION_ALREADY_IN_PROGRESS);
        require(_operation.amount > 0, Errors.AMOUNT_TOO_LOW);
        require(msg.value >= Constants.EXCHANGE_MIN_VALUE, Errors.VALUE_TOO_LOW);
        require(_wallets.exists(_operation.root) && _balances.exists(_operation.root), Errors.UNKNOWN_TOKEN_ROOT);
        require(_wallets.exists(_expected.root), Errors.UNKNOWN_TOKEN_ROOT);
        require(_balances[_operation.root] >= _operation.amount, Errors.NOT_ENOUGH_FUNDS);

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        address pair = address(
            tvm.hash(
                _buildInitData(
                    PlatformTypes.Pool,
                    _buildPairParams(_roots)
                )
            )
        );

        _balances[_operation.root] -= _operation.amount;

        emit ExchangeTokens(
            _operation.root,
            _expected.root,
            _operation.amount,
            _expected.amount,
            _balances[_operation.root]
        );

        address remainingGasTo = _remainingGasTo.value == 0 ? _owner : _remainingGasTo;

        _tmpOperations[_callId] = Operation(
            [_operation],
            remainingGasTo,
            pair
        );

        IBasePool(pair)
            .exchange{ value: 0, bounce: true, flag: MsgFlag.ALL_NOT_RESERVED }
            (
                _callId,
                _operation,
                _expected,
                _owner,
                _currentVersion,
                remainingGasTo
            );
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DEPOSIT LIQUIDITY

    function depositLiquidity(
        uint64 call_id,
        address left_root,
        uint128 left_amount,
        address right_root,
        uint128 right_amount,
        address expected_lp_root,
        bool auto_change,
        address send_gas_to
    ) override external onlyOwner {
        _depositLiquidityInternal(
            call_id,
            [TokenOperation(left_amount, left_root), TokenOperation(right_amount, right_root)],
            TokenOperation(0, expected_lp_root),
            auto_change,
            send_gas_to,
            address(0)
        );
    }

    function depositLiquidityV2(
        uint64 _callId,
        TokenOperation[] _operations,
        TokenOperation _expected,
        bool _autoChange,
        address _remainingGasTo,
        address _referrer
    ) override external onlyOwner {
        _depositLiquidityInternal(
            _callId,
            _operations,
            _expected,
            _autoChange,
            _remainingGasTo,
            _referrer
        );
    }

    function _depositLiquidityInternal(
        uint64 _callId,
        TokenOperation[] _operations,
        TokenOperation _expected,
        bool _autoChange,
        address _remainingGasTo,
        address _referrer
    ) private {
        require(!_tmpOperations.exists(_callId), Errors.OPERATION_ALREADY_IN_PROGRESS);
        require(_operations.length > 1, Errors.WRONG_PAIR);
        require(msg.value >= Constants.DEPOSIT_LIQUIDITY_MIN_VALUE, Errors.VALUE_TOO_LOW);
        require(_wallets.exists(_expected.root) && _balances.exists(_expected.root), Errors.UNKNOWN_TOKEN_ROOT);
        for (TokenOperation operation : _operations) {
            require(_wallets.exists(operation.root) && _balances.exists(operation.root), Errors.UNKNOWN_TOKEN_ROOT);
            require(_balances[operation.root] >= operation.amount, Errors.NOT_ENOUGH_FUNDS);
        }

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        address[] roots;

        for (TokenOperation operation : _operations) {
            roots.push(operation.root);
            _balances[operation.root] -= operation.amount;
        }

        address pair = address(
            tvm.hash(
                _buildInitData(
                    PlatformTypes.Pool,
                    _buildPairParams(roots)
                )
            )
        );

        emit DepositLiquidity(_operations, _autoChange);

        address remainingGasTo = _remainingGasTo.value == 0 ? _owner : _remainingGasTo;

        _tmpOperations[_callId] = Operation(
            _operations,
            remainingGasTo,
            pair
        );

        IBasePool(pair)
            .depositLiquidity{ value: 0, bounce: true, flag: MsgFlag.ALL_NOT_RESERVED }
            (
                _callId,
                _operations,
                _expected,
                _autoChange,
                _owner,
                _currentVersion,
                remainingGasTo,
                _referrer
            );
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // WITHDRAW LIQUIDITY

    function withdrawLiquidity(
        uint64 call_id,
        uint128 lp_amount,
        address lp_root,
        address left_root,
        address right_root,
        address send_gas_to
    ) override external onlyOwner {
        _withdrawLiquidityInternal(
            call_id,
            [left_root, right_root],
            TokenOperation(lp_amount, lp_root),
            [TokenOperation(0, left_root), TokenOperation(0, right_root)],
            send_gas_to
        );
    }

    function withdrawLiquidityV2(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation[] _expected,
        address _remainingGasTo
    ) override external onlyOwner {
        require(_expected.length > 1, Errors.WRONG_PAIR);

        address[] roots;
        for (TokenOperation operation : _expected) {
            roots.push(operation.root);
        }

        _withdrawLiquidityInternal(
            _callId,
            roots,
            _operation,
            _expected,
            _remainingGasTo
        );
    }

    function withdrawLiquidityOneCoin(
        uint64 _callId,
        address[] _roots,
        TokenOperation _operation,
        TokenOperation _expected,
        address _remainingGasTo
    ) override external onlyOwner {
        require(_roots.length > 2, Errors.WRONG_PAIR);

        _withdrawLiquidityInternal(
            _callId,
            _roots,
            _operation,
            [_expected],
            _remainingGasTo
        );
    }

    function _withdrawLiquidityInternal(
        uint64 _callId,
        address[] _roots,
        TokenOperation _operation,
        TokenOperation[] _expected,
        address _remainingGasTo
    ) private {
        require(!_tmpOperations.exists(_callId), Errors.OPERATION_ALREADY_IN_PROGRESS);
        require(_operation.amount > 0, Errors.AMOUNT_TOO_LOW);
        require(msg.value >= Constants.WITHDRAW_LIQUIDITY_MIN_VALUE, Errors.VALUE_TOO_LOW);
        require(_wallets.exists(_operation.root) && _balances.exists(_operation.root), Errors.UNKNOWN_TOKEN_ROOT);
        require(_balances[_operation.root] >= _operation.amount, Errors.NOT_ENOUGH_FUNDS);

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        address pair = address(
            tvm.hash(
                _buildInitData(
                    PlatformTypes.Pool,
                    _buildPairParams(_roots)
                )
            )
        );

        _balances[_operation.root] -= _operation.amount;

        emit WithdrawLiquidity(
            _operation.amount,
            _balances[_operation.root],
            _operation.root,
            _roots
        );

        address remainingGasTo = _remainingGasTo.value == 0 ? _owner : _remainingGasTo;

        _tmpOperations[_callId] = Operation(
            [_operation],
            remainingGasTo,
            pair
        );

        IBasePool(pair)
            .withdrawLiquidity{ value: 0, bounce: true, flag: MsgFlag.ALL_NOT_RESERVED }
            (
                _callId,
                _operation,
                _expected,
                _owner,
                _currentVersion,
                remainingGasTo
            );
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ADD WALLETS

    function addPair(
        address left_root,
        address right_root
    ) override external onlyOwner {
        _addPoolInternal([left_root, right_root]);
    }

    function addPool(address[] _roots) override external onlyOwner {
        _addPoolInternal(_roots);
    }

    function _addPoolInternal(address[] _roots) private view {
        require(_roots.length > 1, Errors.WRONG_PAIR);
        require(msg.value >= Constants.ADD_PAIR_MIN_VALUE, Errors.VALUE_TOO_LOW);

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        address pair = address(
            tvm.hash(
                _buildInitData(
                    PlatformTypes.Pool,
                    _buildPairParams(_roots)
                )
            )
        );

        emit AddPool(_roots, pair);

        IBasePool(pair)
            .checkPair{ value: 0, bounce: true, flag: MsgFlag.ALL_NOT_RESERVED }
            (_owner, _currentVersion);
    }

    function _deployWallet(
        address _tokenRoot,
        address _remainingGasTo
    ) private {
        _tmpDeployingWallets[_tokenRoot] = _remainingGasTo;

        ITokenRoot(_tokenRoot)
            .deployWallet{
                value: Constants.DEPLOY_EMPTY_WALLET_VALUE,
                flag: MsgFlag.SENDER_PAYS_FEES,
                callback: SwapAccount.onTokenWallet
            }(
                address(this),
                Constants.DEPLOY_EMPTY_WALLET_GRAMS
            );
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // CODE UPGRADE

    function requestUpgrade(address send_gas_to) external view onlyOwner {
        require(msg.value >= Constants.UPGRADE_ACCOUNT_MIN_VALUE, Errors.VALUE_TOO_LOW);

        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        emit CodeUpgradeRequested();

        IRoot(_root)
            .requestUpgradeAccount{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
            (_currentVersion, _owner, send_gas_to);
    }

    function upgrade(
        TvmCell _code,
        uint32 _newVersion,
        address _sendGasTo
    ) override external onlyRoot {
        if (_currentVersion == _newVersion) {
            tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

            _sendGasTo.transfer({
                value: 0,
                flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS
            });
        } else {
            emit AccountCodeUpgraded(_newVersion);

            TvmBuilder builder;

            builder.store(_root);
            builder.store(_vault);
            builder.store(_currentVersion);
            builder.store(_newVersion);
            builder.store(_sendGasTo);
            builder.store(platform_code);  // ref1 = platform_code

            TvmBuilder dataBuilder;        // ref2:
            dataBuilder.store(_owner);      //   owner
            dataBuilder.store(_wallets);   //   _wallets
            dataBuilder.store(_balances);  //   _balances
            builder.storeRef(dataBuilder);

            TvmBuilder tmpBuilder;                      // ref3:
            tmpBuilder.store(_tmpOperations);          //   _tmp_operations
            tmpBuilder.store(_tmpDeployingWallets);   //   _tmp_deploying_wallets
            builder.storeRef(tmpBuilder);

            // set code after complete this method
            tvm.setcode(_code);
            tvm.setCurrentCode(_code);

            onCodeUpgrade(builder.toCell());
        }
    }

    /*
        upgrade_data
            bits:
                uint32 old_version - zero if initialize
                uint32 new_version
                address root
                address send_gas_to
            refs:
                1: platform_code
                2: data
                    bits:
                        address owner
                        [mapping(address => address) _wallets]
                        [mapping(address => uint128) _balances]
                3: tmp
                    bits:
                        [mapping(uint64 => Operation) _tmpOperations]
                        [mapping(address => address) _tmpDeployingWallets]
    */
    function onCodeUpgrade(TvmCell _data) private {
        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);
        tvm.resetStorage();

        TvmSlice dataSlice = _data.toSlice();

        (
            address _rootAddress,
            address _vaultAddress,
            uint32 _oldVersion,
            uint32 _newVersion,
            address _sendGasTo
        ) = dataSlice.decode(
            address,
            address,
            uint32,
            uint32,
            address
        );

        _root = _rootAddress;
        _vault = _vaultAddress;
        _currentVersion = _newVersion;

        platform_code = dataSlice.loadRef();        // ref 1

        TvmSlice data = dataSlice.loadRefAsSlice(); // ref 2

        _owner = data.decode(address);

        if (_oldVersion != 0) {
            _wallets = data.decode(mapping(address => address));
            _balances = data.decode(mapping(address => uint128));

            TvmSlice tmp = dataSlice.loadRefAsSlice(); // ref 3
            _tmpOperations = tmp.decode(mapping(uint64 => Operation));
            _tmpDeployingWallets = tmp.decode(mapping(address => address));
        }

        _sendGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function _dexRoot() override internal view returns (address) {
        return _root;
    }

    onBounce(TvmSlice _body) external {
        tvm.rawReserve(Constants.ACCOUNT_INITIAL_BALANCE, 0);

        uint32 functionId = _body.decode(uint32);

        if (
            functionId == tvm.functionId(IBasePool.exchange) ||
            functionId == tvm.functionId(IBasePool.depositLiquidity) ||
            functionId == tvm.functionId(IBasePool.withdrawLiquidity) ||
            functionId == tvm.functionId(IAccount.internalAccountTransfer) ||
            functionId == tvm.functionId(ITokenVault.withdraw)
        ) {
            uint64 callId = _body.decode(uint64);

            if (_tmpOperations.exists(callId)) {
                Operation operation = _tmpOperations[callId];

                delete _tmpOperations[callId];

                for (TokenOperation op : operation.token_operations) {
                    _balances[op.root] += op.amount;

                    emit OperationRollback(
                        op.root,
                        op.amount,
                        _balances[op.root],
                        msg.sender
                    );
                }

                if (operation.send_gas_to == _owner) {
                    IAccountOwner(_owner)
                        .dexAccountOnBounce{
                            value: 0,
                            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
                            bounce: false
                        }(callId, functionId);
                } else {
                    IAccountOwner(_owner)
                        .dexAccountOnBounce{
                            value: Constants.OPERATION_CALLBACK_BASE,
                            flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                            bounce: false
                        }(callId, functionId);

                    operation.send_gas_to.transfer({
                        value: 0,
                        flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
                        bounce: false
                    });
                }
            }
        } else if (functionId == tvm.functionId(IBasePool.checkPair)) {
            emit ExpectedPairNotExist(msg.sender);

            IAccountOwner(_owner)
                .dexAccountOnBounce{
                    value: 0,
                    flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
                    bounce: false
                }(0, functionId);
        }
    }
}
