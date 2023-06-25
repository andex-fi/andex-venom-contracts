pragma ever-solidity >= 0.62.0;

interface IVenomTip3SwapCallbacks {
    function onSwapVenomToTip3Cancel(
        uint64 id,
        uint128 amount
     ) external;

    function onSwapVenomToTip3Partial(
        uint64 id,
        uint128 amount,
        address tokenRoot
    ) external;

    function onSwapVenomToTip3Success(
        uint64 id,
        uint128 amount,
        address tokenRoot
     ) external;

     function onSwapTip3ToVenomCancel(
         uint64 id,
         uint128 amount,
         address tokenRoot
     ) external;

     function onSwapTip3ToVenomSuccess(
         uint64 id,
         uint128 amount
     ) external;
}
