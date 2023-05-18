pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../libraries/Errors.sol";
import "../libraries/Constants.sol";
import "../libraries/MsgFlag.sol";

import "../structures/IReferralProgramParams.sol";

// This is just for test purposes, this is not a real contract!
contract NewDexVault is IReferralProgramParams{
    uint32 private static _nonce;

    TvmCell public platform_code;

    address private _root;
    address private _owner;
    address private _pendingOwner;
    address private _manager;

    // referral program
    ReferralProgramParams _refProgramParams;

    string newTestField;

    constructor() public {revert();}

    function getOwner() external view responsible returns (address) {
        return {
        value: 0,
        bounce: false,
        flag: MsgFlag.REMAINING_GAS
        } _owner;
    }

    function getPendingOwner() external view responsible returns (address) {
        return {
        value: 0,
        bounce: false,
        flag: MsgFlag.REMAINING_GAS
        } _pendingOwner;
    }

    function getManager() external view responsible returns (address) {
        return {
        value: 0,
        bounce: false,
        flag: MsgFlag.REMAINING_GAS
        } _manager;
    }

    function getRoot() external view responsible returns (address) {
        return {
        value: 0,
        bounce: false,
        flag: MsgFlag.REMAINING_GAS
        } _root;
    }

    function getReferralProgramParams() external view responsible returns (ReferralProgramParams) {
        return {
        value: 0,
        bounce: false,
        flag: MsgFlag.REMAINING_GAS
        } _refProgramParams;
    }
    function onCodeUpgrade(TvmCell _data) private {
        tvm.resetStorage();

        TvmSlice slice = _data.toSlice();

        (_root) = slice.decode(address);

        TvmCell ownersData = slice.loadRef();
        TvmSlice ownersSlice = ownersData.toSlice();
        (_owner, _pendingOwner, _manager) = ownersSlice.decode(address, address, address);

        platform_code = slice.loadRef();

        if (slice.refs() >= 1) {
            _refProgramParams  = abi.decode(slice.loadRef(), ReferralProgramParams);
        }

        newTestField = "New Vault";

        // Refund remaining gas
        _owner.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function newFunc() public view returns (string) {
        return newTestField;
    }
}
