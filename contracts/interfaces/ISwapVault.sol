pragma ever-solidity >= 0.6.2;

interface IDexVault {
    function addLiquidityToken(
        address pair,
        address left_root,
        address right_root,
        address send_gas_to
    ) external;

    function deployTokenWallet(
        address owner,
        address token_root,
        address send_gas_to
    ) external;

    function withdrawRequest(
        uint64 callbackId,
        uint128 amount,
        address token_root,
        address owner
    ) external;
}
