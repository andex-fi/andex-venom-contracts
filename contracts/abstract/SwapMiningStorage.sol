pragma ever-solidity >=0.62.0;
pragma AbiHeader expire;

abstract contract SwapMiningStorage {
    
    uint32 const MAX_UINT32 = 0xFFFFFFFF;
    uint128 constant SCALING_FACTOR = 1e18;

    // State vars
    uint32 lastRewardTime;

    //should be set dynamically
    address tokenRoot;
    address tokenWallet;
    uint128 tokenBalance;

    uint256[] accRewardPerShare;
    address[] rewardTokenRoot;
    address[] rewardTokenWallet;
    uint128[] rewardTokenBalance;
    uint128[] rewardTokenBalanceCumulative;
    uint128[] unclaimedReward;

    address owner;

    TvmCell static platform_code;
    TvmCell static user_data_code;

    address static chef;

    uint64 static deploy_nonce;

    uint32 static user_data_version;
    uint32 static pool_version;
}