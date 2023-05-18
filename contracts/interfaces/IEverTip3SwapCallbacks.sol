pragma ever-solidity >= 0.62.0;

interface IEverTip3SwapCallbacks {
    function onSwapEverToTip3Cancel(
        uint64 id,
        uint128 amount
     ) external;

    function onSwapEverToTip3Partial(
        uint64 id,
        uint128 amount,
        address tokenRoot
    ) external;

    function onSwapEverToTip3Success(
        uint64 id,
        uint128 amount,
        address tokenRoot
     ) external;

     function onSwapTip3ToEverCancel(
         uint64 id,
         uint128 amount,
         address tokenRoot
     ) external;

     function onSwapTip3ToEverSuccess(
         uint64 id,
         uint128 amount
     ) external;
}
