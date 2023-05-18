pragma ever-solidity >= 0.62.0;

import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.tsol";

import "../structures/ITokenOperationStructure.sol";
import "../structures/IExchangeStepStructure.sol";
import "../structures/IFeeParams.sol";
import "../structures/IExchangeFee.sol";

import "./ILiquidityTokenRootDeployedCallback.sol";
import "./ILiquidityTokenRootNotDeployedCallback.sol";

/// @title DEX Pool Interface
/// @notice Interface for interaction with DEX pool
interface IDexBasePool is
    IFeeParams,
    ITokenOperationStructure,
    IAcceptTokensTransferCallback,
    IExchangeStepStructure,
    IExchangeFee,
    ILiquidityTokenRootDeployedCallback,
    ILiquidityTokenRootNotDeployedCallback
{
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // EVENTS

    event ActiveStatusUpdated(
        bool current,
        bool previous
    );

    /// @dev Emits when fees config was successfully updated
    event FeesParamsUpdated(FeeParams params);

    /// @dev Emits when liquidity deposit was successfully processed
    event DepositLiquidity(
        address sender,
        address owner,
        TokenOperation[] tokens,
        uint128 lp
    );

    /// @dev Emits when liquidity withdrawal was successfully processed
    event WithdrawLiquidity(
        address sender,
        address owner,
        uint128 lp,
        TokenOperation[] tokens
    );

    /// @dev Emits when swap was successfully processed
    event Exchange(
        address sender,
        address recipient,
        address spentTokenRoot,
        uint128 spentAmount,
        address receiveTokenRoot,
        uint128 receiveAmount,
        ExchangeFee[] fees
    );

    /// @dev Emits when any operation was processed
    event ReferrerFees(
        TokenOperation[] fees
    );

    /// @dev Emits when pool's reserves was changed
    event Sync(
        uint128[] reserves,
        uint128 lp_supply
    );

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // GETTERS

    /// @notice Get DEX root address of the pool
    /// @return dex_root DEX root address
    function getRoot() external view responsible returns (address dex_root);

    /// @notice Get current version of the pool
    /// @return version Version of the pool
    function getVersion() external view responsible returns (uint32 version);

    /// @notice Get type of the pool's pool
    /// @return uint8 Type of the pool
    function getPoolType() external view responsible returns (uint8);

    /// @notice Get DEX vault address
    /// @return dex_vault DEX vault address
    function getVault() external view responsible returns (address dex_vault);

    /// @notice Get pool's fees config
    /// @return params Packed info response about fee params
    function getFeeParams() external view responsible returns (FeeParams params);

    /// @notice Get pool's collected fee reserves
    /// @return accumulatedFees Collected fees
    function getAccumulatedFees() external view responsible returns (uint128[] accumulatedFees);

    /// @notice Get pool's status
    /// @return bool Whether or not pool is active
    function isActive() external view responsible returns (bool);

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // SWAP

    /// @notice Perform exchange from DEX account
    /// @dev Only the DEX account can perform
    /// @param _callId Id of the call
    /// @param _accountOwner Address of the DEX account owner
    /// @param _accountVersion Version of the account
    /// @param _sendGasTo Receiver of the remaining gas
    function exchange(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation _expected,
        address _accountOwner,
        uint32 _accountVersion,
        address _sendGasTo
    ) external;

    /// @notice Perform cross pool swap from another pool
    /// @dev Only the DEX pool can perform
    /// @param _id Id of the call
    /// @param _prevPoolVersion Version of the previous pool
    /// @param _prevPoolType Type of the previous pool
    /// @param _prevPoolTokenRoots TokenRoots of the previous pool
    /// @param _op Operation type
    /// @param _spentTokenRoot Input TokenRoot address
    /// @param _spentAmount Input amount
    /// @param _senderAddress Address of the sender
    /// @param _originalGasTo Receiver of the remaining gas
    /// @param _deployWalletGrams Amount to spent for new wallet deploy
    /// @param _nextPayload Payload for the next pool
    /// @param _notifySuccess Whether or not notify if swap was executed
    /// @param _successPayload Payload for callback about successful swap
    /// @param _notifyCancel Whether or not notify if swap was failed
    /// @param _cancelPayload Payload for callback about failed swap
    function crossPoolExchange(
        uint64 _id,

        uint32 _prevPoolVersion,
        uint8 _prevPoolType,

        address[] _prevPoolTokenRoots,

        uint8 _op,
        address _spentTokenRoot,
        uint128 _spentAmount,

        address _senderAddress,
        address _recipient,
        address _referrer,

        address _originalGasTo,
        uint128 _deployWalletGrams,

        TvmCell _nextPayload,
        bool _notifySuccess,
        TvmCell _successPayload,
        bool _notifyCancel,
        TvmCell _cancelPayload
    ) external;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // DEPOSIT LIQUIDITY

    /// @notice Perform liquidity deposit from DEX account
    /// @dev Only the DEX account can perform
    /// @param _callId Id of the call
    /// @param _operations Input amounts
    /// @param _autoChange Whether or not swap token for full deposit
    /// @param _accountOwner Address of the DEX account owner
    /// @param _accountVersion Version of the account
    /// @param _remainingGasTo Receiver of the remaining gas
    function depositLiquidity(
        uint64 _callId,
        TokenOperation[] _operations,
        TokenOperation _expected,
        bool _autoChange,
        address _accountOwner,
        uint32 _accountVersion,
        address _remainingGasTo,
        address _referrer
    ) external;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // WITHDRAW LIQUIDITY

    /// @notice Perform liquidity withdrawal from DEX account
    /// @dev Only the DEX account can perform
    /// @param _callId Id of the call
    /// @param _operation Address of the LP root
    /// @param _accountOwner Address of the DEX account owner
    /// @param _accountVersion Version of the account
    /// @param _remainingGasTo Receiver of the remaining gas
    function withdrawLiquidity(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation[] _expected,
        address _accountOwner,
        uint32 _accountVersion,
        address _remainingGasTo
    ) external;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // INTERNAL

    /// @notice Upgrades contract's code
    /// @dev Only the DEX root can perform
    /// @param _code Contract's new code
    /// @param _newVersion Number of the new update
    /// @param _newType New pool type
    /// @param _remainingGasTo Receiver of the remaining gas
    function upgrade(
        TvmCell _code,
        uint32 _newVersion,
        uint8 _newType,
        address _remainingGasTo
    ) external;

    /// @notice Set new fee configuration
    /// @dev Only the DEX root can perform
    /// @param _params New fee params
    /// @param _remainingGasTo Receiver of the remaining gas
    function setFeeParams(
        FeeParams _params,
        address _remainingGasTo
    ) external;

    function setActive(
        bool _newActive,
        address _remainingGasTo
    ) external;

    /// @notice Check that pool exists from DEX account
    /// @dev Only the DEX account can perform
    /// @param _accountOwner Address of the DEX account owner
    /// @param _accountVersion Version of the account
    function checkPair(
        address _accountOwner,
        uint32 _accountVersion
    ) external;
}
