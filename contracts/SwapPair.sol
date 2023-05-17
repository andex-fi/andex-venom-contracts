pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

contract SwapPair {
    // cant be deployed directly
    constructor() public { revert(); }
}
