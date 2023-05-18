pragma ever-solidity >= 0.62.0;

interface IPoolTokenData {
    struct PoolTokenData {
        address root;
        address wallet;
        uint128 balance;
        uint8 decimals;
        uint128 accumulatedFee;
        uint256 rate;
        uint256 precisionMul;
        bool decimalsLoaded;
        bool initialized;
    }
}
