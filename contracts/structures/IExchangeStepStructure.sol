pragma ever-solidity >= 0.62.0;

interface IExchangeStepStructure {
    struct ExchangeStep {
        uint128 amount;
        address[] roots;
        address outcoming;
        uint128 numerator;
        uint32[] nextStepIndices;
    }
}
