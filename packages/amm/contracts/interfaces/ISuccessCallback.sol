pragma ever-solidity >= 0.62.0;

interface ISuccessCallback {
    function successCallback(
        uint64 call_id
    ) external;
}
