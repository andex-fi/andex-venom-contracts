pragma ever-solidity >=0.62.0;
pragma AbiHeader expire;

interface IUserData {
    event UserDataUpdated(uint32 prev_version, uint32 new_version);

    struct UserDataDetails {
        uint128[] pool_debt;
        uint128[] entitled;
        uint128 amount;
        uint128[] rewardDebt;
        address swapMiningPool;
        address user;
        uint32 current_version;
    }

    function getDetails() external responsible view returns (UserDataDetails);
    function upgrade(TvmCell new_code, uint32 new_version, address send_gas_to) external;
}