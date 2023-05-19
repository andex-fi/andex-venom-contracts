pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../libraries/MsgFlag.sol";

import "../libraries/Errors.sol";
import "../libraries/Constants.sol";
import "../libraries/FixedPoint128.sol";
import "../libraries/AddressType.sol";
import "../libraries/ReserveType.sol";
import "../libraries/PoolTypes.sol";

import "../interfaces/IPair.sol";

import "../structures/ITokenOperationStructure.sol";
import "../structures/IPairBalances.sol";
import "../structures/IPoint.sol";
import "../structures/IOracleOptions.sol";

// This is just for test purposes, this is not a real contract!
contract TestNewDexPair is
    ITokenOperationStructure,
    IFeeParams,
    IPairBalances,
    IPoint,
    IOracleOptions
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
    // Wallets
    address public lp_wallet;
    address public left_wallet;
    address public right_wallet;
    // Vault wallets
    address public vault_left_wallet;
    address public vault_right_wallet;
    // Liquidity tokens
    address public lp_root;
    uint128 public lp_supply;
    // Balances
    uint128 public left_balance;
    uint128 public right_balance;
    // Fee
    FeeParams fee;

    // v2
    uint64 _nonce;
    mapping(uint64 => TokenOperation) _tmp_operations;
    mapping(uint64 => address) _tmp_send_gas_to;
    mapping(uint64 => address) _tmp_expected_callback_sender;
    mapping(uint64 => uint256) _tmp_sender_public_key;
    mapping(uint64 => address) _tmp_sender_address;

    // Oracle
    mapping(uint32 => Point) private _points;
    OracleOptions private _options;
    uint16 private _length;

    string newTestField;

    constructor() public {revert();}

    function getRoot() external view responsible returns (address dex_root) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } root;
    }

    function getTokenRoots() external view responsible returns (address left, address right, address lp) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } (left_root, right_root, lp_root);
    }

    function getTokenWallets() external view responsible returns (address left, address right, address lp) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } (left_wallet, right_wallet, lp_wallet);
    }

    function getVersion() external view responsible returns (uint32 version) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } current_version;
    }

    function getPoolType() external pure responsible returns (uint8) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } PoolTypes.CONSTANT_PRODUCT;
    }

    function getFeeParams() external view responsible returns (FeeParams) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } fee;
    }

    function isActive() external view responsible returns (bool) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } active;
    }

    function getBalances() external view responsible returns (PairBalances) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } PairBalances(
            lp_supply,
            left_balance,
            right_balance
        );
    }

    function getPoint(uint32 _timestamp) external view responsible returns (Point) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _points[_timestamp];
    }

    function getCardinality() external view responsible returns (uint16) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _options.cardinality;
    }

    function getLength() external view responsible returns (uint16) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _length;
    }

    function getMinInterval() external view responsible returns (uint8) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } _options.minInterval;
    }

    function getMinRateDelta() external view responsible returns (uint) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } FixedPoint128.encodeFromNumeratorAndDenominator(
            _options.minRateDeltaNumerator,
            _options.minRateDeltaDenominator
        );
    }

    function isInitialized() external view responsible returns (bool) {
        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } !_points.empty();
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

        TvmCell otherDataCell = s.loadRef();    // ref 2

        mapping(uint8 => uint128[]) type_to_reserves;
        mapping(uint8 => address[]) type_to_root_addresses;
        mapping(uint8 => address[]) type_to_wallet_addresses;

        (
            fee,
            type_to_reserves,
            type_to_root_addresses,
            type_to_wallet_addresses
        ) = abi.decode(otherDataCell, (
            FeeParams,
            mapping(uint8 => uint128[]),
            mapping(uint8 => address[]),
            mapping(uint8 => address[])
        ));

        lp_root = type_to_root_addresses[AddressType.LP][0];
        lp_wallet = type_to_wallet_addresses[AddressType.LP][0];
        lp_supply = type_to_reserves[ReserveType.LP][0];

        left_root = type_to_root_addresses[AddressType.RESERVE][0];
        right_root = type_to_root_addresses[AddressType.RESERVE][1];

        left_wallet = type_to_wallet_addresses[AddressType.RESERVE][0];
        right_wallet = type_to_wallet_addresses[AddressType.RESERVE][1];

        left_balance = type_to_reserves[ReserveType.POOL][0];
        right_balance = type_to_reserves[ReserveType.POOL][1];

        TvmSlice oracleDataSlice = s.loadRefAsSlice();  // ref 4

        (
            _points,
            _options,
            _length
        ) = oracleDataSlice.decode(
            mapping(uint32 => Point),
            OracleOptions,
            uint16
        );

        newTestField = "New Pair";

        send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED });
    }

    function newFunc() public view returns (string) {
        return newTestField;
    }
}
