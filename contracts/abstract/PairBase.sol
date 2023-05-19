pragma ever-solidity >= 0.62.0;

import "tip3/contracts/interfaces/ITokenRoot.tsol";

import "../interfaces/IConstantProductPair.sol";
import "../interfaces/IAccount.sol";
import "../interfaces/IRoot.sol";
import "../interfaces/ITokenVault.sol";

import "../libraries/PoolTypes.sol";
import "../libraries/Constants.sol";
import "../libraries/AddressType.sol";
import "../libraries/ReserveType.sol";

import "../structures/IPoolTokenData.sol";
import "../structures/IAmplificationCoefficient.sol";

import "./ContractBase.sol";
import "./TWAPOracle.sol";

/// @title DEX Pair Base
/// @notice Base implementation of the DEX pair
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract PairBase is
    ContractBase,
    IConstantProductPair,
    TWAPOracle
{
    /// @dev Root address
    address private _root;

    /// @dev Root address
    address private _vault;

    /// @dev Whether or not pair is active
    bool internal _active;

    /// @dev Current pair's code version
    uint32 internal _currentVersion;

    /// @dev Pair's fee params
    FeeParams internal _fee;

    /// @dev Mapping for vault, lp and TIP-3 roots addresses
    mapping(uint8 => address[]) internal _typeToRootAddresses;

    /// @dev Mapping for lp and TIP-3 wallets addresses
    mapping(uint8 => address[]) internal _typeToWalletAddresses;

    /// @dev Mapping for pool, lp and fee reserves
    mapping(uint8 => uint128[]) internal _typeToReserves;

    // Prevent manual transfers
    receive() external pure {
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);
        msg.sender.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    // Prevent undefined functions call, need for bounce future Account/Root functions calls, when not upgraded
    fallback() external pure {
        revert();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // MODIFIERS

    /// @dev Only the pair's owner can call a function with this modifier
    modifier onlyActive() {
        require(_active, Errors.NOT_ACTIVE);
        _;
    }

    /// @dev Only pair's LP TokenRoot can call a function with this modifier
    modifier onlyLiquidityTokenRoot() {
        require(
            _typeToRootAddresses[AddressType.LP][0].value != 0 &&
            msg.sender == _typeToRootAddresses[AddressType.LP][0],
            Errors.NOT_LP_TOKEN_ROOT
        );
        _;
    }

    /// @dev Only TIP-3 TokenRoot can call a function with this modifier
    modifier onlyTokenRoot() {
        require(
            (_typeToRootAddresses[AddressType.RESERVE][0].value != 0 && msg.sender == _typeToRootAddresses[AddressType.RESERVE][0]) ||
            (_typeToRootAddresses[AddressType.RESERVE][1].value != 0 && msg.sender == _typeToRootAddresses[AddressType.RESERVE][1]) ||
            (_typeToRootAddresses[AddressType.LP][0].value != 0 && msg.sender == _typeToRootAddresses[AddressType.LP][0]),
            Errors.NOT_TOKEN_ROOT
        );
        _;
    }

    /// @dev Only the DEX root can call a function with this modifier
    modifier onlyRoot() override {
        require(_root.value != 0 && msg.sender == _root, Errors.NOT_ROOT);
        _;
    }

    /// @dev Only DEX pair or the DEX token vault can call a function with this modifier
    modifier onlyPoolOrTokenVault(address[] _poolTokenRoots, address _tokenRoot) {
        require(
            msg.sender == _expectedPoolAddress(_poolTokenRoots) ||
            msg.sender == _expectedTokenVaultAddress(_tokenRoot),
            Errors.NEITHER_POOL_NOR_VAULT
        );
        _;
    }

    /// @dev Prevent function calls from the same contract
    modifier notSelfCall() {
        require(msg.sender != address(this));
        _;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // GETTERS

    // Return dex root address
    function getRoot() override external view responsible returns (address dex_root) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _root;
    }

    // Return token roots addresses
    function getTokenRoots() override external view responsible returns (
        address left,
        address right,
        address lp
    ) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } (
            _typeToRootAddresses[AddressType.RESERVE][0],
            _typeToRootAddresses[AddressType.RESERVE][1],
            _typeToRootAddresses[AddressType.LP][0]
        );
    }

    // Return pair's wallets addresses
    function getTokenWallets() override external view responsible returns (
        address left,
        address right,
        address lp
    ) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } (
            _typeToWalletAddresses[AddressType.RESERVE][0],
            _typeToWalletAddresses[AddressType.RESERVE][1],
            _typeToWalletAddresses[AddressType.LP][0]
        );
    }

    // Return current version
    function getVersion() override external view responsible returns (uint32 version) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _currentVersion;
    }

    // Return Vault address
    function getVault() override external view responsible returns (address) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _vault;
    }

    // Return type of the pair's pool
    function getPoolType() override external view responsible returns (uint8) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } PoolTypes.CONSTANT_PRODUCT;
    }

    // Return fee options
    function getFeeParams() override external view responsible returns (FeeParams) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _fee;
    }

    // return packed values of accumulated fees
    function getAccumulatedFees() override external view responsible returns (uint128[] accumulatedFees) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _typeToReserves[ReserveType.FEE];
    }

    // is pair active
    function isActive() override external view responsible returns (bool) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _active;
    }

    // return current pair's reserves
    function getBalances() override external view responsible returns (PairBalances) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } PairBalances(
            _typeToReserves[ReserveType.LP][0],
            _typeToReserves[ReserveType.POOL][0],
            _typeToReserves[ReserveType.POOL][1]
        );
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // INTERNAL

    function setFeeParams(
        FeeParams _params,
        address _remainingGasTo
    ) override external onlyRoot {
        // Check input params
        require(
            _params.denominator != 0 &&
            (_params.pool_numerator + _params.beneficiary_numerator + _params.referrer_numerator) < _params.denominator &&
            ((_params.beneficiary.value != 0 && _params.beneficiary_numerator != 0) ||
            (_params.beneficiary.value == 0 && _params.beneficiary_numerator == 0)),
            Errors.WRONG_FEE_PARAMS
        );
        require(msg.value >= Constants.SET_FEE_PARAMS_MIN_VALUE, Errors.VALUE_TOO_LOW);
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        // Flush all fees from pair
        if (_fee.beneficiary.value != 0) {
            _processBeneficiaryFees(true, _remainingGasTo);
        }

        // Update fee options and notify
        _fee = _params;
        emit FeesParamsUpdated(_fee);

        // Refund remaining gas
        _remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED,
            bounce: false
        });
    }

    function withdrawBeneficiaryFee(address send_gas_to) external {
        require(_fee.beneficiary.value != 0 && msg.sender == _fee.beneficiary, Errors.NOT_BENEFICIARY);
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        // Withdraw left and right accumulated fees
        _processBeneficiaryFees(true, send_gas_to);

        // Refund remaining gas
        send_gas_to.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function checkPair(
        address _accountOwner,
        uint32
    ) override external onlyAccount(_accountOwner) {
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        // Notify account about pair
        IAccount(msg.sender)
            .checkPoolCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
            (
                _typeToRootAddresses[AddressType.RESERVE],
                _typeToRootAddresses[AddressType.LP][0]
            );
    }

    function upgrade(
        TvmCell _code,
        uint32 _newVersion,
        uint8 _newType,
        address _remainingGasTo
    ) override external onlyRoot {
        if (
            _currentVersion == _newVersion &&
            _newType == PoolTypes.CONSTANT_PRODUCT
        ) {
            tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

            _remainingGasTo.transfer({
                value: 0,
                flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
                bounce: false
            });
        } else {
            if (_fee.beneficiary.value != 0) {
                _processBeneficiaryFees(true, _remainingGasTo);
            }

            emit PairCodeUpgraded(_newVersion, _newType);

            TvmBuilder builder;

            builder.store(_root);
            builder.store(_vault);
            builder.store(_currentVersion);
            builder.store(_newVersion);
            builder.store(_remainingGasTo);
            builder.store(PoolTypes.CONSTANT_PRODUCT);
            builder.store(platform_code);  // ref1 = platform_code

            TvmCell otherData = abi.encode(
                _fee,
                _typeToReserves,
                _typeToRootAddresses,
                _typeToWalletAddresses
            );

            builder.store(otherData);   // ref2
            builder.store(_packAllOracleData());    // ref3

            // set code after complete this method
            tvm.setcode(_code);
            tvm.setCurrentCode(_code);

            onCodeUpgrade(builder.toCell());
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // CALLBACKS

    function liquidityTokenRootDeployed(
        address _lpRootAddress,
        address _remainingGasTo
    ) override external onlyRoot {
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        _typeToRootAddresses[AddressType.LP].push(_lpRootAddress);

        // Deploy wallets for pair
        _configureTokenRootWallets(_typeToRootAddresses[AddressType.LP][0]);
        _configureTokenRootWallets(_typeToRootAddresses[AddressType.RESERVE][0]);
        _configureTokenRootWallets(_typeToRootAddresses[AddressType.RESERVE][1]);

        // Notify root that pair was created
        IRoot(_root)
            .onPoolCreated{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
            (
                _tokenRoots(),
                PoolTypes.CONSTANT_PRODUCT,
                _remainingGasTo
            );
    }

    function liquidityTokenRootNotDeployed(
        address,
        address _remainingGasTo
    ) override external onlyRoot {
        // Destroy pair if it's not active
        if (!_active) {
            _remainingGasTo.transfer({
                value: 0,
                flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.DESTROY_IF_ZERO,
                bounce: false
            });
        } else {
            tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

            _remainingGasTo.transfer({
                value: 0,
                flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
                bounce: false
            });
        }
    }

    /// @dev Callback after wallet deploy for reserve
    /// @param _wallet Address of the wallet with for pair's reserve
    function onTokenWallet(address _wallet) external onlyTokenRoot {
        // Set wallets addresses and values
        if (
            msg.sender == _typeToRootAddresses[AddressType.LP][0] &&
            _typeToWalletAddresses[AddressType.LP].length == 0
        ) {
            _typeToWalletAddresses[AddressType.LP].push(_wallet);
            _typeToReserves[ReserveType.LP].push(0);
        } else if (
            msg.sender == _typeToRootAddresses[AddressType.RESERVE][0]
        ) {
            if (
                _typeToWalletAddresses[AddressType.RESERVE].length == 0
            ) {
                _typeToWalletAddresses[AddressType.RESERVE].push(_wallet);

                _typeToReserves[ReserveType.POOL].push(0);
                _typeToReserves[ReserveType.FEE].push(0);
            } else if (
                _typeToWalletAddresses[AddressType.RESERVE].length == 2 &&
                _typeToWalletAddresses[AddressType.RESERVE][0].value == 0
            ) {
                _typeToWalletAddresses[AddressType.RESERVE][0] = _wallet;

                _typeToReserves[ReserveType.POOL].push(0);
                _typeToReserves[ReserveType.FEE].push(0);
            }
        } else if (
            msg.sender == _typeToRootAddresses[AddressType.RESERVE][1]
        ) {
            if (
                _typeToWalletAddresses[AddressType.RESERVE].length == 1 &&
                _typeToWalletAddresses[AddressType.RESERVE][0] != _wallet
            ) {
                _typeToWalletAddresses[AddressType.RESERVE].push(_wallet);

                _typeToReserves[ReserveType.POOL].push(0);
                _typeToReserves[ReserveType.FEE].push(0);
            } else if (
                _typeToWalletAddresses[AddressType.RESERVE].length == 0
            ) {
                _typeToWalletAddresses[AddressType.RESERVE].push(address(0));
                _typeToWalletAddresses[AddressType.RESERVE].push(_wallet);

                _typeToReserves[ReserveType.POOL].push(0);
                _typeToReserves[ReserveType.FEE].push(0);
            }
        }

        _tryToActivate();

        _wallet.transfer({
            value: 0,
            flag: MsgFlag.REMAINING_GAS + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    /// @dev Returns DEX root address
    /// @return address Root address
    function _dexRoot() override internal view returns (address) {
        return _root;
    }

    /// @dev Withdraw accumulated beneficiary's fees
    /// @param _isForce Whether or not withdraw if accumulated fees are lower than threshold
    /// @param _remainingGasTo Receiver of the remaining gas
    function _processBeneficiaryFees(
        bool _isForce,
        address _remainingGasTo
    ) internal {
        for (uint i = 0; i < _typeToReserves[ReserveType.FEE].length; i++) {
            if (
                (_typeToReserves[ReserveType.FEE][i] > 0 && _isForce) ||
                !_fee.threshold.exists(_typeToRootAddresses[AddressType.RESERVE][i]) ||
                _typeToReserves[ReserveType.FEE][i] >= _fee.threshold.at(_typeToRootAddresses[AddressType.RESERVE][i])
            ) {
                IAccount(_expectedAccountAddress(_fee.beneficiary))
                    .internalPoolTransfer{ value: Constants.INTERNAL_PAIR_TRANSFER_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                    (
                        _typeToReserves[ReserveType.FEE][i],
                        _typeToRootAddresses[AddressType.RESERVE][i],
                        _typeToRootAddresses[AddressType.RESERVE],
                        _remainingGasTo
                    );

                    _typeToReserves[ReserveType.FEE][i] = 0;
            }
        }
    }

    /// @dev Pack left and right reserves and return them
    /// @return uint128[] Reserves' values sorted by reserves roots
    function _reserves() internal view override returns (uint128[]) {
        return _typeToReserves[ReserveType.POOL];
    }

    /// @dev Emits sync event with pair's balances
    function _sync() internal view {
        emit Sync(_reserves(), _typeToReserves[ReserveType.LP][0]);
    }

    /// @dev Pack left and right TIP-3 token roots and return them
    /// @return address[] Sorted TokenRoot addresses of the reserves
    function _tokenRoots() internal view override returns (address[]) {
        return _typeToRootAddresses[AddressType.RESERVE];
    }

    function _lpRoot() internal view returns (address) {
        return _typeToRootAddresses[AddressType.LP][0];
    }

    function _lpReserve() internal view returns (uint128) {
        return _typeToReserves[ReserveType.LP][0];
    }

    /// @dev Deploys wallet by TIP-3 token root and wait for callback
    /// @param _tokenRoot Address of the TIP-3 TokenRoot for a new wallet deploy
    function _configureTokenRootWallets(address _tokenRoot) private pure {
        ITokenRoot(_tokenRoot)
            .deployWallet{
                value: Constants.DEPLOY_EMPTY_WALLET_VALUE,
                flag: MsgFlag.SENDER_PAYS_FEES,
                callback: PairBase.onTokenWallet
            }(address(this), Constants.DEPLOY_EMPTY_WALLET_GRAMS);
    }

    function setActive(
        bool _newActive,
        address _remainingGasTo
    ) external override onlyRoot {
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        bool previous = _active;

        if (_newActive) {
            _tryToActivate();
        } else {
            _active = false;
        }

        emit ActiveStatusUpdated({
            current: _active,
            previous: previous
        });

        _remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    /// @dev Will activate pair if all wallets' addresses are set
    function _tryToActivate() private {
        if (
            _typeToWalletAddresses[AddressType.LP].length == 1 &&
            _typeToWalletAddresses[AddressType.RESERVE].length == 2
        ) {
            _active = true;
        }
    }

    /// @dev Restores old data after contract's code update
    /// @param _data Old encoded data
    function onCodeUpgrade(TvmCell _data) private {
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);
        tvm.resetStorage();

        TvmSlice dataSlice = _data.toSlice();

        address remainingGasTo;
        uint32 oldVersion;
        uint8 oldPoolType = PoolTypes.CONSTANT_PRODUCT;

        // Unpack base data
        (
            _root,
            _vault,
            oldVersion,
            _currentVersion,
            remainingGasTo
        ) = dataSlice.decode(
            address,
            address,
            uint32,
            uint32,
            address
        );

        if (dataSlice.bits() >= 8) {
            oldPoolType = dataSlice.decode(uint8);
        }

        // Load platform's code
        platform_code = dataSlice.loadRef(); // ref 1

        address leftRoot;
        address rightRoot;

        if (oldVersion == 0) {
            TvmSlice tokensDataSlice = dataSlice.loadRefAsSlice(); // ref 2
            (leftRoot, rightRoot) = tokensDataSlice.decode(address, address);

            // Set token roots
            _typeToRootAddresses[AddressType.RESERVE].push(leftRoot);
            _typeToRootAddresses[AddressType.RESERVE].push(rightRoot);

            // Set initial params for fees
            _fee = FeeParams(1000000, 3000, 0, 0, address(0), emptyMap, emptyMap);

            // Deploy LP TokenRoot and vault for each token
            IRoot(_root)
                .deployLpToken{
                    value: 0,
                    flag: MsgFlag.ALL_NOT_RESERVED,
                    bounce: false
                }(
                    _typeToRootAddresses[AddressType.RESERVE],
                    remainingGasTo
                );

            _initializeTWAPOracle(now);
        } else if (oldPoolType == PoolTypes.CONSTANT_PRODUCT) {
            _active = true;
            TvmCell otherData = dataSlice.loadRef(); // ref 2

            // Decode reserves, wallets and fee options
            (
                _fee,
                _typeToReserves,
                _typeToRootAddresses,
                _typeToWalletAddresses
            ) = abi.decode(otherData, (
                FeeParams,
                mapping(uint8 => uint128[]),
                mapping(uint8 => address[]),
                mapping(uint8 => address[])
            ));

            if (dataSlice.refs() > 0) {
                TvmSlice oracleDataSlice = dataSlice.loadRefAsSlice();  // ref 4

                (
                    _points,
                    _options,
                    _length
                ) = oracleDataSlice.decode(
                    mapping(uint32 => Point),
                    OracleOptions,
                    uint16
                );
            }
        } else if (oldPoolType == PoolTypes.STABLESWAP) {
            TvmSlice tokensDataSlice = dataSlice.loadRefAsSlice(); // ref 2
            (leftRoot, rightRoot) = tokensDataSlice.decode(address, address);

            // Set token roots
            _typeToRootAddresses[AddressType.RESERVE].push(leftRoot);
            _typeToRootAddresses[AddressType.RESERVE].push(rightRoot);

            TvmCell otherData = dataSlice.loadRef(); // ref 3
            IPoolTokenData.PoolTokenData[] tokensData = new IPoolTokenData.PoolTokenData[](2);

            _active = true;

            address lpRoot;
            address lpWallet;
            uint128 lpSupply;

            // Set lp reserve and fee options
            (
                lpRoot, lpWallet, lpSupply,
                _fee,
                tokensData,,
            ) = abi.decode(otherData, (
                address, address, uint128,
                FeeParams,
                IPoolTokenData.PoolTokenData[],
                IAmplificationCoefficient.AmplificationCoefficient,
                uint256
            ));

            // Set lp reserve
            _typeToRootAddresses[AddressType.LP].push(lpRoot);
            _typeToWalletAddresses[AddressType.LP].push(lpWallet);
            _typeToReserves[ReserveType.LP].push(lpSupply);

            // Set left reserve and wallet
            _typeToWalletAddresses[AddressType.RESERVE].push(tokensData[0].wallet);
            _typeToReserves[ReserveType.POOL].push(tokensData[0].balance);

            // Set right reserve and wallet
            _typeToWalletAddresses[AddressType.RESERVE].push(tokensData[1].wallet);
            _typeToReserves[ReserveType.POOL].push(tokensData[1].balance);

            // Set fee reserves
            _typeToReserves[ReserveType.FEE].push(tokensData[0].accumulatedFee);
            _typeToReserves[ReserveType.FEE].push(tokensData[1].accumulatedFee);

            _initializeTWAPOracle(now);
        } else if (oldPoolType == PoolTypes.STABLE_POOL) {
            TvmCell tokenDataCell = dataSlice.loadRef(); // ref 2
            _typeToRootAddresses[AddressType.RESERVE] = abi.decode(tokenDataCell, address[]);

            TvmCell otherData = dataSlice.loadRef(); // ref 3
            IPoolTokenData.PoolTokenData[] tokensData = new IPoolTokenData.PoolTokenData[](2);

            _active = true;

            address lpRoot;
            address lpWallet;
            uint128 lpSupply;

            // Set lp reserve and fee options
            (
                lpRoot, lpWallet, lpSupply,
                _fee,
                tokensData,,
            ) = abi.decode(otherData, (
                address, address, uint128,
                FeeParams,
                IPoolTokenData.PoolTokenData[],
                IAmplificationCoefficient.AmplificationCoefficient,
                uint256
            ));

            // Set lp reserve
            _typeToRootAddresses[AddressType.LP].push(lpRoot);
            _typeToWalletAddresses[AddressType.LP].push(lpWallet);
            _typeToReserves[ReserveType.LP].push(lpSupply);

            // Set left reserve and wallet
            _typeToWalletAddresses[AddressType.RESERVE].push(tokensData[0].wallet);
            _typeToReserves[ReserveType.POOL].push(tokensData[0].balance);

            // Set right reserve and wallet
            _typeToWalletAddresses[AddressType.RESERVE].push(tokensData[1].wallet);
            _typeToReserves[ReserveType.POOL].push(tokensData[1].balance);

            // Set fee reserves
            _typeToReserves[ReserveType.FEE].push(tokensData[0].accumulatedFee);
            _typeToReserves[ReserveType.FEE].push(tokensData[1].accumulatedFee);

            _initializeTWAPOracle(now);
        }

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }
}
