pragma ever-solidity >= 0.62.0;

interface IExchangeResult {
    struct ExchangeResult {
        bool left_to_right;
        uint128 spent;
        uint128 fee;
        uint128 received;
    }
}
