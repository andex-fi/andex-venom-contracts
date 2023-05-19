pragma ever-solidity >= 0.62.0;

interface IVenomTip3SwapEvents {

    event SwapVenomToTip3Start(
        address pair,
        uint8 operationType,
        uint64 id,
        address user
    );

    event SwapVenomToTip3Success(address user, uint64 id, uint128 amount, address tokenRoot);
    event SwapVenomToTip3Partial(address user, uint64 id, uint128 amount, address tokenRoot);
    event SwapVenomToTip3Cancel(address user, uint64 id, uint128 amount);

    // Tip3ToEvent contract events
    event SwapTip3EverSuccessTransfer(address user, uint64 id, uint128 amount);
    event SwapTip3EverCancelTransfer(address user, uint64 id, uint128 amount, address tokenRoot);

    // VenomWvenomToTip3 contract events
    event SwapVenomWvenomToTip3Unwrap(address user, uint64 id);
}
