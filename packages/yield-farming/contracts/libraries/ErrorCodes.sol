pragma ever-solidity ^0.62.0;


library ErrorCodes {
    // Access
    uint16 constant NOT_OWNER = 1101;
    uint16 constant ZERO_OWNER = 1102;

    // Utils
    // - CheckPubKey
    uint16 constant DIFFERENT_PUB_KEYS = 1103;
}
