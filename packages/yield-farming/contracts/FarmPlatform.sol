pragma ever-solidity >= 0.57.0;

import "./external/Platform.sol";

contract FarmPlatform is Platform {
    constructor(
        TvmCell code,
        TvmCell params,
        address sendGasTo
    ) public Platform (
        code,
        params,
        sendGasTo
    ) {}
}