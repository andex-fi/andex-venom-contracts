pragma ever-solidity >= 0.62.0;

interface IPoolTokenDataPrev {
    struct PoolTokenDataPrev {
        address root;
        address wallet;
        address vaultWallet;
        uint128 balance;
        uint8 decimals;
        uint128 accumulatedFee;
        uint256 rate;
        uint256 precisionMul;
        bool decimalsLoaded;
        bool initialized;
    }
}
