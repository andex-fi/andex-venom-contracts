pragma ever-solidity >= 0.62.0;

pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../external/Vault.sol";


contract TestWeverVault is Vault {
    constructor(
        address owner_,
        address root,
        address root_tunnel,
        uint128 receive_safe_fee,
        uint128 settings_deploy_wallet_grams,
        uint128 initial_balance
    ) Vault(owner_, root, root_tunnel, receive_safe_fee, settings_deploy_wallet_grams, initial_balance) public {}
}
