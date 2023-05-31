pragma ever-solidity >= 0.62.0;
pragma AbiHeader expire;

import "./SwapMiningStorage.sol";

abstract contract SwapMiningBase is SwapMiningStorage {

    function _init_reward_arrays() internal virtual {
        for (uint i = 0; i < rewardTokenRoot.length; i++) {
            accRewardPerShare.push(0);
            rewardTokenWallet.push(address.makeAddrNone());
            rewardTokenBalance.push(0);
            rewardTokenBalanceCumulative.push(0);
            unclaimedReward.push(0);
        }
    }

    function _reserve() internal virtual pure returns (uint128) {
        return math.max(address(this).balance - msg.value, CONTRACT_MIN_BALANCE);
    }
}