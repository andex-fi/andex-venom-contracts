pragma ever-solidity >= 0.62.0;

/// @title DEX Pair Balances Interface
/// @notice Structure for packed pair's reserves
interface IPairBalances {
    /// @dev Packed reserves of the pair
    struct DexPairBalances {
        uint128 lp_supply;
        uint128 left_balance;
        uint128 right_balance;
    }
}
