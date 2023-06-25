pragma ever-solidity >= 0.62.0;

interface IAccountOwner {
    function dexAccountOnSuccess(uint64 nonce) external;
    function dexAccountOnBounce(uint64 nonce, uint32 functionId) external;
}
