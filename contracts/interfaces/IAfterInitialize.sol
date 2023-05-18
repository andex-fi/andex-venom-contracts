pragma ever-solidity >= 0.62.0;

interface IAfterInitialize {
    function afterInitialize(address send_gas_to) external;
}
