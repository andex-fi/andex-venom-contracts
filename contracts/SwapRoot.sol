pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "./libraries/Types.sol";
import "./libraries/Errors.sol";
import "./libraries/Constants.sol";

import "./SwapPlatform.sol";
import "./interfaces/IUpgradable.sol";
import "./interfaces/IUpgradableByRequest.sol";
import "./interfaces/IAfterInitialize.sol";
import "./interfaces/ISwapRoot.sol";
import "./interfaces/IResetGas.sol";

contract SwapRoot is ISwapRoot, IResetGas, IUpgradable {

    uint32 static _nonce;

    TvmCell platform_code;
    bool has_platform_code;
    TvmCell account_code;
    uint32 account_version;
    TvmCell pair_code;
    uint32 pair_version;

    bool active;

    address owner;
    address vault;
    address pending_owner;

    constructor(address initial_owner, address initial_vault) public {
        tvm.accept();
        owner = initial_owner;
        vault = initial_vault;
    }

    // Install

    function installPlatformOnce(TvmCell code) external onlyOwner {
        // can be installed only once
        require(!has_platform_code, Errors.PLATFORM_CODE_NON_EMPTY);
        tvm.rawReserve(Constants.ROOT_INITIAL_BALANCE, 2);
        platform_code = code;
        owner.transfer({ value: 0, flag: 128 });
    }

    function installOrUpdateAccountCode(TvmCell code) external onlyOwner {
        tvm.rawReserve(Constants.ROOT_INITIAL_BALANCE, 2);
        account_code = code;
        account_version++;
        owner.transfer({ value: 0, flag: 128 });
    }

    function installOrUpdatePairCode(TvmCell code) external onlyOwner {
        tvm.rawReserve(Constants.ROOT_INITIAL_BALANCE, 2);
        pair_code = code;
        pair_version++;
        owner.transfer({ value: 0, flag: 128 });
    }

    function getAccountVersion() external view responsible returns (uint32) {
        return{ value: 0, bounce: false, flag: 64 } account_version;
    }

    function getPairVersion() external view responsible returns (uint32) {
        return{ value: 0, bounce: false, flag: 64 } pair_version;
    }

    // Vault

    function setVault(address new_vault) external onlyOwner {
        tvm.rawReserve(Constants.ROOT_INITIAL_BALANCE, 2);
        vault = new_vault;
        owner.transfer({ value: 0, flag: 128 });
    }

    function getVault() external view responsible returns (address) {
        return{ value: 0, bounce: false, flag: 64 } vault;
    }

    modifier onlyVault() {
        require(msg.sender == vault, Errors.NOT_VAULT);
        _;
    }

    // Active

    function setActive(bool new_active) external onlyOwner {
        tvm.rawReserve(Constants.ROOT_INITIAL_BALANCE, 2);
        if (new_active && has_platform_code && vault.value != 0 && account_version > 0 && pair_version > 0) {
            active = true;
        } else {
            active = false;
        }
        owner.transfer({ value: 0, flag: 128 });
    }

    function isActive() external view responsible returns (bool) {
        return{ value: 0, bounce: false, flag: 64 } active;
    }

    modifier onlyActive() {
        require(active, Errors.NOT_ACTIVE);
        _;
    }

    // Upgrade the root contract itself (IUpgradable)

    function upgrade(TvmCell code) override external onlyOwner {

        require(msg.value > gasToValue(Constants.UPGRADE_ACCOUNT_MIN_VALUE, address(this).wid), Errors.VALUE_TOO_LOW);

        tvm.rawReserve(Constants.ROOT_INITIAL_BALANCE, 2);

        active = false;

        TvmBuilder builder;

        builder.store(owner);
        builder.store(vault);

        builder.store(platform_code);
        builder.store(account_code);
        builder.store(pair_code);

        tvm.setcode(code);
        tvm.setCurrentCode(code);

        onCodeUpgrade(builder.toCell());
    }

    function onCodeUpgrade(TvmCell data) private {}

    function requestUpgradeAccount(
        uint32 current_version,
        address send_gas_to,
        address account_owner
    ) override external onlyAccount(account_owner) {
        tvm.rawReserve(math.max(Constants.ROOT_INITIAL_BALANCE, address(this).balance - msg.value), 2);
        if (current_version == account_version || !active) {
            send_gas_to.transfer({ value: 0, flag: 128 });
        } else {
            IUpgradableByRequest(msg.sender).upgrade{ value: 0, flag: 128 }(account_code, account_version, send_gas_to);
        }
    }

    function forceUpgradeAccount(
        address account_owner,
        address send_gas_to
    ) external view onlyOwner {
        require(msg.value >= gasToValue(Constants.UPGRADE_ACCOUNT_MIN_VALUE, address(this).wid), Errors.VALUE_TOO_LOW);
        tvm.rawReserve(math.max(Constants.ROOT_INITIAL_BALANCE, address(this).balance - msg.value), 2);
        IUpgradableByRequest(address(tvm.hash(_buildInitData(
            Types.Account,
            _buildAccountParams(account_owner)
        )))).upgrade{ value: 0, flag: 128 }(account_code, account_version, send_gas_to);
    }

    function upgradePair(
        address left_root,
        address right_root,
        address send_gas_to
    ) external view onlyOwner {
        require(msg.value >= gasToValue(Constants.UPGRADE_PAIR_MIN_VALUE, address(this).wid), Errors.VALUE_TOO_LOW);
        tvm.rawReserve(math.max(Constants.ROOT_INITIAL_BALANCE, address(this).balance - msg.value), 2);
        IUpgradableByRequest(address(tvm.hash(_buildInitData(
            Types.Pair,
            _buildPairParams(left_root, right_root)
        ))))
        .upgrade{ value: 0, flag: 128 }(pair_code, pair_version, send_gas_to);
    }

    // Reset balance to ROOT_INITIAL_BALANCE
    function resetGas(address receiver) override external view onlyOwner {
        tvm.rawReserve(Constants.ROOT_INITIAL_BALANCE, 2);
        receiver.transfer({ value: 0, flag: 128 });
    }

    function resetTargetGas(address target, address receiver) external view onlyOwner {
        tvm.rawReserve(math.max(Constants.ROOT_INITIAL_BALANCE, address(this).balance - msg.value), 2);
        IResetGas(target).resetGas{ value: 0, flag: 128 }(receiver);
    }

    // Owner

    modifier onlyOwner() {
        require(msg.sender == owner, Errors.NOT_MY_OWNER);
        _;
    }

    function transferOwner(address new_owner) external onlyOwner {
        pending_owner = new_owner;
    }

    function acceptOwner() external {
        require(msg.sender == pending_owner, Errors.NOT_PENDING_OWNER);
        owner = pending_owner;
        pending_owner = address.makeAddrStd(0, 0);
    }

    // Expected address functions

    modifier onlyPlatform(uint8 type_id, TvmCell params) {
        address expected = address(tvm.hash(_buildInitData(type_id, params)));
        require(msg.sender == expected, Errors.NOT_PLATFORM);
        _;
    }

    modifier onlyAccount(address account_owner) {
        address expected = address(tvm.hash(_buildInitData(
            Types.Account,
            _buildAccountParams(account_owner)
        )));
        require(msg.sender == expected, Errors.NOT_ACCOUNT);
        _;
    }

    modifier onlyPair(address left_root, address right_root) {
        address expected = address(tvm.hash(_buildInitData(
            Types.Pair,
            _buildPairParams(left_root, right_root)
        )));
        require(msg.sender == expected, Errors.NOT_PAIR);
        _;
    }

    function getExpectedAccountAddress(address account_owner) external view responsible returns (address) {
        return { value: 0, bounce: false, flag: 64 } address(tvm.hash(_buildInitData(
            Types.Account,
            _buildAccountParams(account_owner)
        )));
    }

    function getExpectedPairAddress(address left_root, address right_root) external view responsible returns (address) {
        return { value: 0, bounce: false, flag: 64 } address(tvm.hash(_buildInitData(
            Types.Pair,
            _buildPairParams(left_root, right_root)
        )));
    }

    function _buildAccountParams(address account_owner) private inline pure returns (TvmCell) {
        TvmBuilder builder;
        builder.store(account_owner);
        return builder.toCell();
    }

    function _buildPairParams(address left_root, address right_root) private inline pure returns (TvmCell) {
        TvmBuilder builder;
        if (left_root.value > right_root.value) {
            builder.store(left_root);
            builder.store(right_root);
        } else {
            builder.store(right_root);
            builder.store(left_root);
        }
        return builder.toCell();
    }

    function _buildInitData(uint8 type_id, TvmCell params) private inline view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: SwapPlatform,
            varInit: {
                root: address(this),
                type_id: type_id,
                params: params
            },
            pubkey: 0,
            code: platform_code
        });
    }

    // Deploy child contracts

    function deployAccount(address account_owner, address send_gas_to) external view onlyActive {
        require(msg.value >= gasToValue(Constants.DEPLOY_ACCOUNT_MIN_VALUE, address(this).wid), Errors.VALUE_TOO_LOW);
        require(account_owner.value != 0, Errors.INVALID_ADDRESS);

        tvm.rawReserve(math.max(Constants.ROOT_INITIAL_BALANCE, address(this).balance - msg.value), 2);

        SwapPlatform platform = new SwapPlatform{
            stateInit: _buildInitData(Types.Account, _buildAccountParams(account_owner)),
            value: gasToValue(Constants.PLATFORM_DEPLOY_VALUE, address(this).wid),
            flag: 1
        }();
        platform.setPlatformCode{value: gasToValue(Constants.SET_PLATFORM_CODE_VALUE, address(this).wid), flag: 1}(platform_code);
        platform.initialize{value: gasToValue(Constants.ACCOUNT_INITIALIZE_VALUE, address(this).wid), flag: 1 }(
            account_code,
            account_version,
            vault,
            send_gas_to
        );
        send_gas_to.transfer({ value: 0, flag: 128 });
    }

    function deployPair(address left_root, address right_root, address send_gas_to) external view onlyActive {
        require(msg.value >= gasToValue(Constants.DEPLOY_PAIR_MIN_VALUE, address(this).wid), Errors.VALUE_TOO_LOW);

        tvm.rawReserve(math.max(Constants.ROOT_INITIAL_BALANCE, address(this).balance - msg.value), 2);

        address platform = new SwapPlatform{
            stateInit: _buildInitData(Types.Pair, _buildPairParams(left_root, right_root)),
            value: gasToValue(Constants.PLATFORM_DEPLOY_VALUE, address(this).wid),
            flag: 1
        }();
        SwapPlatform(platform).setPlatformCode{value: gasToValue(Constants.SET_PLATFORM_CODE_VALUE, address(this).wid), flag: 1}(platform_code);
        SwapPlatform(platform).initialize{value: gasToValue(Constants.PAIR_INITIALIZE_VALUE, address(this).wid), flag: 1 }(
            pair_code,
            pair_version,
            vault,
            send_gas_to
        );
        IAfterInitialize(platform).afterInitialize{ value: 0, flag: 128 }(send_gas_to);
    }

}
