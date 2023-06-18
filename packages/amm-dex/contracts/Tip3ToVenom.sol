pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "./libraries/VenomToTip3Gas.sol";
import "./libraries/VenomToTip3Errors.sol";
import "./libraries/OperationTypes.sol";
import "./libraries/VenomToTip3OperationStatus.sol";
import "./libraries/OperationStatus.sol";
import "./libraries/PairPayload.sol";

import "./interfaces/IVenomTip3SwapEvents.sol";
import "./interfaces/IVenomTip3SwapCallbacks.sol";

import "./structures/IExchangeStepStructure.sol";

import "./libraries/MsgFlag.sol";
import "tip3/contracts/interfaces/ITokenRoot.sol";
import "tip3/contracts/interfaces/ITokenWallet.sol";
import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.sol";
import "tip3/contracts/interfaces/IAcceptTokensBurnCallback.sol";

contract Tip3ToVenom is IAcceptTokensTransferCallback, IAcceptTokensBurnCallback, IVenomTip3SwapEvents {

    uint32 static randomNonce_;

    address static public wvenomRoot;
    address static public wvenomVault;

    address public wvenomWallet;

    constructor() public {
        tvm.accept();

        tvm.rawReserve(VenomToTip3Gas.TARGET_BALANCE, 0);

        ITokenRoot(wvenomRoot).deployWallet{
            value: VenomToTip3Gas.DEPLOY_EMPTY_WALLET_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES,
            callback: Tip3ToVenom.onWvenomWallet
        }(
            address(this),
            VenomToTip3Gas.DEPLOY_EMPTY_WALLET_GRAMS
        );

        msg.sender.transfer(0, false, MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS);
    }

    // Сallback deploy WVENOM wallet for contract
    function onWvenomWallet(address _wvenomWallet) external {
        require(msg.sender.value != 0 && msg.sender == wvenomRoot, VenomToTip3Errors.NOT_WVENOM_ROOT);
        wvenomWallet = _wvenomWallet;
        wvenomWallet.transfer(0, false, MsgFlag.REMAINING_GAS + MsgFlag.IGNORE_ERRORS);
    }

    // Payload constructor swap TIP-3 -> Venom
    function buildExchangePayload(
        address pair,
        uint64 id,
        uint128 expectedAmount,
        address referrer,
        optional(address) outcoming
    ) public pure returns (TvmCell) {
        TvmBuilder builder;

        TvmBuilder successPayload;
        successPayload.store(VenomToTip3OperationStatus.SUCCESS);
        successPayload.store(id);

        TvmBuilder cancelPayload;
        cancelPayload.store(VenomToTip3OperationStatus.CANCEL);
        cancelPayload.store(id);
        cancelPayload.store(uint128(0));

        TvmCell pairPayload = PairPayload.buildExchangePayloadV2(
            id,
            0, // deployWalletGrams
            expectedAmount,
            address(0), // recipient
            outcoming.hasValue() ? outcoming.get() : address(0),
            referrer,
            successPayload.toCell(),
            cancelPayload.toCell()
        );

        builder.store(VenomToTip3OperationStatus.SWAP);
        builder.store(pair);
        builder.store(pairPayload);
        return builder.toCell();
    }

    struct Tip3ToVenomExchangeStep {
        uint128 amount;
        address pool;
        address outcoming;
        uint128 numerator;
        uint32[] nextStepIndices;
    }

    // Payload constructor swap TIP-3 -> Venom via split-cross-pool
    function buildCrossPairExchangePayload(
        address pool,
        uint64 id,
        uint128 deployWalletValue,
        uint128 expectedAmount,
        address outcoming,
        uint32[] nextStepIndices,
        Tip3ToVenomExchangeStep[] steps,
        address referrer
    ) public pure returns (TvmCell) {
        require(steps.length > 0);

        TvmBuilder builder;

        TvmBuilder successPayload;
        successPayload.store(VenomToTip3OperationStatus.SUCCESS);
        successPayload.store(id);

        TvmBuilder cancelPayload;
        cancelPayload.store(VenomToTip3OperationStatus.CANCEL);
        cancelPayload.store(id);
        cancelPayload.store(deployWalletValue);

        IExchangeStepStructure.ExchangeStep[] exchangeSteps;
        address[] pools;
        for (uint32 i = 0; i < steps.length; i++) {
            pools.push(steps[i].pool);
            exchangeSteps.push(IExchangeStepStructure.ExchangeStep(steps[i].amount, new address[](0), steps[i].outcoming, steps[i].numerator, steps[i].nextStepIndices));
        }

        TvmCell pairPayload = PairPayload.buildCrossPairExchangePayloadV2(
            id,
            deployWalletValue,
            address(0), // recipient
            expectedAmount,
            outcoming,
            nextStepIndices,
            exchangeSteps,
            pools,
            referrer,
            successPayload.toCell(),
            cancelPayload.toCell()
        );

        builder.store(VenomToTip3OperationStatus.SWAP);
        builder.store(pool);
        builder.store(pairPayload);

        return builder.toCell();
    }

    // Callback result swap
    function onAcceptTokensTransfer(
        address tokenRoot,
        uint128 amount,
        address sender,
        address /*senderWallet*/,
        address user,
        TvmCell payload
    ) override external {
        require(msg.sender.value != 0);
        tvm.rawReserve(VenomToTip3Gas.TARGET_BALANCE, 0);

        bool needCancel = false;
        TvmSlice payloadSlice = payload.toSlice();

        uint8 operationStatus = VenomToTip3OperationStatus.UNKNOWN;

        if (payloadSlice.bits() >= 8) {
            operationStatus = payloadSlice.decode(uint8);
        }

        if (
            payloadSlice.bits() == 267 && payloadSlice.refs() == 1 &&
            operationStatus == VenomToTip3OperationStatus.SWAP &&
            msg.value >= VenomToTip3Gas.SWAP_TIP3_TO_VENOM_MIN_VALUE
        ) {
            address pair = payloadSlice.decode(address);
            TvmCell ref1 = payloadSlice.loadRef();

            ITokenWallet(msg.sender).transfer{value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false}(
                amount,
                pair,
                uint128(0),
                user,
                true,
                ref1
            );
        } else if (operationStatus == OperationStatus.SUCCESS || operationStatus == OperationStatus.CANCEL) {

            TvmSlice venomToTip3PayloadSlice;
            if (payloadSlice.refs() >= 1) {
                venomToTip3PayloadSlice = payloadSlice.loadRefAsSlice();
            }

            uint8 venomToTip3OperationStatus;
            if (venomToTip3PayloadSlice.bits() >= 8) {
                venomToTip3OperationStatus = venomToTip3PayloadSlice.decode(uint8);
            }

            if (
                venomToTip3PayloadSlice.bits() == 192 &&
                venomToTip3OperationStatus == VenomToTip3OperationStatus.CANCEL
            ) {
                (uint64 id_, uint128 deployWalletValue_) = venomToTip3PayloadSlice.decode(uint64, uint128);
                TvmBuilder payloadID;
                payloadID.store(id_);

                emit SwapTip3VenomCancelTransfer(user, id_, amount, tokenRoot);
                IVenomTip3SwapCallbacks(user).onSwapTip3ToVenomCancel{
                    value: VenomToTip3Gas.OPERATION_CALLBACK_BASE,
                    flag: MsgFlag.SENDER_PAYS_FEES,
                    bounce: false
                }(id_, amount, tokenRoot);

                ITokenWallet(msg.sender).transfer{value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false}(
                    amount,
                    user,
                    deployWalletValue_,
                    user,
                    true,
                    payloadID.toCell()
                );
            } else if (
                venomToTip3PayloadSlice.bits() == 64 &&
                venomToTip3OperationStatus == VenomToTip3OperationStatus.SUCCESS &&
                (msg.sender.value != 0 && msg.sender == wvenomWallet)
            ) {
                uint64 id_ = venomToTip3PayloadSlice.decode(uint64);
                TvmBuilder payloadID;
                payloadID.store(id_);

                ITokenWallet(wvenomWallet).transfer{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false }(
                    amount,
                    wvenomVault,
                    uint128(0),
                    user,
                    true,
                    payloadID.toCell()
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

    // Callback Burn token if result swap success
    function onAcceptTokensBurn(
        uint128 amount,
        address /*walletOwner*/,
        address /*wallet*/,
        address user,
        TvmCell payload
    ) override external {
        require(msg.sender.value != 0 && msg.sender == wvenomRoot, VenomToTip3Errors.NOT_WVENOM_ROOT);
        tvm.rawReserve(VenomToTip3Gas.TARGET_BALANCE, 0);

        TvmSlice payloadSlice =  payload.toSlice();
        uint64 id = payloadSlice.decode(uint64);

        emit SwapTip3VenomSuccessTransfer(user, id, amount);
        IVenomTip3SwapCallbacks(user).onSwapTip3ToVenomSuccess{ value: VenomToTip3Gas.OPERATION_CALLBACK_BASE, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false }(id, amount);
    }

    fallback() external pure {  }

}
