pragma ever-solidity >= 0.62.0;

import "./UtilityErrors.sol";

contract CheckPubKey {
    modifier checkPubKey() {
        require(
            msg.pubkey() == tvm.pubkey(),
            UtilityErrors.DIFFERENT_PUB_KEYS
        );
        _;
    }
}