pragma ever-solidity >= 0.62.0;

import "../structures/IDexPairBalances.sol";

import "./IDexBasePool.sol";

/// @title DEX Pair Interface
/// @notice Interface for interaction with DEX pair
interface IDexPair is IDexPairBalances, IDexBasePool {
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // EVENTS

    /// @dev Emits when pair's code was successfully upgraded
    event PairCodeUpgraded(
        uint32 version,
        uint8 pool_type
    );

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // GETTERS

    /// @notice Get TIP-3 tokens' roots of the pair
    /// @return left_root Packed info response about TokenRoots addresses
    function getTokenRoots() external view responsible returns (
        address left_root,
        address right_root,
        address lp_root
    );

    /// @notice Get TIP-3 tokens' wallets of the pair
    /// @return left Packed info response about TokenWallets addresses
    function getTokenWallets() external view responsible returns (
        address left,
        address right,
        address lp
    );

    /// @notice Get pair's reserves
    /// @return DexPairBalances Current reserves of the pair
    function getBalances() external view responsible returns (DexPairBalances);

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // SWAP

    /// @notice Calculate expected fees and output amount for swap
    /// @param amount Input amount
    /// @param spent_token_root Input TIP-3 TokenRoot
    /// @return expected_amount Fees and output amount after swap
    function expectedExchange(
        uint128 amount,
        address spent_token_root
    ) external view responsible returns (
        uint128 expected_amount,
        uint128 expected_fee
    );

    /// @notice Calculate expected fees and input amount for swap
    /// @param receive_amount Output amount
    /// @param receive_token_root Output TIP-3 TokenRoot
    /// @return expected_amount Fees and input amount before swap
    function expectedSpendAmount(
        uint128 receive_amount,
        address receive_token_root
    ) external view responsible returns (
        uint128 expected_amount,
        uint128 expected_fee
    );

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // WITHDRAW LIQUIDITY

    /// @notice Calculate expected output amounts after liquidity withdrawal
    /// @param lp_amount Amount of LP tokens to burn
    /// @return expected_left_amount Expected left and right amounts
    function expectedWithdrawLiquidity(
        uint128 lp_amount
    ) external view responsible returns (
        uint128 expected_left_amount,
        uint128 expected_right_amount
    );
}
