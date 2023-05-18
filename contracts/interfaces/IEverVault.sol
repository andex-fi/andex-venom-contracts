pragma ever-solidity >= 0.62.0;

interface IEverVault {
    function wrap(
        uint128 tokens,
        address owner_address,
        address gas_back_address,
        TvmCell payload
    ) external;
}
