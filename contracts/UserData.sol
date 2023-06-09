pragma ever-solidity >= 0.62.0;
pragma AbiHeader expire;

import "./interfaces/IUserData.sol";
import "./libraries/MsgFlag.sol";

contract UserData is IUserData {
    uint32 current_version;
    TvmCell platform_code;

    uint128 amount;
    uint128[] rewardDebt;
    uint128[] entitled;
    uint128[] pool_debt;

    address swapMiningPool;
    address user; // setup from initData

    uint8 constant NOT_SWAP_MINING_POOL = 101;
    uint128 constant CONTRACT_MIN_BALANCE = 0.1 ever;
    uint32 constant MAX_VESTING_RATIO = 1000;
    uint256 constant SCALING_FACTOR = 1e18;

    // Cant be deployed directly
    constructor() public { revert(); }

    // should be called in onCodeUpgrade on platform initialization
    function _init(uint8 reward_tokens_count) internal {
        require (swapMiningPool == msg.sender, NOT_SWAP_MINING_POOL);
        for (uint i = 0; i < reward_tokens_count; i++) {
            rewardDebt.push(0);
            entitled.push(0);
            pool_debt.push(0);
        }
    }

    function _reserve() internal pure returns (uint128) {
        return math.max(address(this).balance - msg.value, CONTRACT_MIN_BALANCE);
    }

    function getDetails() external responsible view override returns (UserDataDetails) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } UserDataDetails (
            pool_debt,
            entitled,
            amount,
            rewardDebt,
            swapMiningPool,
            user,
            current_version
        );
    }

    function _isEven(uint64 num) internal pure returns (bool) {
        return (num / 2) == 0 ? true : false;
    }

    function _rangeSum(uint64 range) internal pure returns (uint64) {
        if (_isEven(range)) {
            return (range / 2) * range + (range / 2);
        }
        return ((range / 2) + 1) * range;
    }


}