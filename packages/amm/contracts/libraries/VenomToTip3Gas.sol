pragma ever-solidity >= 0.62.0;

library VenomToTip3Gas {
    uint128 constant TARGET_BALANCE                 = 1 ever;
    uint128 constant DEPLOY_EMPTY_WALLET_VALUE      = 0.5 ever;
    uint128 constant DEPLOY_EMPTY_WALLET_GRAMS      = 0.1 ever;
    uint128 constant SWAP_TIP3_TO_VENOM_MIN_VALUE    = 3 ever;
    uint128 constant SWAP_VENOM_TO_TIP3_MIN_VALUE    = 4 ever;
    uint128 constant OPERATION_CALLBACK_BASE        = 0.01 ever;
}
