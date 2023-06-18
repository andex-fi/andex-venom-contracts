pragma ever-solidity >= 0.62.0;

pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "./external/Tunnel.sol";


contract WvenomTunnel is Tunnels {
    constructor(
        address[] sources,
        address[] destinations,
        address owner_
    ) Tunnels(sources, destinations, owner_) public {}
}
