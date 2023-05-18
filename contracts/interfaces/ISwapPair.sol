pragma ever-solidity >= 0.62.0;

interface ISwapPair {
    function liquidityTokenRootDeployed(address lp_root, address send_gas_to) external;
}