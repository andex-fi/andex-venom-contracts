pragma ever-solidity >= 0.62.0;

interface IDepositLiquidityResultV2 {
    struct DepositLiquidityResultV2 {
        uint128[] old_balances;
        uint128[] amounts;
        uint128 lp_reward;
        uint128[] result_balances;
        uint128 invariant;
        uint128[] differences;
        bool[] sell;
        uint128[] pool_fees;
        uint128[] beneficiary_fees;
    }
}
