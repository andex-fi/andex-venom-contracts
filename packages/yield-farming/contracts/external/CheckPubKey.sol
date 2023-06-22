pragma ever-solidity ^0.62.0;


import "../libraries/ErrorCodes.sol";


contract CheckPubKey {
    modifier checkPubKey() {
        require(msg.pubkey() == tvm.pubkey(), ErrorCodes.DIFFERENT_PUB_KEYS);
        _;
    }
}
