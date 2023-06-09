pragma ever-solidity >=0.62.0;
pragma AbiHeader expire;

abstract contract SwapMiningStorage {
    // Constants
    uint128 constant CONTRACT_MIN_BALANCE = 1 ever;
    
    uint32 constant MAX_UINT32 = 0xFFFFFFFF;
    uint128 constant SCALING_FACTOR = 1e18;

    // State vars

    uint128 lastRewardTime; // Last time rewards were distributed
    uint256[] accAndxPerShare; // Accumulated Andx per share, time 1e12.
    uint256[] allocPoint; // How many allocation points assigned to this pool. ksts to distribute per block.
    uint256[] quantity;
    uint256[] accQuantity;
    uint256[] allocAndxAmount;
    uint256[] accAndxAmount;

    //should be set dynamically
    address tokenRoot;
    address tokenWallet;
    uint128 tokenBalance;

    
    address[] rewardTokenRoot;
    address[] rewardTokenWallet;
    uint128[] rewardTokenBalance;
    uint128[] rewardTokenBalanceCumulative;
    uint128[] unclaimedReward;

    address lp_root; // Address of LP token contract.
    address lp_wallet; // Address of LP wallet.
    
    address owner;

    TvmCell static platform_code;
    TvmCell static user_data_code;

    address static chef;

    uint64 static deploy_nonce;

    uint32 static user_data_version;
    uint32 static pool_version;
}