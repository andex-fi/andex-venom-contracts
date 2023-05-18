pragma ever-solidity >= 0.62.0;

interface ISwapRoot {
    function requestUpgradeAccount(
        uint32 currentVersion,
        address sendGasTo,
        address owner
    ) external;
}