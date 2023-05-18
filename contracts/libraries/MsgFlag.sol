pragma ever-solidity >= 0.6.2;

library MsgFlag {
    uint8 constant AddTranFees  = 1;
    uint8 constant IgnoreErrors = 2;
    uint8 constant DESTROY_IF_ZERO  = 32;
    uint8 constant ALL_REMAIN   = 64;
    uint8 constant ALL_NOT_RESERVED   = 128;
}