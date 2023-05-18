pragma ever-solidity >= 0.62.0;

import "../structures/IDepositLiquidityResult.sol";

import "./IDexPair.sol";
import "./ITWAPOracle.sol";

/**
 * @title DEX Pair Interface
 * @notice Interface for pair with constant product formula logic aka k = y * x
 */
interface IDexConstantProductPair is
    IDexPair,
    IDepositLiquidityResult,
    ITWAPOracle
{
    /**
     * @notice Calculate expected result of liquidity deposit for given amounts
     * @param left_amount Amount of the left token for deposit
     * @param right_amount Amount of the right token to deposit
     * @param auto_change Whether or not swap incoming amounts with the current pair's reserves ratio
     * @return DepositLiquidityResult Data about expected deposit's steps
     */
    function expectedDepositLiquidity(
        uint128 left_amount,
        uint128 right_amount,
        bool auto_change
    ) external view responsible returns (DepositLiquidityResult);

    /**
     * @notice Build payload for TIP-3 token transfer with exchange operation
     * @param id ID of the call
     * @param deploy_wallet_grams Amount of EVER for a new TIP-3 wallet deploy
     * @param expected_amount Minimum token amount after swap
     * @return TvmCell Encoded payload for transfer
     */
    function buildExchangePayload(
        uint64 id,
        uint128 deploy_wallet_grams,
        uint128 expected_amount
    ) external pure returns (TvmCell);

    /**
     * @notice Build payload for TIP-3 token transfer with exchange operation
     * @param _id ID of the call
     * @param _deployWalletGrams Amount of EVER for a new TIP-3 wallet deploy
     * @param _expectedAmount Minimum token amount after swap
     * @param _recipient Address of the receiver
     * @return TvmCell Encoded payload for transfer
     */
    function buildExchangePayloadV2(
        uint64 _id,
        uint128 _deployWalletGrams,
        uint128 _expectedAmount,
        address _recipient,
        address _referrer,
        optional(TvmCell) _successPayload,
        optional(TvmCell) _cancelPayload
    ) external pure returns (TvmCell);

    /**
     * @notice Build payload for TIP-3 token transfer with liquidity deposit operation
     * @param id ID of the call
     * @param deploy_wallet_grams Amount of EVER for a new TIP-3 wallet deploy
     * @return TvmCell Encoded payload for transfer
     */
    function buildDepositLiquidityPayload(
        uint64 id,
        uint128 deploy_wallet_grams
    ) external pure returns (TvmCell);

    /**
     * @notice Build payload for TIP-3 token transfer with liquidity deposit operation
     * @param _id ID of the call
     * @param _deployWalletGrams Amount of EVER for a new TIP-3 wallet deploy
     * @param _expectedAmount Minimum LP token amount after deposit
     * @param _recipient Address of the receiver
     * @return TvmCell Encoded payload for transfer
     */
    function buildDepositLiquidityPayloadV2(
        uint64 _id,
        uint128 _deployWalletGrams,
        uint128 _expectedAmount,
        address _recipient,
        address _referrer,
        optional(TvmCell) _successPayload,
        optional(TvmCell) _cancelPayload
    ) external pure returns (TvmCell);

    /**
     * @notice Build payload for TIP-3 token transfer with liquidity withdrawal operation
     * @param id ID of the call
     * @param deploy_wallet_grams Amount of EVER for a new TIP-3 wallet deploy
     * @return TvmCell Encoded payload for transfer
     */
    function buildWithdrawLiquidityPayload(
        uint64 id,
        uint128 deploy_wallet_grams
    ) external pure returns (TvmCell);

    /**
     * @notice Build payload for TIP-3 token transfer with liquidity withdrawal operation
     * @param _id ID of the call
     * @param _deployWalletGrams Amount of EVER for a new TIP-3 wallet deploy
     * @param _expectedLeftAmount Minimum pair's left token amount after withdrawal
     * @param _expectedRightAmount Minimum pair's right token amount after withdrawal
     * @param _recipient Address of the receiver
     * @return TvmCell Encoded payload for transfer
     */
    function buildWithdrawLiquidityPayloadV2(
        uint64 _id,
        uint128 _deployWalletGrams,
        uint128 _expectedLeftAmount,
        uint128 _expectedRightAmount,
        address _recipient,
        address _referrer,
        optional(TvmCell) _successPayload,
        optional(TvmCell) _cancelPayload
    ) external pure returns (TvmCell);

    /**
     * @notice Build payload for TIP-3 token transfer with cross-pair exchange operation
     * @param id ID of the call
     * @param deploy_wallet_grams Amount of EVER for a new TIP-3 wallet deploy
     * @param expected_amount Minimum token amount after the first swap
     * @param steps Next pairs' root and expected amount
     * @return TvmCell Encoded payload for transfer
     */
    function buildCrossPairExchangePayload(
        uint64 id,
        uint128 deploy_wallet_grams,
        uint128 expected_amount,
        TokenOperation[] steps
    ) external pure returns (TvmCell);
}
