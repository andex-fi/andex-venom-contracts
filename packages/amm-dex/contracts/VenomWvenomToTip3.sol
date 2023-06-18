pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "./libraries/VenomToTip3Gas.sol";
import "./libraries/VenomToTip3Errors.sol";
import "./libraries/VenomToTip3Payloads.sol";

import "./interfaces/IVenomVault.sol";
import "./structures/INextExchangeData.sol";

import "./libraries/MsgFlag.sol";
import "tip3/contracts/interfaces/ITokenRoot.sol";
import "tip3/contracts/interfaces/ITokenWallet.sol";
import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.sol";
import "tip3/contracts/interfaces/IAcceptTokensBurnCallback.sol";

contract VenomWvenomToTip3 is IAcceptTokensTransferCallback, IAcceptTokensBurnCallback {

    uint32 static randomNonce_;

    address static public wvenomRoot;
    address static public wvenomVault;
    address static public venomToTip3;

    address public wvenomWallet;

    constructor() public {
        tvm.accept();

        tvm.rawReserve(VenomToTip3Gas.TARGET_BALANCE, 0);

        ITokenRoot(wvenomRoot).deployWallet{
            value: VenomToTip3Gas.DEPLOY_EMPTY_WALLET_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES,
            callback: VenomWvenomToTip3.onWvenomWallet
        }(
            address(this),
            VenomToTip3Gas.DEPLOY_EMPTY_WALLET_GRAMS
        );

        msg.sender.transfer(0, false, MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS);
    }

    // Callback deploy WVENOM wallet for contract
    function onWvenomWallet(address _wvenomWallet) external {
        require(msg.sender.value != 0 && msg.sender == wvenomRoot, VenomToTip3Errors.NOT_WVENOM_ROOT);
        wvenomWallet = _wvenomWallet;
        wvenomWallet.transfer(0, false, MsgFlag.REMAINING_GAS + MsgFlag.IGNORE_ERRORS);
    }

    // Payload constructor swap Venom -> Tip-3
    function buildExchangePayload(
        address pair,
        uint64 id,
        uint128 deployWalletValue,
        uint128 expectedAmount,
        uint128 amount,
        address referrer,
        optional(address) outcoming
    ) external pure returns (TvmCell) {
        return VenomToTip3Payloads.buildExchangePayload(
            pair,
            id,
            deployWalletValue,
            expectedAmount,
            amount,
            referrer,
            outcoming.hasValue() ? outcoming.get() : address(0)
        );
    }

    // Payload constructor swap Venom -> Tip-3 via split-cross-pool
    function buildCrossPairExchangePayload(
        address pool,
        uint64 id,
        uint128 deployWalletValue,
        uint128 expectedAmount,
        address outcoming,
        uint32[] nextStepIndices,
        VenomToTip3Payloads.VenomToTip3ExchangeStep[] steps,
        uint128 amount,
        address referrer
    ) external pure returns (TvmCell) {
        return VenomToTip3Payloads.buildCrossPairExchangePayload(
            pool,
            id,
            deployWalletValue,
            expectedAmount,
            outcoming,
            nextStepIndices,
            steps,
            amount,
            referrer
        );
    }

     //Callback
    function onAcceptTokensTransfer(
        address /*tokenRoot*/,
        uint128 amount,
        address sender,
        address /*senderWallet*/,
        address user,
        TvmCell payload
    )
        override
        external
    {
        require(msg.sender.value != 0);

        bool needCancel = false;
        TvmSlice payloadSlice = payload.toSlice();
        tvm.rawReserve(VenomToTip3Gas.TARGET_BALANCE, 0);
        if (payloadSlice.bits() == 395 && msg.sender == wvenomWallet) {
            (, uint128 amount_) = payloadSlice.decode(address, uint128);
            if ((amount + msg.value - VenomToTip3Gas.SWAP_VENOM_TO_TIP3_MIN_VALUE) >= amount_) {
                ITokenWallet(msg.sender).transfer{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false }(
                    amount,
                    wvenomVault,
                    0,
                    user,
                    true,
                    payload
                );
            } else {
                needCancel = true;
            }
        } else {
            needCancel = true;
        }

        if (needCancel) {
            TvmCell emptyPayload;
            ITokenWallet(msg.sender).transfer{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false }(
                amount,
                user,
                sender != user ? 0.1 ever : 0,
                user,
                true,
                emptyPayload
            );
        }
    }

    // Callback Burn token
    function onAcceptTokensBurn(
        uint128 /*amount*/,
        address /*walletOwner*/,
        address /*wallet*/,
        address user,
        TvmCell payload
    )
        override
        external
    {
        require(msg.sender.value != 0 && msg.sender == wvenomRoot, VenomToTip3Errors.NOT_WVENOM_ROOT);
        tvm.rawReserve(VenomToTip3Gas.TARGET_BALANCE, 0);

        TvmSlice payloadSlice =  payload.toSlice();
        (, uint128 amount_) = payloadSlice.decode(address, uint128);

        IVenomVault(wvenomVault).wrap{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false }(
            amount_,
            venomToTip3,
            user,
            payload
        );
    }
}
