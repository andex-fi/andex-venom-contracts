pragma ever-solidity ^0.62.0;
pragma AbiHeader expire;

import "tip3/contracts/interfaces/ITokenRoot.sol";
import "tip3/contracts/interfaces/ITokenWallet.sol";
import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.sol";

import "../interfaces/IFarmPool.sol";
import "../interfaces/IManager.sol";
import "../interfaces/IUserData.sol";

import "../libraries/MsgFlag.sol";

abstract contract FarmPoolStorage is IFarmPool, IAcceptTokensTransferCallback {
    // ERRORS
    uint8 constant NOT_OWNER = 101;
    uint8 constant NOT_ROOT = 102;
    uint8 constant NOT_TOKEN_WALLET = 103;
    uint8 constant LOW_DEPOSIT_MSG_VALUE = 104;
    uint8 constant NOT_USER_DATA = 105;
    uint8 constant EXTERNAL_CALL = 106;
    uint8 constant ZERO_AMOUNT_INPUT = 107;
    uint8 constant LOW_WITHDRAW_MSG_VALUE = 108;
    uint8 constant FARMING_NOT_ENDED = 109;
    uint8 constant WRONG_INTERVAL = 110;
    uint8 constant BAD_REWARD_TOKENS_INPUT = 111;
    uint8 constant NOT_MANAGER = 112;
    uint8 constant LOW_CLAIM_REWARD_MSG_VALUE = 113;
    uint8 constant BAD_REWARD_ROUNDS_INPUT = 114;
    uint8 constant BAD_FARM_END_TIME = 115;
    uint8 constant BAD_VESTING_SETUP = 116;
    uint8 constant CANT_WITHDRAW_UNCLAIMED_ALL = 117;
    uint8 constant LOW_MSG_VALUE = 118;

    // constants
    uint128 constant TOKEN_WALLET_DEPLOY_VALUE = 0.5 ever;
    uint128 constant TOKEN_WALLET_DEPLOY_GRAMS_VALUE = 0.1 ever;
    uint128 constant MIN_CALL_MSG_VALUE = 1 ever;
    uint128 constant USER_DATA_DEPLOY_VALUE = 0.2 ever;
    uint128 constant USER_DATA_UPGRADE_VALUE = 1 ever;
    uint128 constant REQUEST_UPGRADE_VALUE = 1.5 ever;
    uint128 constant TOKEN_TRANSFER_VALUE = 1 ever;
    uint128 constant MANAGER_DEPLOY_CALLBACK_VALUE = 0.1 ever;
    uint128 constant ADD_REWARD_ROUND_VALUE = 0.5 ever;
    uint128 constant SET_END_TIME_VALUE = 0.5 ever;
    uint128 constant INCREASE_DEBT_VALUE = 0.3 ever;
    uint128 constant CONTRACT_MIN_BALANCE = 1 ever;

    uint32 constant MAX_UINT32 = 0xFFFFFFFF;
    uint128 constant SCALING_FACTOR = 1e18;

    uint32 withdrawAllLockPeriod;

    // State vars
    uint32 lastRewardTime;

    // should be set dynamically
    uint32 farmEndTime;

    uint32 vestingPeriod;

    uint32 vestingRatio;

    address tokenRoot;

    address tokenWallet;

    uint128 tokenBalance;

    RewardRound[] rewardRounds;

    uint256[] accRewardPerShare;

    address[] rewardTokenRoot;

    address[] rewardTokenWallet;

    uint128[] rewardTokenBalance;

    uint128[] rewardTokenBalanceCumulative;

    uint128[] unclaimedReward;

    address owner;

    struct PendingDeposit {
        address user;
        uint128 amount;
        address send_gas_to;
        uint32 nonce;
    }

    uint64 deposit_nonce = 0;
    // this is used to prevent data loss on bounced messages during deposit
    mapping (uint64 => PendingDeposit) deposits;
    //
    TvmCell static platformCode;

    TvmCell static userDataCode;

    address static manager;

    uint64 static deploy_nonce;

    uint32 static user_data_version;
    uint32 static pool_version;
}