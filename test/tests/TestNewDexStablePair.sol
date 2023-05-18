pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../libraries/MsgFlag.sol";

import "../libraries/Errors.sol";
import "../libraries/Constants.sol";
import "../libraries/PoolTypes.sol";

import "../interfaces/IPair.sol";

import "../structures/ITokenOperationStructure.sol";
import "../structures/IPairBalances.sol";
import "../structures/IPoolTokenData.sol";
import "../structures/IAmplificationCoefficient.sol";

// This is just for test purposes, this is not a real contract!
contract TestNewDexStablePair is
    ITokenOperationStructure,
    IFeeParams,
    IPoolTokenData,
    IPairBalances,
    IAmplificationCoefficient
{
    address root;
    address vault;
    uint32 current_version;
    TvmCell public platform_code;

    // Params:
    address left_root;
    address right_root;

    // Custom:
    bool active;

    // Token data
    PoolTokenData[] tokenData;
    uint256 PRECISION;
    // Liquidity tokens
    address public lp_wallet;
    address public lp_root;
    uint128 public lp_supply;
    // Fee
    FeeParams fee;

    AmplificationCoefficient A;
    uint8 constant N_COINS = 2;

    // v2
    uint64 _nonce;
    mapping(uint64 => TokenOperation) _tmp_operations;
    mapping(uint64 => address) _tmp_send_gas_to;
    mapping(uint64 => address) _tmp_expected_callback_sender;
    mapping(uint64 => uint256) _tmp_sender_public_key;
    mapping(uint64 => address) _tmp_sender_address;

    string newTestField;

    constructor() public {revert();}

    function getRoot() external view responsible returns (address dex_root) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } root;
    }

    function getTokenRoots() external view responsible returns (address left, address right, address lp) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } (tokenData[0].root, tokenData[1].root, lp_root);
    }

    function getTokenWallets() external view responsible returns (address left, address right, address lp) {
        return {
        value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS
        } (tokenData[0].wallet, tokenData[1].wallet, lp_wallet);
    }

    function getVersion() external view responsible returns (uint32 version) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } current_version;
    }

    function getPoolType() external pure responsible returns (uint8) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } PoolTypes.STABLESWAP;
    }

    function getAccumulatedFees() external view responsible returns (uint128[] accumulatedFees) {
        uint128[] _accumulatedFees = new uint128[](0);

        for (uint8 i = 0; i < N_COINS; i++) {
            _accumulatedFees.push(tokenData[i].accumulatedFee);
        }

        return {
        value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS
        } _accumulatedFees;
    }

    function getFeeParams() external view responsible returns (FeeParams) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } fee;
    }

    function getAmplificationCoefficient() external view responsible returns (AmplificationCoefficient) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } A;
    }

    function isActive() external view responsible returns (bool) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } active;
    }

    function getBalances() external view responsible returns (DexPairBalances) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } DexPairBalances(
            lp_supply,
            tokenData[0].balance,
            tokenData[1].balance
        );
    }

    function onCodeUpgrade(TvmCell data) private {
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 2);
        tvm.resetStorage();
        TvmSlice s = data.toSlice();

        address send_gas_to;
        uint32 old_version;

        active = true;

        (root, vault, old_version, current_version, send_gas_to) = s.decode(address, address, uint32, uint32, address);

        platform_code = s.loadRef(); // ref 1

        TvmSlice tokens_data_slice =  s.loadRefAsSlice(); // ref 2

        (left_root, right_root) = tokens_data_slice.decode(address, address);

        TvmCell otherData = s.loadRef(); // ref 3

        (
            lp_root, lp_wallet, lp_supply,
            fee,
            tokenData,
            A, PRECISION
        ) = abi.decode(otherData, (
            address, address, uint128,
            FeeParams,
            PoolTokenData[],
            AmplificationCoefficient,
            uint256
        ));

        newTestField = "New Stable Pair";

        send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED });
    }

    function newFunc() public view returns (string) {
        return newTestField;
    }
}
