pragma ever-solidity >= 0.62.0;

pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "./abstract/VaultBase.sol";


contract WvenomVault is VaultBase {
    constructor(
        address owner_,
        address root,
        address root_tunnel,
        uint128 receive_safe_fee,
        uint128 settings_deploy_wallet_grams,
        uint128 initial_balance
    ) VaultBase(owner_, root, root_tunnel, receive_safe_fee, settings_deploy_wallet_grams, initial_balance) public {}
}
