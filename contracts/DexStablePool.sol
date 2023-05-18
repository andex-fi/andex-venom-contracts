pragma ton -solidity >= 0.57.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "tip3/contracts/interfaces/ITokenRoot.sol";
import "tip3/contracts/interfaces/ITokenWallet.sol";
import "tip3/contracts/interfaces/IBurnableByRootTokenRoot.sol";
import "tip3/contracts/interfaces/IBurnableTokenWallet.sol";
import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.sol";

import "./libraries/DexPlatformTypes.sol";
import "./libraries/DexPoolTypes.sol";
import "./libraries/DexErrors.sol";
import "./libraries/DexGas.sol";
import "./libraries/DexAddressType.sol";
import "./libraries/DexReserveType.sol";
import "./libraries/MsgFlag.sol";
import "./libraries/DexOperationTypes.sol";
import "./libraries/PairPayload.sol";
import "./libraries/DirectOperationErrors.sol";

import "./interfaces/IUpgradableByRequest.sol";
import "./interfaces/IDexRoot.sol";
import "./interfaces/IDexBasePool.sol";
import "./interfaces/ISuccessCallback.sol";
import "./interfaces/IDexAccount.sol";
import "./interfaces/IDexTokenVault.sol";
import "./interfaces/IDexStablePool.sol";
import "./interfaces/IDexPairOperationCallback.sol";

import "./structures/IExchangeResultV2.sol";
import "./structures/IWithdrawResultV2.sol";
import "./structures/ITokenOperationStructure.sol";
import "./structures/IDepositLiquidityResultV2.sol";
import "./structures/IDexPoolBalances.sol";
import "./structures/IPoolTokenData.sol";
import "./structures/INextExchangeData.sol";

import "./abstract/DexContractBase.sol";
import "./DexPlatform.sol";
import "./TokenFactory.sol";

contract DexStablePool is
    DexContractBase,
    IDexStablePool,
    IPoolTokenData,
    INextExchangeData
{
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Data

    // Base:
    address root;
    address vault;


    // Custom:
    bool active;
    uint32 current_version;

    // Token data
    PoolTokenData[] tokenData;
    mapping(address => uint8) tokenIndex;
    uint256 PRECISION;
    uint8 MAX_DECIMALS;

    // Liquidity tokens
    address lp_root;
    address lp_wallet;
    uint128 lp_supply;

    // Fee
    FeeParams fee;

    AmplificationCoefficient A;
    uint8 N_COINS;
    uint8 constant LP_DECIMALS = 9;

    // ####################################################


    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Base functions

    // Cant be deployed directly
    constructor() public { revert(); }

    function _dexRoot() override internal view returns(address) {
        return root;
    }

    // Prevent manual transfers
    receive() external pure {
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);
        msg.sender.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    // Prevent undefined functions call, need for bounce future Account/Root functions calls, when not upgraded
    fallback() external pure { revert();  }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Getters

    function getRoot() override external view responsible returns (address dex_root) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } root;
    }

    function getTokenRoots() override external view responsible returns (address[] roots, address lp) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } (_tokenRoots(), lp_root);
    }

    function getTokenWallets() override external view responsible returns (address[] token_wallets, address lp) {
        address[] w = new address[](0);
        for (uint8 i = 0; i < N_COINS; i++) {
            w.push(tokenData[i].wallet);
        }

        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } (w, lp_wallet);
    }

    function getVersion() override external view responsible returns (uint32 version) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } current_version;
    }

    function getVault() override external view responsible returns (address) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } vault;
    }

    function getPoolType() override external view responsible returns (uint8) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } DexPoolTypes.STABLE_POOL;
    }

    function getAccumulatedFees() override external view responsible returns (uint128[] accumulatedFees) {
        uint128[] _accumulatedFees = new uint128[](0);

        for (uint8 i = 0; i < N_COINS; i++) {
            _accumulatedFees.push(tokenData[i].accumulatedFee);
        }

        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } _accumulatedFees;
    }

    function getFeeParams() override external view responsible returns (FeeParams) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } fee;
    }

    function getAmplificationCoefficient() override external view responsible returns (AmplificationCoefficient) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } A;
    }

    function isActive() override external view responsible returns (bool) {
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } active;
    }

    function getBalances() override external view responsible returns (DexPoolBalances) {
        uint128[] balances = new uint128[](0);
        for (uint8 i = 0; i < N_COINS; i++) {
            balances.push(tokenData[i].balance);
        }
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } DexPoolBalances(
            balances,
            lp_supply
        );
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Setters

    function setActive(
        bool _newActive,
        address _remainingGasTo
    ) external override onlyRoot {
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        if (_newActive) {
            _tryToActivate();
        } else {
            active = false;
        }

        _remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED,
            bounce: false
        });
    }

    function setAmplificationCoefficient(AmplificationCoefficient _A, address send_gas_to) override external onlyRoot {
        require(msg.value >= DexGas.SET_FEE_PARAMS_MIN_VALUE, DexErrors.VALUE_TOO_LOW);
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        A = _A;

        emit AmplificationCoefficientUpdated(A);

        send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false });

    }

    function setFeeParams(FeeParams params, address send_gas_to) override external onlyRoot {
        require(params.denominator != 0 &&
        (params.pool_numerator + params.beneficiary_numerator) < params.denominator &&
            ((params.beneficiary.value != 0 && params.beneficiary_numerator != 0) ||
            (params.beneficiary.value == 0 && params.beneficiary_numerator == 0)),
            DexErrors.WRONG_FEE_PARAMS);
        require(msg.value >= DexGas.SET_FEE_PARAMS_MIN_VALUE, DexErrors.VALUE_TOO_LOW);
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        if (fee.beneficiary.value != 0) {
            _processBeneficiaryFees(true, send_gas_to);
        }

        fee = params;
        emit FeesParamsUpdated(fee);

        send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false });

    }

    function withdrawBeneficiaryFee(address send_gas_to) external {
        require(fee.beneficiary.value != 0 && msg.sender == fee.beneficiary, DexErrors.NOT_BENEFICIARY);
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);
        _processBeneficiaryFees(true, send_gas_to);
        send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS, bounce: false });
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Direct operations

    function buildExchangePayload(
        uint64 id,
        uint128 deploy_wallet_grams,
        uint128 expected_amount,
        address outcoming,
        address recipient,
        address referrer,
        optional(TvmCell) success_payload,
        optional(TvmCell) cancel_payload
    )  external pure returns (TvmCell) {
        return PairPayload.buildExchangePayloadV2(
            id,
            deploy_wallet_grams,
            expected_amount,
            recipient,
            outcoming,
            referrer,
            success_payload,
            cancel_payload
        );
    }

    function buildDepositLiquidityPayload(
        uint64 id,
        uint128 deploy_wallet_grams,
        uint128 expected_amount,
        address recipient,
        address referrer,
        optional(TvmCell) success_payload,
        optional(TvmCell) cancel_payload
    ) external pure returns (TvmCell) {
        return PairPayload.buildDepositLiquidityPayloadV2(
            id,
            deploy_wallet_grams,
            expected_amount,
            recipient,
            referrer,
            success_payload,
            cancel_payload
        );
    }

    function buildWithdrawLiquidityPayload(
        uint64 id,
        uint128 deploy_wallet_grams,
        uint128[] expected_amounts,
        address recipient,
        address referrer,
        optional(TvmCell) success_payload,
        optional(TvmCell) cancel_payload
    ) external view returns (TvmCell) {
        require(expected_amounts.length == 0 || expected_amounts.length == N_COINS);

        return PairPayload.buildWithdrawLiquidityPayloadV2(
            id,
            deploy_wallet_grams,
            expected_amounts,
            recipient,
            referrer,
            success_payload,
            cancel_payload
        );
    }

    function buildWithdrawLiquidityOneCoinPayload(
        uint64 id,
        uint128 deploy_wallet_grams,
        uint128 expected_amount,
        address outcoming,
        address recipient,
        address referrer,
        optional(TvmCell) success_payload,
        optional(TvmCell) cancel_payload
    ) external pure returns (TvmCell) {
        return PairPayload.buildWithdrawLiquidityOneCoinPayload(
            id,
            deploy_wallet_grams,
            recipient,
            expected_amount,
            outcoming,
            referrer,
            success_payload,
            cancel_payload
        );
    }

    function buildCrossPairExchangePayload(
        uint64 id,
        uint128 deployWalletGrams,
        uint128 expectedAmount,
        address outcoming,
        uint32[] nextStepIndices,
        ExchangeStep[] steps,
        address recipient,
        address referrer,
        optional(TvmCell) success_payload,
        optional(TvmCell) cancel_payload
    ) external view returns (TvmCell) {
        address[] pools;

        // Calculate pools' addresses by token roots
        for (uint32 i = 0; i < steps.length; i++) {
            pools.push(_expectedPoolAddress(steps[i].roots));
        }

        return PairPayload.buildCrossPairExchangePayloadV2(
            id,
            deployWalletGrams,
            recipient,
            expectedAmount,
            outcoming,
            nextStepIndices,
            steps,
            pools,
            referrer,
            success_payload,
            cancel_payload
        );
    }

    function onAcceptTokensTransfer(
        address token_root,
        uint128 tokens_amount,
        address sender_address,
        address sender_wallet,
        address original_gas_to,
        TvmCell payload
    ) override external {
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        // Decode base data from payload
        (
            bool is_payload_valid,
            uint8 op,
            uint64 id,
            uint128 deploy_wallet_grams,
            address recipient,
            uint128[] expected_amounts,
            address outcoming,
            NextExchangeData[] next_steps,
            address referrer
        ) = PairPayload.decodeOnAcceptTokensTransferData(payload);

        uint128 expected_amount = expected_amounts.length == 1 ? expected_amounts[0] : 0;
        if (expected_amounts.length == 0) {
            expected_amounts = new uint128[](N_COINS);
        }

        // Set sender as recipient if it's empty
        recipient = recipient.value == 0 ? sender_address : recipient;

        // Decode payloads for callbacks
        (
            bool notify_success,
            TvmCell success_payload,
            bool notify_cancel,
            TvmCell cancel_payload
        ) = PairPayload.decodeOnAcceptTokensTransferPayloads(payload, op);

        TvmCell empty;
        uint128 referrer_value = referrer.value != 0 ? DexGas.REFERRER_FEE_EXTRA_VALUE : 0;

        uint16 errorCode = _checkOperationData(msg.sender, msg.value, is_payload_valid, deploy_wallet_grams, op, token_root, outcoming, referrer_value);

        if (errorCode == 0) {
            if (op == DexOperationTypes.WITHDRAW_LIQUIDITY_V2) {

                optional(WithdrawResultV2) result_opt = _expectedWithdrawLiquidity(tokens_amount);

                errorCode = _checkWithdrawalReceivedAmounts(result_opt, expected_amounts);
                if (errorCode == 0) {
                    WithdrawResultV2 result = result_opt.get();

                    _applyWithdrawLiquidity(
                        result,
                        new uint128[](N_COINS),
                        id,
                        false,
                        sender_address,
                        recipient,
                        referrer,
                        referrer_value,
                        original_gas_to
                    );

                    for (uint8 ii = 0; ii < N_COINS; ii++) {
                        if (result.amounts[ii] >= 0) {
                            IDexTokenVault(_expectedTokenVaultAddress(tokenData[ii].root)).transfer{
                                value: DexGas.VAULT_TRANSFER_BASE_VALUE_V2 + deploy_wallet_grams,
                                flag: MsgFlag.SENDER_PAYS_FEES
                            }(
                                result.amounts[ii],
                                recipient,
                                deploy_wallet_grams,
                                notify_success,
                                PairPayload.buildSuccessPayload(op, success_payload, sender_address),
                                _tokenRoots(),
                                current_version,
                                original_gas_to
                            );
                        }
                    }

                    IBurnableTokenWallet(msg.sender).burn{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }(
                        tokens_amount,
                        original_gas_to,
                        address.makeAddrStd(0, 0),
                        empty
                    );
                }
            } else if (op == DexOperationTypes.WITHDRAW_LIQUIDITY_ONE_COIN) {

                uint8 i = tokenIndex[outcoming];
                (optional(WithdrawResultV2) result_opt, uint128[] referrer_fees) = _expectedWithdrawLiquidityOneCoin(tokens_amount, i, _reserves(), lp_supply, referrer);

                errorCode = _checkOneCoinWithdrawalReceivedAmount(result_opt, i, expected_amount);
                if (errorCode == 0) {
                    WithdrawResultV2 result = result_opt.get();

                    _applyWithdrawLiquidity(
                        result,
                        referrer_fees,
                        id,
                        false,
                        sender_address,
                        recipient,
                        referrer,
                        referrer_value,
                        original_gas_to
                    );

                    IDexTokenVault(_expectedTokenVaultAddress(tokenData[i].root)).transfer{
                        value: DexGas.VAULT_TRANSFER_BASE_VALUE_V2 + deploy_wallet_grams,
                        flag: MsgFlag.SENDER_PAYS_FEES
                    }(
                        result.amounts[i],
                        recipient,
                        deploy_wallet_grams,
                        notify_success,
                        PairPayload.buildSuccessPayload(op, success_payload, sender_address),
                        _tokenRoots(),
                        current_version,
                        original_gas_to
                    );

                    IBurnableTokenWallet(msg.sender).burn{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }(
                        tokens_amount,
                        original_gas_to,
                        address.makeAddrStd(0, 0),
                        empty);
                }
            } else if (op == DexOperationTypes.EXCHANGE_V2) {

                (optional(ExpectedExchangeResult) dy_result_opt, uint128 referrer_fee) = _get_dy(tokenIndex[token_root], tokenIndex[outcoming], tokens_amount, referrer);

                errorCode = _checkExchangeReceivedAmount(dy_result_opt, expected_amount);
                if (errorCode == 0) {
                    uint8 i = tokenIndex[token_root];
                    uint8 j = tokenIndex[outcoming];

                    ExpectedExchangeResult dy_result = dy_result_opt.get();

                    tokenData[i].balance += tokens_amount - dy_result.beneficiary_fee - referrer_fee;
                    tokenData[j].balance -= dy_result.amount;

                    ExchangeFee[] fees = new ExchangeFee[](0);
                    fees.push(ExchangeFee(
                            tokenData[i].root,
                            dy_result.pool_fee,
                            dy_result.beneficiary_fee,
                            fee.beneficiary
                    ));

                    emit Exchange(
                        sender_address,
                        recipient,
                        tokenData[i].root,
                        tokens_amount,
                        tokenData[j].root,
                        dy_result.amount,
                        fees
                    );

                    if (dy_result.beneficiary_fee > 0) {
                        tokenData[i].accumulatedFee += dy_result.beneficiary_fee;
                        _processBeneficiaryFees(false, original_gas_to);
                    }

                    if (referrer_fee > 0) {
                        IDexTokenVault(_expectedTokenVaultAddress(tokenData[i].root)).referralFeeTransfer{
                            value: referrer_value,
                            flag: 0
                        }(
                            referrer_fee,
                            referrer,
                            original_gas_to,
                            _tokenRoots()
                        );

                        emit ReferrerFees([TokenOperation(referrer_fee, tokenData[i].root)]);
                    }

                    IDexPairOperationCallback(sender_address).dexPairExchangeSuccessV2{
                        value: DexGas.OPERATION_CALLBACK_BASE + 10,
                        flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                        bounce: false
                    }(id, false, IExchangeResultV2.ExchangeResultV2(
                            token_root,
                            outcoming,
                            tokens_amount,
                            dy_result.pool_fee + dy_result.beneficiary_fee + referrer_fee,
                            dy_result.amount
                        ));

                    if (recipient != sender_address) {
                        IDexPairOperationCallback(recipient).dexPairExchangeSuccessV2{
                            value: DexGas.OPERATION_CALLBACK_BASE,
                            flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                            bounce: false
                        }(id, false, IExchangeResultV2.ExchangeResultV2(
                            token_root,
                            outcoming,
                            tokens_amount,
                            dy_result.pool_fee + dy_result.beneficiary_fee + referrer_fee,
                            dy_result.amount
                        ));
                    }

                    ITokenWallet(msg.sender).transfer{
                        value: DexGas.TRANSFER_TOKENS_VALUE,
                        flag: MsgFlag.SENDER_PAYS_FEES
                    }(
                        tokens_amount,
                        _expectedTokenVaultAddress(token_root),
                        0,
                        original_gas_to,
                        false,
                        empty
                    );

                    IDexTokenVault(_expectedTokenVaultAddress(tokenData[j].root)).transfer{
                        value: 0,
                        flag: MsgFlag.ALL_NOT_RESERVED
                    }(
                        dy_result.amount,
                        recipient,
                        deploy_wallet_grams,
                        notify_success,
                        PairPayload.buildSuccessPayload(op, success_payload, sender_address),
                        _tokenRoots(),
                        current_version,
                        original_gas_to
                    );
                }
            } else if (op == DexOperationTypes.CROSS_PAIR_EXCHANGE_V2) {

                if (next_steps.length == 0) errorCode = DirectOperationErrors.INVALID_NEXT_STEPS;

                uint256 denominator = 0;
                uint32 all_nested_nodes = uint32(next_steps.length);
                uint32 all_leaves = 0;
                uint32 max_nested_nodes = 0;
                uint32 max_nested_nodes_idx = 0;
                for (uint32 i = 0; i < next_steps.length; i++) {
                    NextExchangeData next_step = next_steps[i];
                    if (next_step.poolRoot.value == 0 || next_step.poolRoot == address(this) ||
                        next_step.numerator == 0 || next_step.leaves == 0) {

                        errorCode = DirectOperationErrors.INVALID_NEXT_STEPS;
                        break;
                    }
                    if (next_step.nestedNodes > max_nested_nodes) {
                        max_nested_nodes = next_step.nestedNodes;
                        max_nested_nodes_idx = i;
                    }
                    denominator += next_step.numerator;
                    all_nested_nodes += next_step.nestedNodes;
                    all_leaves += next_step.leaves;
                }

                if (errorCode == 0 && msg.value < (DexGas.CROSS_POOL_EXCHANGE_MIN_VALUE + referrer_value) * (1 + all_nested_nodes)) {
                    errorCode = DirectOperationErrors.VALUE_TOO_LOW;
                }

                TokenOperation operation;

                if (errorCode == 0) {
                    if (outcoming == lp_root && token_root != lp_root) { // deposit liquidity

                        (optional(DepositLiquidityResultV2) resultOpt, uint128[] referrer_fees) = _expectedOneCoinDepositLiquidity(tokens_amount, tokenIndex[token_root], _reserves(), lp_supply, referrer);

                        errorCode = _checkDepositReceivedAmount(resultOpt, expected_amount);
                        if (errorCode == 0) {
                            DepositLiquidityResultV2 result = resultOpt.get();
                            _applyAddLiquidity(
                                result,
                                referrer_fees,
                                id,
                                false,
                                sender_address,
                                recipient,
                                referrer,
                                referrer_value,
                                original_gas_to
                            );

                            TvmBuilder builder;

                            TvmCell exchange_data = abi.encode(
                                id,
                                current_version,
                                DexPoolTypes.STABLE_POOL,
                                _tokenRoots(),
                                sender_address,
                                recipient,
                                referrer,
                                deploy_wallet_grams,
                                next_steps
                            );
                            builder.store(exchange_data);

                            builder.store(success_payload);
                            builder.store(cancel_payload);

                            ITokenRoot(lp_root).mint{
                                value: 0,
                                flag: MsgFlag.ALL_NOT_RESERVED
                            }(
                                result.lp_reward,
                                _expectedTokenVaultAddress(lp_root),
                                deploy_wallet_grams,
                                original_gas_to,
                                true,
                                builder.toCell()
                            );
                        }
                    } else if (token_root == lp_root && outcoming != lp_root) { // withdraw liquidity

                        (optional(WithdrawResultV2) result_opt, uint128[] referrer_fees) = _expectedWithdrawLiquidityOneCoin(tokens_amount, tokenIndex[outcoming], _reserves(), lp_supply, referrer);

                        errorCode = _checkOneCoinWithdrawalReceivedAmount(result_opt, tokenIndex[outcoming], expected_amount);
                        if (errorCode == 0) {
                            WithdrawResultV2 result = result_opt.get();
                            uint8 j = tokenIndex[outcoming];

                            _applyWithdrawLiquidity(
                                result,
                                referrer_fees,
                                id,
                                false,
                                sender_address,
                                recipient,
                                referrer,
                                referrer_value,
                                original_gas_to
                            );

                            operation = TokenOperation(result.amounts[j], tokenData[j].root);

                            IBurnableTokenWallet(msg.sender).burn{
                                value: DexGas.BURN_VALUE,
                                flag: MsgFlag.SENDER_PAYS_FEES
                            }(
                                tokens_amount,
                                original_gas_to,
                                address.makeAddrStd(0, 0),
                                empty);
                        }
                    } else { // exchange
                        optional(ExpectedExchangeResult) dy_result_opt;
                        uint128 referrer_fee = 0;

                        if (token_root == outcoming) {
                            errorCode = DirectOperationErrors.WRONG_TOKEN_ROOT;
                        } else {
                            (dy_result_opt, referrer_fee) = _get_dy(tokenIndex[token_root], tokenIndex[outcoming], tokens_amount, referrer);
                            errorCode = _checkExchangeReceivedAmount(dy_result_opt, expected_amount);
                        }

                        if (errorCode == 0) {
                            uint8 i = tokenIndex[token_root];
                            uint8 j = tokenIndex[outcoming];

                            ExpectedExchangeResult dy_result = dy_result_opt.get();
                            operation = TokenOperation(dy_result.amount, tokenData[j].root);

                            tokenData[i].balance += tokens_amount - dy_result.beneficiary_fee - referrer_fee;
                            tokenData[j].balance -= dy_result.amount;

                            ExchangeFee[] fees;
                            fees.push(ExchangeFee(tokenData[i].root, dy_result.pool_fee, dy_result.beneficiary_fee, fee.beneficiary));

                            emit Exchange(
                                sender_address,
                                recipient,
                                tokenData[i].root,
                                tokens_amount,
                                tokenData[j].root,
                                dy_result.amount,
                                fees
                            );

                            if (dy_result.beneficiary_fee > 0) {
                                tokenData[i].accumulatedFee += dy_result.beneficiary_fee;
                                _processBeneficiaryFees(false, original_gas_to);
                            }

                            if (referrer_fee > 0) {
                                IDexTokenVault(_expectedTokenVaultAddress(tokenData[i].root)).referralFeeTransfer{
                                    value: referrer_value,
                                    flag: 0
                                }(
                                    referrer_fee,
                                    referrer,
                                    original_gas_to,
                                    _tokenRoots()
                                );

                                emit ReferrerFees([TokenOperation(referrer_fee, tokenData[i].root)]);
                            }
                        }
                    }
                }

                if (errorCode == 0) {
                    if (token_root != lp_root) { // deposit or exchange
                        ITokenWallet(msg.sender).transfer{
                            value: DexGas.TRANSFER_TOKENS_VALUE,
                            flag: MsgFlag.SENDER_PAYS_FEES
                        }(
                            tokens_amount,
                            _expectedTokenVaultAddress(token_root),
                            0,
                            original_gas_to,
                            false,
                            empty
                        );
                    }

                    if (outcoming != lp_root) { // withdraw or exchange
                        uint128 extraValue = msg.value - (DexGas.CROSS_POOL_EXCHANGE_MIN_VALUE + referrer_value) * (1 + all_nested_nodes);

                        for (uint32 i = 0; i < next_steps.length; i++) {
                            NextExchangeData next_step = next_steps[i];

                            uint128 next_pool_amount = uint128(math.muldiv(operation.amount, next_step.numerator, denominator));
                            uint128 current_extra_value = math.muldiv(uint128(next_step.leaves), extraValue, uint128(all_leaves));

                            IDexBasePool(next_step.poolRoot).crossPoolExchange{
                                value: i == max_nested_nodes_idx ? 0 : (next_step.nestedNodes + 1) * (DexGas.CROSS_POOL_EXCHANGE_MIN_VALUE + referrer_value) + current_extra_value,
                                flag: i == max_nested_nodes_idx ? MsgFlag.ALL_NOT_RESERVED : MsgFlag.SENDER_PAYS_FEES
                            }(
                                id,

                                current_version,
                                DexPoolTypes.STABLE_POOL,

                                _tokenRoots(),

                                op,
                                operation.root,
                                next_pool_amount,

                                sender_address,
                                recipient,
                                referrer,

                                original_gas_to,
                                deploy_wallet_grams,

                                next_step.payload,
                                notify_success,
                                success_payload,
                                notify_cancel,
                                cancel_payload
                            );
                        }
                    }
                }
            } else if (op == DexOperationTypes.DEPOSIT_LIQUIDITY_V2) {

                (optional(DepositLiquidityResultV2) resultOpt, uint128[] referrer_fees) = _expectedOneCoinDepositLiquidity(tokens_amount, tokenIndex[token_root], _reserves(), lp_supply, referrer);

                errorCode = _checkDepositReceivedAmount(resultOpt, expected_amount);
                if (errorCode == 0) {
                    DepositLiquidityResultV2 result = resultOpt.get();
                    _applyAddLiquidity(
                        result,
                        referrer_fees,
                        id,
                        false,
                        sender_address,
                        recipient,
                        referrer,
                        referrer_value,
                        original_gas_to
                    );

                    ITokenWallet(msg.sender).transfer{
                        value: DexGas.TRANSFER_TOKENS_VALUE,
                        flag: MsgFlag.SENDER_PAYS_FEES
                    }(
                        tokens_amount,
                        _expectedTokenVaultAddress(token_root),
                        0,
                        original_gas_to,
                        false,
                        empty
                    );

                    ITokenRoot(lp_root).mint{
                        value: 0,
                        flag: MsgFlag.ALL_NOT_RESERVED
                    }(
                        result.lp_reward,
                        recipient,
                        deploy_wallet_grams,
                        original_gas_to,
                        notify_success,
                        PairPayload.buildSuccessPayload(op, success_payload, sender_address)
                    );
                }
            } else {
                errorCode = DirectOperationErrors.WRONG_OPERATION_TYPE;
            }
        }

        if (errorCode != 0) {
            IDexPairOperationCallback(sender_address).dexPairOperationCancelled{
                value: DexGas.OPERATION_CALLBACK_BASE + 44,
                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                bounce: false
            }(id);

            if (recipient != sender_address) {
                IDexPairOperationCallback(recipient).dexPairOperationCancelled{
                    value: DexGas.OPERATION_CALLBACK_BASE,
                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                    bounce: false
                }(id);
            }

            ITokenWallet(msg.sender).transferToWallet{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }(
                tokens_amount,
                sender_wallet,
                original_gas_to,
                notify_cancel,
                PairPayload.buildCancelPayload(op, errorCode, cancel_payload, next_steps)
            );
        } else {
            _sync();
        }
    }

    function _checkOperationData(
        address msg_sender,
        uint128 msg_value,
        bool is_payload_valid,
        uint128 deploy_wallet_grams,
        uint8 op,
        address token_root,
        address outcoming,
        uint128 referrer_value
    ) private view returns (uint16) {

        if (!active) return DirectOperationErrors.NOT_ACTIVE;
        if (!is_payload_valid) return DirectOperationErrors.INVALID_PAYLOAD;
        if (lp_supply == 0) return DirectOperationErrors.NON_POSITIVE_LP_SUPPLY;
        if (msg_value < DexGas.DIRECT_PAIR_OP_MIN_VALUE_V2 + deploy_wallet_grams + referrer_value) return DirectOperationErrors.VALUE_TOO_LOW;

        if (token_root == lp_root && msg_sender != lp_wallet) return DirectOperationErrors.NOT_LP_TOKEN_WALLET;
        if (token_root != lp_root) {
            if (!tokenIndex.exists(token_root)) return DirectOperationErrors.NOT_TOKEN_ROOT;
            if (msg_sender.value == 0 || msg_sender != tokenData[tokenIndex.at(token_root)].wallet) return DirectOperationErrors.NOT_TOKEN_WALLET;
        }

        if (!(msg_sender == lp_wallet && (op == DexOperationTypes.WITHDRAW_LIQUIDITY_V2 || op == DexOperationTypes.WITHDRAW_LIQUIDITY_ONE_COIN)
            || msg_sender != lp_wallet && (op == DexOperationTypes.DEPOSIT_LIQUIDITY_V2 || op == DexOperationTypes.EXCHANGE_V2)
            || op == DexOperationTypes.CROSS_PAIR_EXCHANGE_V2)) return DirectOperationErrors.WRONG_OPERATION_TYPE;

        if (op == DexOperationTypes.WITHDRAW_LIQUIDITY_V2 && msg_value < DexGas.DIRECT_PAIR_OP_MIN_VALUE_V2 + N_COINS * deploy_wallet_grams + referrer_value) {
            return DirectOperationErrors.VALUE_TOO_LOW;
        }

        if (!tokenIndex.exists(outcoming) && (op == DexOperationTypes.WITHDRAW_LIQUIDITY_ONE_COIN || op == DexOperationTypes.EXCHANGE_V2)
            || (!tokenIndex.exists(outcoming) && outcoming != lp_root && op == DexOperationTypes.CROSS_PAIR_EXCHANGE_V2)) {

            return DirectOperationErrors.NOT_TOKEN_ROOT;
        }

        return 0;
    }

    function _checkExchangeReceivedAmount(optional(ExpectedExchangeResult) dy_result_opt, uint128 expected_amount) private pure returns (uint16) {
        if (!dy_result_opt.hasValue()) return DirectOperationErrors.INVALID_RECEIVED_AMOUNT;
        if (dy_result_opt.get().amount < expected_amount) return DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;

        return 0;
    }

    function _checkDepositReceivedAmount(optional(DepositLiquidityResultV2) result_opt, uint128 expected_amount) private pure returns (uint16) {
        if (!result_opt.hasValue()) return DirectOperationErrors.INVALID_RECEIVED_AMOUNT;
        if (result_opt.get().lp_reward < expected_amount) return DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;

        return 0;
    }

    function _checkOneCoinWithdrawalReceivedAmount(optional(WithdrawResultV2) result_opt, uint8 i, uint128 expected_amount) private pure returns (uint16) {
        if (!result_opt.hasValue()) return DirectOperationErrors.INVALID_RECEIVED_AMOUNT;
        if (result_opt.get().amounts[i] < expected_amount) return DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;

        return 0;
    }

    function _checkWithdrawalReceivedAmounts(optional(WithdrawResultV2) result_opt, uint128[] expected_amounts) private view returns (uint16) {
        if (!result_opt.hasValue()) return DirectOperationErrors.INVALID_RECEIVED_AMOUNT;

        WithdrawResultV2 result = result_opt.get();
        for (uint8 ii = 0; ii < N_COINS; ii++) {
            if (result.amounts[ii] < expected_amounts[ii]) return DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;
        }

        return 0;
}

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Deposit liquidity

    function expectedDepositLiquidityV2(
        uint128[] amounts
    ) override external view responsible returns (DepositLiquidityResultV2) {
        (optional(DepositLiquidityResultV2) resultOpt,) = _expectedDepositLiquidity(amounts, _reserves(), lp_supply, address(0));
        require(resultOpt.hasValue(), DexErrors.WRONG_LIQUIDITY);
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } resultOpt.get();
    }

    function expectedDepositLiquidityOneCoin(
        address spent_token_root,
        uint128 amount
    ) external view responsible returns (DepositLiquidityResultV2) {
        require(tokenIndex.exists(spent_token_root), DexErrors.NOT_TOKEN_ROOT);
        uint8 i = tokenIndex[spent_token_root];

        (optional(DepositLiquidityResultV2) resultOpt,) = _expectedOneCoinDepositLiquidity(amount, i, _reserves(), lp_supply, address(0));
        require(resultOpt.hasValue(), DexErrors.WRONG_LIQUIDITY);
        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } resultOpt.get();
    }

    function depositLiquidity(
        uint64 call_id,
        TokenOperation[] _operations,
        TokenOperation _expected,
        bool    auto_change,
        address account_owner,
        uint32 /*account_version*/,
        address send_gas_to,
        address referrer
    ) override external onlyActive onlyAccount(account_owner) {
        require(_expected.root == lp_root, DexErrors.NOT_LP_TOKEN_ROOT);

        bool isValid = true;
        if (lp_supply == 0) {
            uint256 deposit = math.muldiv(tokenData[tokenIndex[_operations[0].root]].rate, _operations[0].amount, PRECISION);
            for (TokenOperation op: _operations) {
                isValid = isValid && math.muldiv(tokenData[tokenIndex[op.root]].rate, op.amount, PRECISION) == deposit;
            }
            isValid = isValid && deposit != 0;
        }

        bool anyGreaterThanZero = false;
        bool allGreaterThanZero = true;
        for (TokenOperation op: _operations) {
            if (op.amount > 0) {
                anyGreaterThanZero = true;
            } else {
                allGreaterThanZero = false;
            }
        }

        require(isValid, DexErrors.WRONG_LIQUIDITY);
        require(allGreaterThanZero || (auto_change && anyGreaterThanZero), DexErrors.AMOUNT_TOO_LOW);

        uint128[] amounts = new uint128[](N_COINS);
        for (TokenOperation op: _operations) {
            amounts[tokenIndex[op.root]] = op.amount;
        }
        (optional(DepositLiquidityResultV2) resultOpt, uint128[] referrer_fees) = _expectedDepositLiquidity(amounts, _reserves(), lp_supply, referrer);
        require(resultOpt.hasValue(), DexErrors.WRONG_LIQUIDITY);
        DepositLiquidityResultV2 result = resultOpt.get();
        require(result.lp_reward >= _expected.amount, DexErrors.WRONG_LIQUIDITY);

        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        uint128 referrer_value = referrer.value != 0 ? DexGas.REFERRER_FEE_EXTRA_VALUE : 0;

        _applyAddLiquidity(
            result,
            referrer_fees,
            call_id,
            true,
            account_owner,
            account_owner,
            referrer,
            referrer_value,
            send_gas_to
        );

        _sync();

        TvmCell empty;
        ITokenRoot(lp_root)
        .mint{
            value: DexGas.DEPLOY_MINT_VALUE_BASE + DexGas.DEPLOY_EMPTY_WALLET_GRAMS,
            flag: MsgFlag.SENDER_PAYS_FEES
        }(
            result.lp_reward,
            account_owner,
            DexGas.DEPLOY_EMPTY_WALLET_GRAMS,
            send_gas_to,
            send_gas_to == account_owner,
            empty
        );

        ISuccessCallback(msg.sender).successCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }(call_id);
    }

    function expectedDepositSpendAmount(
        uint128 lp_amount,
        address spent_token_root
    ) external view responsible returns (uint128 tokens_amount, uint128 expected_fee) {
        require(tokenIndex.exists(spent_token_root), DexErrors.NOT_TOKEN_ROOT);
        uint8 i = tokenIndex[spent_token_root];

        (optional(uint128) deposit_amount_opt, uint128 dx_fee) = _getExpectedDepositAmount(i, lp_amount);
        require(deposit_amount_opt.hasValue(), DexErrors.WRONG_AMOUNT);

        uint128 deposit_amount = deposit_amount_opt.get();

        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } (deposit_amount, dx_fee);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Withdraw liquidity

    function expectedWithdrawLiquidity(
        uint128 lp_amount
    ) override external view responsible returns (WithdrawResultV2) {
        optional(WithdrawResultV2) resultOpt = _expectedWithdrawLiquidity(lp_amount);
        require(resultOpt.hasValue(), DexErrors.WRONG_LIQUIDITY);

        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS} resultOpt.get();
    }

    function expectedOneCoinWithdrawalSpendAmount(
        uint128 receive_amount,
        address receive_token_root
    ) external view responsible returns (uint128 lp, uint128 expected_fee) {
        require(tokenIndex.exists(receive_token_root), DexErrors.NOT_TOKEN_ROOT);
        uint8 i = tokenIndex[receive_token_root];

        (optional(uint128) lp_amount_opt, uint128 dy_fee) = _getExpectedLpAmount(i, receive_amount);
        require(lp_amount_opt.hasValue(), DexErrors.WRONG_AMOUNT);

        uint128 lp_amount = lp_amount_opt.get();

        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } (lp_amount, dy_fee);
    }

    function expectedWithdrawLiquidityOneCoin(
        uint128 lp_amount,
        address outcoming
    ) override external view responsible returns (WithdrawResultV2) {
        require(tokenIndex.exists(outcoming), DexErrors.NOT_TOKEN_ROOT);
        require(lp_amount < lp_supply, DexErrors.WRONG_LIQUIDITY);

        (optional(WithdrawResultV2) resultOpt,) = _expectedWithdrawLiquidityOneCoin(lp_amount, tokenIndex[outcoming], _reserves(), lp_supply, address(0));
        require(resultOpt.hasValue(), DexErrors.WRONG_LIQUIDITY);

        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } resultOpt.get();
    }

    function withdrawLiquidity(
        uint64 call_id,
        TokenOperation _operation,
        TokenOperation[] _expected,
        address account_owner,
        uint32 /*account_version*/,
        address send_gas_to
    ) override external onlyActive onlyAccount(account_owner) {
        require(_operation.root == lp_root, DexErrors.NOT_LP_TOKEN_ROOT);
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        optional(WithdrawResultV2) resultOpt;
        uint128[] referrer_fees = new uint128[](N_COINS);
        if (_expected.length == 1) {
            (resultOpt, referrer_fees) = _expectedWithdrawLiquidityOneCoin(_operation.amount, tokenIndex[_expected[0].root], _reserves(), lp_supply, address(0));
        } else {
            resultOpt = _expectedWithdrawLiquidity(_operation.amount);
        }

        require(resultOpt.hasValue(), DexErrors.WRONG_LIQUIDITY);
        WithdrawResultV2 result = resultOpt.get();

        for (TokenOperation expected: _expected) {
            require(expected.amount <= result.amounts[tokenIndex[expected.root]], DexErrors.WRONG_LIQUIDITY);
        }

        _applyWithdrawLiquidity(
            result,
            referrer_fees,
            call_id,
            true,
            account_owner,
            account_owner,
            address(0),
            0,
            send_gas_to
        );

        _sync();

        for (uint8 i = 0; i < N_COINS; i++) {
            if (result.amounts[i] > 0) {
                IDexAccount(msg.sender)
                    .internalPoolTransfer{ value: DexGas.INTERNAL_PAIR_TRANSFER_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                (
                    result.amounts[i],
                    tokenData[i].root,
                    _tokenRoots(),
                    send_gas_to
                );
            }
        }

        TvmCell empty;
        IBurnableByRootTokenRoot(lp_root).burnTokens{
            value: DexGas.BURN_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES
        }(
            _operation.amount,
            _expectedTokenVaultAddress(lp_root),
            send_gas_to,
            address(0),
            empty
        );

        ISuccessCallback(msg.sender).successCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }(call_id);
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Exchange

    function expectedExchange(
        uint128 amount,
        address spent_token_root,
        address receive_token_root
    ) override external view responsible returns (uint128 expected_amount, uint128 expected_fee) {
        require(tokenIndex.exists(spent_token_root) && tokenIndex.exists(receive_token_root), DexErrors.NOT_TOKEN_ROOT);
        uint8 i = tokenIndex[spent_token_root];
        uint8 j = tokenIndex[receive_token_root];
        (optional(ExpectedExchangeResult) dy_result_opt,) = _get_dy(i, j, amount, address(0));
        if (dy_result_opt.hasValue()) {
            ExpectedExchangeResult dy_result = dy_result_opt.get();

            return {
                value: 0,
                bounce: false,
                flag: MsgFlag.REMAINING_GAS
            } (dy_result.amount, dy_result.pool_fee + dy_result.beneficiary_fee);
        } else {
            return {
                value: 0,
                bounce: false,
                flag: MsgFlag.REMAINING_GAS
            } (0, 0);
        }
    }

    function expectedSpendAmount(
        uint128 receive_amount,
        address receive_token_root,
        address spent_token_root
    ) override external view responsible returns (uint128 expected_amount, uint128 expected_fee) {
        require(tokenIndex.exists(receive_token_root) && tokenIndex.exists(spent_token_root), DexErrors.NOT_TOKEN_ROOT);
        uint8 j = tokenIndex[receive_token_root];
        uint8 i = tokenIndex[spent_token_root];
        optional(ExpectedExchangeResult) dx_result_opt = _get_dx(i, j, receive_amount);
        require(dx_result_opt.hasValue(), DexErrors.WRONG_AMOUNT);

        ExpectedExchangeResult dx_result = dx_result_opt.get();

        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } (dx_result.amount, dx_result.pool_fee + dx_result.beneficiary_fee);
    }

    function exchange(
        uint64 call_id,
        TokenOperation _operation,
        TokenOperation _expected,
        address account_owner,
        uint32 /*account_version*/,
        address send_gas_to
    ) override external onlyActive onlyAccount(account_owner) {
        require(tokenIndex.exists(_operation.root) && tokenIndex.exists(_expected.root), DexErrors.NOT_TOKEN_ROOT);
        uint8 i = tokenIndex[_operation.root];
        uint8 j = tokenIndex[_expected.root];
        require(i != j && i < N_COINS && j < N_COINS, DexErrors.WRONG_TOKEN_ROOT);
        (optional(ExpectedExchangeResult) dy_result_opt,) = _get_dy(i, j, _operation.amount, address(0));
        require(dy_result_opt.hasValue(), DexErrors.WRONG_AMOUNT);

        ExpectedExchangeResult dy_result = dy_result_opt.get();

        require(dy_result.amount >= _expected.amount, DexErrors.LOW_EXCHANGE_RATE);

        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        tokenData[i].balance += _operation.amount - dy_result.beneficiary_fee;
        tokenData[j].balance -= dy_result.amount;

        if (dy_result.beneficiary_fee > 0) {
            tokenData[i].accumulatedFee += dy_result.beneficiary_fee;
            _processBeneficiaryFees(false, send_gas_to);
        }

        ExchangeFee[] fees;
        fees.push(ExchangeFee(tokenData[i].root, dy_result.pool_fee, dy_result.beneficiary_fee, fee.beneficiary));

        emit Exchange(
            account_owner,
            account_owner,
            tokenData[i].root,
            _operation.amount,
            tokenData[j].root,
            dy_result.amount,
            fees
        );

        _sync();

        IDexPairOperationCallback(account_owner).dexPairExchangeSuccessV2{
            value: DexGas.OPERATION_CALLBACK_BASE + 1,
            flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
            bounce: false
        }(call_id, true, IExchangeResultV2.ExchangeResultV2(
            _operation.root,
            _expected.root,
            _operation.amount,
            dy_result.pool_fee + dy_result.beneficiary_fee,
            dy_result.amount
        ));

        IDexAccount(msg.sender)
            .internalPoolTransfer{ value: DexGas.INTERNAL_PAIR_TRANSFER_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
        (
            dy_result.amount,
            _expected.root,
            _tokenRoots(),
            send_gas_to
        );

        ISuccessCallback(msg.sender).successCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }(call_id);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Fee

    function _processBeneficiaryFees(bool force, address send_gas_to) private {
        address beneficiaryAccount = _expectedAccountAddress(fee.beneficiary);

        for (uint8 i = 0; i < N_COINS; i++) {
            address _root = tokenData[i].root;
            if (
                (tokenData[i].accumulatedFee > 0 && force) ||
                !fee.threshold.exists(_root) ||
                tokenData[i].accumulatedFee >= fee.threshold[_root]
            ) {
                IDexAccount(beneficiaryAccount).internalPoolTransfer{
                    value: DexGas.INTERNAL_PAIR_TRANSFER_VALUE,
                    flag: MsgFlag.SENDER_PAYS_FEES
                }(
                    tokenData[i].accumulatedFee,
                    tokenData[i].root,
                    _tokenRoots(),
                    send_gas_to
                );
                tokenData[i].accumulatedFee = 0;
            }
        }
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Cross-pair exchange

    function crossPoolExchange(
        uint64 id,

        uint32 /*prev_pool_version*/,
        uint8 /*prev_pool_type*/,

        address[] prev_pool_token_roots,

        uint8 op,
        address spent_token_root,
        uint128 spent_amount,

        address sender_address,
        address recipient,
        address referrer,

        address original_gas_to,
        uint128 deploy_wallet_grams,

        TvmCell payload,
        bool notify_success,
        TvmCell success_payload,
        bool notify_cancel,
        TvmCell cancel_payload
    ) override external onlyPoolOrTokenVault(prev_pool_token_roots, spent_token_root) {
        require(tokenIndex.exists(spent_token_root) || spent_token_root == lp_root, DexErrors.NOT_TOKEN_ROOT);

        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        (
            uint128 expected_amount,
            address outcoming,
            NextExchangeData[] next_steps
        ) = PairPayload.decodeCrossPoolExchangePayload(payload, op);

        TvmCell empty;
        uint128 referrer_value = referrer.value != 0 ? DexGas.REFERRER_FEE_EXTRA_VALUE : 0;

        uint16 errorCode = !active ? DirectOperationErrors.NOT_ACTIVE
            : msg.sender == address(this) ? DirectOperationErrors.WRONG_PREVIOUS_POOL
            : !tokenIndex.exists(outcoming) && outcoming != lp_root ? DirectOperationErrors.NOT_TOKEN_ROOT
            : 0;

        if (errorCode == 0) {
            TokenOperation operation;

            if (outcoming == lp_root && spent_token_root != lp_root) { // deposit liquidity

                (optional(DepositLiquidityResultV2) resultOpt, uint128[] referrer_fees) = _expectedOneCoinDepositLiquidity(spent_amount, tokenIndex[spent_token_root], _reserves(), lp_supply, referrer);

                errorCode = _checkDepositReceivedAmount(resultOpt, expected_amount);
                if (errorCode == 0) {
                    DepositLiquidityResultV2 result = resultOpt.get();
                    _applyAddLiquidity(
                        result,
                        referrer_fees,
                        id,
                        false,
                        sender_address,
                        recipient,
                        referrer,
                        referrer_value,
                        original_gas_to
                    );

                    TvmBuilder builder;

                    TvmCell exchange_data = abi.encode(
                        id,
                        current_version,
                        DexPoolTypes.STABLE_POOL,
                        _tokenRoots(),
                        sender_address,
                        recipient,
                        referrer,
                        deploy_wallet_grams,
                        next_steps
                    );
                    builder.store(exchange_data);

                    builder.store(success_payload);
                    builder.store(cancel_payload);

                    ITokenRoot(lp_root).mint{
                        value: 0,
                        flag: MsgFlag.ALL_NOT_RESERVED
                    }(
                        result.lp_reward,
                        _expectedTokenVaultAddress(lp_root),
                        deploy_wallet_grams,
                        original_gas_to,
                        true,
                        builder.toCell()
                    );
                }
            } else if (outcoming != lp_root && spent_token_root == lp_root) { // withdraw liquidity

                (optional(WithdrawResultV2) result_opt, uint128[] referrer_fees) = _expectedWithdrawLiquidityOneCoin(spent_amount, tokenIndex[outcoming], _reserves(), lp_supply, referrer);

                errorCode = _checkOneCoinWithdrawalReceivedAmount(result_opt, tokenIndex[outcoming], expected_amount);
                if (errorCode == 0) {
                    WithdrawResultV2 result = result_opt.get();
                    uint8 j = tokenIndex[outcoming];

                    _applyWithdrawLiquidity(
                        result,
                        referrer_fees,
                        id,
                        false,
                        sender_address,
                        recipient,
                        referrer,
                        referrer_value,
                        original_gas_to
                    );

                    operation = TokenOperation(result.amounts[j], tokenData[j].root);

                    IBurnableByRootTokenRoot(lp_root).burnTokens{
                        value: DexGas.BURN_VALUE,
                        flag: MsgFlag.SENDER_PAYS_FEES
                    }(
                        spent_amount,
                        _expectedTokenVaultAddress(lp_root),
                        original_gas_to,
                        address(0),
                        empty
                    );
                }
            } else { // exchange
                optional(ExpectedExchangeResult) dy_result_opt;
                uint128 referrer_fee = 0;

                if (spent_token_root == outcoming) {
                    errorCode = DirectOperationErrors.WRONG_TOKEN_ROOT;
                } else {
                    (dy_result_opt, referrer_fee) = _get_dy(tokenIndex[spent_token_root], tokenIndex[outcoming], spent_amount, referrer);
                    errorCode = _checkExchangeReceivedAmount(dy_result_opt, expected_amount);
                }

                if (errorCode == 0) {
                    uint8 i = tokenIndex[spent_token_root];
                    uint8 j = tokenIndex[outcoming];

                    ExpectedExchangeResult dy_result = dy_result_opt.get();
                    operation = TokenOperation(dy_result.amount, tokenData[j].root);

                    tokenData[i].balance += spent_amount - dy_result.beneficiary_fee - referrer_fee;
                    tokenData[j].balance -= dy_result.amount;

                    ExchangeFee[] fees;
                    fees.push(ExchangeFee(tokenData[i].root, dy_result.pool_fee, dy_result.beneficiary_fee, fee.beneficiary));

                    emit Exchange(
                        sender_address,
                        recipient,
                        tokenData[i].root,
                        spent_amount,
                        tokenData[j].root,
                        dy_result.amount,
                        fees
                    );

                    if (dy_result.beneficiary_fee > 0) {
                        tokenData[i].accumulatedFee += dy_result.beneficiary_fee;
                        _processBeneficiaryFees(false, original_gas_to);
                    }

                    if (referrer_fee > 0) {
                        IDexTokenVault(_expectedTokenVaultAddress(tokenData[i].root)).referralFeeTransfer{
                            value: referrer_value,
                            flag: 0
                        }(
                            referrer_fee,
                            referrer,
                            original_gas_to,
                            _tokenRoots()
                        );

                        emit ReferrerFees([TokenOperation(referrer_fee, tokenData[i].root)]);
                    }
                }
            }

            if (errorCode == 0) {

                if (outcoming != lp_root) { // withdraw or exchange

                    uint16 post_swap_error_code = 0;

                    uint256 denominator = 0;
                    uint32 all_nested_nodes = uint32(next_steps.length);
                    uint32 all_leaves = 0;
                    uint32 max_nested_nodes = 0;
                    uint32 max_nested_nodes_idx = 0;
                    for (uint32 i = 0; i < next_steps.length; i++) {
                        NextExchangeData next_step = next_steps[i];
                        if (next_step.poolRoot.value == 0 || next_step.poolRoot == address(this) ||
                            next_step.numerator == 0 || next_step.leaves == 0) {

                            post_swap_error_code = DirectOperationErrors.INVALID_NEXT_STEPS;
                            break;
                        }
                        if (next_step.nestedNodes > max_nested_nodes) {
                            max_nested_nodes = next_step.nestedNodes;
                            max_nested_nodes_idx = i;
                        }
                        denominator += next_step.numerator;
                        all_nested_nodes += next_step.nestedNodes;
                        all_leaves += next_step.leaves;
                    }

                    if (post_swap_error_code == 0 && msg.value < (DexGas.CROSS_POOL_EXCHANGE_MIN_VALUE + referrer_value) * (1 + all_nested_nodes)) {
                        post_swap_error_code = DirectOperationErrors.VALUE_TOO_LOW;
                    }

                    if (post_swap_error_code == 0 && next_steps.length > 0) {
                        uint128 extraValue = msg.value - (DexGas.CROSS_POOL_EXCHANGE_MIN_VALUE + referrer_value) * (1 + all_nested_nodes);

                        for (uint32 i = 0; i < next_steps.length; i++) {
                            NextExchangeData next_step = next_steps[i];

                            uint128 next_pool_amount = uint128(math.muldiv(operation.amount, next_step.numerator, denominator));
                            uint128 current_extra_value = math.muldiv(uint128(next_step.leaves), extraValue, uint128(all_leaves));

                            IDexBasePool(next_step.poolRoot).crossPoolExchange{
                                value: i == max_nested_nodes_idx ? 0 : (next_step.nestedNodes + 1) * (DexGas.CROSS_POOL_EXCHANGE_MIN_VALUE + referrer_value) + current_extra_value,
                                flag: i == max_nested_nodes_idx ? MsgFlag.ALL_NOT_RESERVED : MsgFlag.SENDER_PAYS_FEES
                            }(
                                id,

                                current_version,
                                DexPoolTypes.STABLE_POOL,

                                _tokenRoots(),

                                op,
                                operation.root,
                                next_pool_amount,

                                sender_address,
                                recipient,
                                referrer,

                                original_gas_to,
                                deploy_wallet_grams,

                                next_step.payload,
                                notify_success,
                                success_payload,
                                notify_cancel,
                                cancel_payload
                            );
                        }
                    } else {
                        uint8 j = tokenIndex[operation.root];
                        bool is_last_step = next_steps.length == 0;

                        if (!is_last_step) {
                            IDexPairOperationCallback(sender_address).dexPairOperationCancelled{
                                value: DexGas.OPERATION_CALLBACK_BASE + 44,
                                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                                bounce: false
                            }(id);

                            if (recipient != sender_address) {
                                IDexPairOperationCallback(recipient).dexPairOperationCancelled{
                                    value: DexGas.OPERATION_CALLBACK_BASE,
                                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                                    bounce: false
                                }(id);
                            }
                        }

                        IDexTokenVault(_expectedTokenVaultAddress(tokenData[j].root)).transfer{
                            value: 0,
                            flag: MsgFlag.ALL_NOT_RESERVED
                        }(
                            operation.amount,
                            is_last_step ? recipient : sender_address,
                            deploy_wallet_grams,
                            is_last_step ? notify_success : notify_cancel,
                            is_last_step
                                ? PairPayload.buildSuccessPayload(op, success_payload, sender_address)
                                : PairPayload.buildCancelPayload(op, post_swap_error_code, cancel_payload, next_steps),
                            _tokenRoots(),
                            current_version,
                            original_gas_to
                        );
                    }
                }
            }
        }

        if (errorCode != 0) {
            IDexPairOperationCallback(sender_address).dexPairOperationCancelled{
                value: DexGas.OPERATION_CALLBACK_BASE + 44,
                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                bounce: false
            }(id);

            if (recipient != sender_address) {
                IDexPairOperationCallback(recipient).dexPairOperationCancelled{
                    value: DexGas.OPERATION_CALLBACK_BASE,
                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                    bounce: false
                }(id);
            }

            IDexTokenVault(_expectedTokenVaultAddress(spent_token_root)).transfer{
                value: 0,
                flag: MsgFlag.ALL_NOT_RESERVED
            }(
                spent_amount,
                sender_address,
                deploy_wallet_grams,
                notify_cancel,
                PairPayload.buildCancelPayload(op, errorCode, cancel_payload, next_steps),
                _tokenRoots(),
                current_version,
                original_gas_to
            );
        } else {
            _sync();
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Account operations

    function checkPair(address account_owner, uint32 /*account_version*/) override external onlyAccount(account_owner) {
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);
        IDexAccount(msg.sender).checkPoolCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }(
            _tokenRoots(),
            lp_root
        );
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Modifiers

    modifier onlyActive() {
        require(active, DexErrors.NOT_ACTIVE);
        _;
    }

    modifier onlyLiquidityTokenRoot() {
        require(msg.sender == lp_root, DexErrors.NOT_LP_TOKEN_ROOT);
        _;
    }

    modifier onlyTokenRoot() {
        bool found = false;
        for (uint8 i = 0; i < N_COINS; i++) {
            if (tokenData[i].root == msg.sender) {
                found = true;
                break;
            }
        }
        require(found, DexErrors.NOT_TOKEN_ROOT);
        _;
    }

    modifier onlyRoot() {
        require(msg.sender == root, DexErrors.NOT_ROOT);
        _;
    }

    modifier onlyPoolOrTokenVault(address[] _poolTokenRoots, address _tokenRoot) {
        require(
            msg.sender == _expectedPoolAddress(_poolTokenRoots) ||
            msg.sender == _expectedTokenVaultAddress(_tokenRoot),
            DexErrors.NEITHER_POOL_NOR_VAULT
        );
        _;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Code upgrade

    function upgrade(TvmCell code, uint32 new_version, uint8 new_type, address send_gas_to) override external onlyRoot {
        if (current_version == new_version && new_type == DexPoolTypes.STABLE_POOL) {
            tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);
            send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS, bounce: false });
        } else {
            if (fee.beneficiary.value != 0) {
                _processBeneficiaryFees(true, send_gas_to);
            }
            emit PoolCodeUpgraded(new_version, new_type);

            TvmBuilder builder;

            builder.store(root);
            builder.store(vault);
            builder.store(current_version);
            builder.store(new_version);
            builder.store(send_gas_to);
            builder.store(DexPoolTypes.STABLE_POOL);

            builder.store(platform_code);  // ref1 = platform_code

            //Tokens
            TvmCell tokens_data_cell = abi.encode(_tokenRoots());
            builder.store(tokens_data_cell);  // ref2

            TvmCell other_data = abi.encode(
                lp_root,
                lp_wallet,
                lp_supply,

                fee,
                tokenData,
                A,
                PRECISION
            );

            builder.store(other_data);   // ref3

            // set code after complete this method
            tvm.setcode(code);

            // run onCodeUpgrade from new code
            tvm.setCurrentCode(code);
            onCodeUpgrade(builder.toCell());
        }
    }

    function onCodeUpgrade(TvmCell upgrade_data) private {
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);
        tvm.resetStorage();
        TvmSlice s = upgrade_data.toSlice();

        address send_gas_to;
        uint32 old_version;
        uint8 old_pool_type;

        (root, vault, old_version, current_version, send_gas_to) = s.decode(address, address, uint32, uint32, address);

        if (s.bits() >= 8) {
            old_pool_type = s.decode(uint8);
        }

        platform_code = s.loadRef(); // ref 1

        address[] roots;
        if (old_pool_type != DexPoolTypes.CONSTANT_PRODUCT) {
            TvmCell tokens_data_cell = s.loadRef(); // ref 2

            TvmSlice tokens_data_slice = tokens_data_cell.toSlice();
            if (tokens_data_slice.bits() == 33) {
                roots = abi.decode(tokens_data_cell, address[]);
            } else {
                (address left_root, address right_root) = tokens_data_slice.decode(address, address);
                roots = [left_root, right_root];
            }
            N_COINS = uint8(roots.length);

            for (uint8 i = 0; i < N_COINS; i++) {
                tokenIndex[roots[i]] = i;
            }
        }

        if (old_version == 0) {
            fee = FeeParams(1000000, 3000, 0, 0, address(0), emptyMap, emptyMap);
            A = AmplificationCoefficient(100 * uint128(N_COINS) ** (N_COINS - 1), 1);

            tokenData = new PoolTokenData[](N_COINS);
            for (uint8 i = 0; i < N_COINS; i++) {
                tokenData[i] = PoolTokenData(roots[i], address(0), 0, 0, 0, 0, 0, false, false);
            }

            IDexRoot(root)
                .deployLpToken{
                    value: 0,
                    flag: MsgFlag.ALL_NOT_RESERVED
                }(
                    roots,
                    send_gas_to
                );
        } else if (old_pool_type == DexPoolTypes.CONSTANT_PRODUCT) {
            active = false;
            A = AmplificationCoefficient(200, 1);

            mapping(uint8 => uint128[]) type_to_reserves;
            mapping(uint8 => address[]) type_to_root_addresses;
            mapping(uint8 => address[]) type_to_wallet_addresses;

            TvmCell otherData = s.loadRef(); // ref 2
            (
                fee,
                type_to_reserves,
                type_to_root_addresses,
                type_to_wallet_addresses
            ) = abi.decode(otherData, (
                FeeParams,
                mapping(uint8 => uint128[]),
                mapping(uint8 => address[]),
                mapping(uint8 => address[])
            ));

            lp_root = type_to_root_addresses[DexAddressType.LP][0];
            lp_wallet = type_to_wallet_addresses[DexAddressType.LP][0];
            lp_supply = type_to_reserves[DexReserveType.LP][0];

            tokenIndex[type_to_root_addresses[DexAddressType.RESERVE][0]] = 0;
            tokenIndex[type_to_root_addresses[DexAddressType.RESERVE][1]] = 1;
            N_COINS = 2;

            tokenData = new PoolTokenData[](N_COINS);
            tokenData[0] = PoolTokenData(type_to_root_addresses[DexAddressType.RESERVE][0], type_to_wallet_addresses[DexAddressType.RESERVE][0], type_to_reserves[DexReserveType.POOL][0], 0, type_to_reserves[DexReserveType.FEE][0], 0, 0, false, false);
            tokenData[1] = PoolTokenData(type_to_root_addresses[DexAddressType.RESERVE][1], type_to_wallet_addresses[DexAddressType.RESERVE][1], type_to_reserves[DexReserveType.POOL][1], 0, type_to_reserves[DexReserveType.FEE][1], 0, 0, false, false);

            ITokenRoot(type_to_root_addresses[DexAddressType.RESERVE][0]).decimals{
                value: DexGas.GET_TOKEN_DECIMALS_VALUE,
                flag: MsgFlag.SENDER_PAYS_FEES,
                callback: DexStablePool.onTokenDecimals
            }();
                ITokenRoot(type_to_root_addresses[DexAddressType.RESERVE][1]).decimals{
                value: DexGas.GET_TOKEN_DECIMALS_VALUE,
                flag: MsgFlag.SENDER_PAYS_FEES,
                callback: DexStablePool.onTokenDecimals
            }();
        } else if (old_pool_type == DexPoolTypes.STABLESWAP) {
            active = false;
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

            uint8 maxDecimals = 0;
            for (uint8 _i = 0; _i < N_COINS; _i++) {
                maxDecimals = math.max(maxDecimals, tokenData[_i].decimals);
            }
            MAX_DECIMALS = maxDecimals;

            _tryToActivate();
        } else if (old_pool_type == DexPoolTypes.STABLE_POOL) {
            active = false;
            TvmCell other_data = s.loadRef(); // ref 3

            // Set lp reserve and fee options
            (
                lp_root, lp_wallet, lp_supply,

                fee,
                tokenData,
                A,
                PRECISION
            ) = abi.decode(other_data, (
                address, address, uint128,
                FeeParams,
                IPoolTokenData.PoolTokenData[],
                IAmplificationCoefficient.AmplificationCoefficient,
                uint256
            ));

            uint8 maxDecimals = 0;
            for (uint8 _i = 0; _i < N_COINS; _i++) {
                maxDecimals = math.max(maxDecimals, tokenData[_i].decimals);
            }
            MAX_DECIMALS = maxDecimals;

            _tryToActivate();
        }

        send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS, bounce: false });
    }

    function _tryToActivate() private {
        bool allTokensIsInit = true;
        for (uint i = 0; i < N_COINS; i++) {
            if (!tokenData[i].initialized) {
                allTokensIsInit = false;
                break;
            }
        }
        active = lp_wallet.value != 0 && allTokensIsInit;
    }

    function _configureToken(address token_root) private view {
        ITokenRoot(token_root).deployWallet {
            value: DexGas.DEPLOY_EMPTY_WALLET_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES,
            callback: DexStablePool.onTokenWallet
        }(address(this), DexGas.DEPLOY_EMPTY_WALLET_GRAMS);

        if (token_root != lp_root) {
            ITokenRoot(token_root).decimals{
                value: DexGas.GET_TOKEN_DECIMALS_VALUE,
                flag: MsgFlag.SENDER_PAYS_FEES,
                callback: DexStablePool.onTokenDecimals
            }();
        }
    }

    function onTokenWallet(address wallet) external {
        require(tokenIndex.exists(msg.sender) || msg.sender == lp_root, DexErrors.NOT_ROOT);

        if (msg.sender == lp_root && lp_wallet.value == 0) {
            lp_wallet = wallet;

            bool allTokensIsInit = true;
            for (uint i = 0; i < N_COINS; i++) {
                if (!tokenData[i].initialized) {
                    allTokensIsInit = false;
                    break;
                }
            }
            active = allTokensIsInit;
        } else {
            tokenData[tokenIndex[msg.sender]].wallet = wallet;
        }

        wallet.transfer({
            value: 0,
            flag: MsgFlag.REMAINING_GAS + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function onTokenDecimals(uint8 _decimals) external {
        require(tokenIndex.exists(msg.sender), DexErrors.NOT_ROOT);

        tokenData[tokenIndex[msg.sender]].decimals = _decimals;
        tokenData[tokenIndex[msg.sender]].decimalsLoaded = true;

        bool allDecimalsLoaded = true;

        for (uint8 _i = 0; _i < N_COINS; _i++) {
            allDecimalsLoaded = allDecimalsLoaded && tokenData[_i].decimalsLoaded;
        }

        if (allDecimalsLoaded) {
            _initializeTokenData();
        }
    }

    function _initializeTokenData() internal {
        uint8 maxDecimals = 0;

        for (uint8 _i = 0; _i < N_COINS; _i++) {
            maxDecimals = math.max(maxDecimals, tokenData[_i].decimals);
        }

        MAX_DECIMALS = maxDecimals;
        PRECISION = uint256(10) ** uint256(MAX_DECIMALS);

        for (uint8 _i = 0; _i < N_COINS; _i++) {
            tokenData[_i].precisionMul = uint256(10) ** uint256(MAX_DECIMALS - tokenData[_i].decimals);
            tokenData[_i].rate = tokenData[_i].precisionMul * PRECISION;
            tokenData[_i].initialized = true;
        }

        active = lp_wallet.value != 0;
    }

    function liquidityTokenRootDeployed(address lp_root_, address send_gas_to) override external onlyRoot {
        tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);

        lp_root = lp_root_;

        _configureToken(lp_root);

        address[] r = new address[](0);
        for (PoolTokenData t: tokenData) {
            _configureToken(t.root);
            r.push(t.root);
        }

        IDexRoot(root).onPoolCreated{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }(r, DexPoolTypes.STABLE_POOL, send_gas_to);
    }

    function liquidityTokenRootNotDeployed(address /*lp_root_*/, address send_gas_to) override external onlyRoot {
        if (!active) send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.DESTROY_IF_ZERO, bounce: false});
        else {
            tvm.rawReserve(DexGas.PAIR_INITIAL_BALANCE, 0);
            send_gas_to.transfer({ value: 0, flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS, bounce: false});
        }
    }

    function getVirtualPrice() override external view responsible returns (optional(uint256)) {
        optional(uint256) result;

        if (lp_supply != 0) {
            uint256[] xp = new uint256[](0);

            for (PoolTokenData t: tokenData) {
                xp.push(math.muldiv(t.rate, t.balance, PRECISION));
            }

            optional(uint256) D_opt = _get_D(xp);

            if (D_opt.hasValue()) {
                uint256 value = uint256(math.muldiv(D_opt.get(), 10**18, lp_supply));
                result.set(math.muldiv(value, uint256(10)**LP_DECIMALS, PRECISION));
            }
        }

        return { value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS } result;
    }

    function getPriceImpact(
        uint128 amount,
        address spent_token_root,
        address receive_token_root,
        uint128 price_amount
    ) external view returns (optional(uint256)) {
        optional(uint256) result;

        if (tokenIndex.exists(spent_token_root) && tokenIndex.exists(receive_token_root) && price_amount != 0 && amount != 0) {

            uint8 i = tokenIndex[spent_token_root];
            uint8 j = tokenIndex[receive_token_root];

            uint128[] reserves_mem = _reserves();
            uint256[] xp_mem = _xp_mem(reserves_mem);

            (optional(ExpectedExchangeResult) old_price_res,) = _get_dy_mem(i, j, price_amount, xp_mem, address(0));

            (optional(ExpectedExchangeResult) dy_result_opt,) = _get_dy_mem(i, j, amount, xp_mem, address(0));

            if (
                dy_result_opt.hasValue() &&
                old_price_res.hasValue()
            ) {
                uint128 old_price = old_price_res.get().amount;
                ExpectedExchangeResult dy_result = dy_result_opt.get();

                reserves_mem[i] += amount - dy_result.beneficiary_fee;
                reserves_mem[j] -= dy_result.amount;

                (optional(ExpectedExchangeResult) new_price_res,) = _get_dy_mem(i, j, price_amount, _xp_mem(reserves_mem), address(0));

                if (new_price_res.hasValue()) {
                    result.set(
                        math.muldiv(
                            uint256(old_price - new_price_res.get().amount),
                            10**20,
                            old_price
                        )
                    );
                }
            }
        }

        return result;
    }

    function getDepositPriceImpact(
        uint128 amount,
        address spent_token_root,
        uint128 price_amount
    ) external view returns (optional(uint256)) {
        optional(uint256) result;

        if (tokenIndex.exists(spent_token_root) && price_amount != 0 && amount != 0) {

            uint8 i = tokenIndex[spent_token_root];
            uint128[] reserves_mem = _reserves();

            (optional(DepositLiquidityResultV2) old_price_res,) = _expectedOneCoinDepositLiquidity(price_amount, i, reserves_mem, lp_supply, address(0));

            (optional(DepositLiquidityResultV2) result_opt,) = _expectedOneCoinDepositLiquidity(amount, i, reserves_mem, lp_supply, address(0));

            if (
                result_opt.hasValue() &&
                old_price_res.hasValue()
            ) {
                uint128 old_price = old_price_res.get().lp_reward;
                DepositLiquidityResultV2 deposit_result = result_opt.get();

                reserves_mem[i] = deposit_result.result_balances[i];
                uint128 new_lp_supply = lp_supply + deposit_result.lp_reward;

                (optional(DepositLiquidityResultV2) new_price_res,) = _expectedOneCoinDepositLiquidity(price_amount, i, reserves_mem, new_lp_supply, address(0));

                if (new_price_res.hasValue()) {
                    result.set(
                        math.muldiv(
                            old_price > new_price_res.get().lp_reward ? uint256(old_price - new_price_res.get().lp_reward) : 0,
                            10**20,
                            old_price
                        )
                    );
                }
            }
        }

        return result;
    }

    function getWithdrawalPriceImpact(
        uint128 amount,
        address receive_token_root,
        uint128 price_amount
    ) external view returns (optional(uint256)) {
        optional(uint256) result;

        if (tokenIndex.exists(receive_token_root) && price_amount != 0 && amount != 0 && amount + price_amount < lp_supply) {

            uint8 j = tokenIndex[receive_token_root];
            uint128[] reserves_mem = _reserves();

            (optional(WithdrawResultV2) old_price_res,) = _expectedWithdrawLiquidityOneCoin(price_amount, j, reserves_mem, lp_supply, address(0));

            (optional(WithdrawResultV2) result_opt,) = _expectedWithdrawLiquidityOneCoin(amount, j, reserves_mem, lp_supply, address(0));

            if (
                result_opt.hasValue() &&
                old_price_res.hasValue()
            ) {
                uint128 old_price = old_price_res.get().amounts[j];
                WithdrawResultV2 withdrawal_result = result_opt.get();

                reserves_mem[j] = withdrawal_result.result_balances[j];
                uint128 new_lp_supply = lp_supply - withdrawal_result.lp_amount;

                (optional(WithdrawResultV2) new_price_res,) = _expectedWithdrawLiquidityOneCoin(price_amount, j, reserves_mem, new_lp_supply, address(0));

                if (new_price_res.hasValue()) {
                    result.set(
                        math.muldiv(
                            old_price > new_price_res.get().amounts[j] ? uint256(old_price - new_price_res.get().amounts[j]) : 0,
                            10**20,
                            old_price
                        )
                    );
                }
            }
        }

        return result;
    }

    // Stable math ##############################################
    function _get_D(uint256[] _xp) internal view returns(optional(uint256)) {
        optional(uint256) result;

        uint256 S = 0;
        uint256 Dprev = 0;

        for (uint256 _x: _xp) {
            S += _x;
        }
        if (S == 0) {
            result.set(0);
            return result;
        }

        uint256 D = S;
        uint256 Ann = A.value * N_COINS;

        for (uint8 _i = 0; _i <= 255; _i++) {
            uint256 D_P = D;
            for (uint256 _x : _xp) {
                D_P = math.muldiv(D_P, D, _x * N_COINS);
            }
            Dprev = D;
            D = math.muldiv(
                math.muldiv(Ann, S, A.precision) + D_P * N_COINS,
                D,
                (math.muldiv(Ann - A.precision, D, A.precision) + (N_COINS + 1) * D_P)
            );
            if ((D > Dprev ? (D - Dprev) : (Dprev - D)) <= 1) {
                result.set(D);
                return result;
            }
        }
        return result;
    }

    function _get_y(uint8 i, uint8 j, uint256 x, uint256[] _xp) internal view returns(optional(uint128)){
        optional(uint128) result;
        optional(uint256) D_opt = _get_D(_xp);
        if (!D_opt.hasValue() || i == j || i >= N_COINS || j >= N_COINS) {
            return result;
        }

        uint256 D = D_opt.get();
        uint256 Ann = A.value * N_COINS;
        uint256 c = D;
        uint256 S = 0;
        uint256 _x = 0;
        uint256 y_prev = 0;

        for (uint8 _i = 0; _i < N_COINS; _i++) {
            if (_i == i) {
                _x = x;
                S += _x;
                c = math.muldiv(c, D, _x * N_COINS);
            } else if(_i != j) {
                _x = _xp[_i];
                S += _x;
                c = math.muldiv(c, D, _x * N_COINS);
            }
        }

        c = math.muldiv(c, D * A.precision, (Ann * N_COINS));
        uint256 b = S + math.muldiv(D, A.precision, Ann);
        uint256 y = D;

        for (uint8 _i = 0; _i <= 255; _i++) {
            y_prev = y;
            y = (y*y + c) / (2 * y + b - D);
            if ((y > y_prev ? (y - y_prev) : (y_prev - y)) <= 1) {
                result.set(uint128(y));
                break;
            }
        }

        return result;
    }

    function _xp_mem(uint128[] _balances) internal view returns(uint256[]) {
        uint256[] result = new uint256[](0);

        for (uint8 i = 0; i < N_COINS; i++) {
            result.push(math.muldiv(tokenData[i].rate, _balances[i], PRECISION));
        }

        return result;
    }

    struct ExpectedExchangeResult {
        uint128 amount;
        uint128 pool_fee;
        uint128 beneficiary_fee;
    }

    function _get_dy(uint8 i, uint8 j, uint128 _dx, address referrer) internal view returns (optional(ExpectedExchangeResult), uint128) {
        uint256[] xp = new uint256[](0);

        for (PoolTokenData t: tokenData) {
            xp.push(math.muldiv(t.rate, t.balance, PRECISION));
        }

        return _get_dy_mem(i, j, _dx, xp, referrer);
    }

    function _get_dy_mem(uint8 i, uint8 j, uint128 _dx, uint256[] xp, address referrer) internal view returns (optional(ExpectedExchangeResult), uint128) {
        optional(ExpectedExchangeResult) result;

        uint128 fee_numerator = fee.pool_numerator + fee.beneficiary_numerator + fee.referrer_numerator;
        uint128 x_fee = math.muldivc(_dx, fee_numerator, fee.denominator);
        uint128 x_referrer_fee = math.muldiv(x_fee, fee.referrer_numerator, fee_numerator);
        uint128 x_beneficiary_fee;
        uint128 x_pool_fee;

        if (referrer.value != 0 && (
            !fee.referrer_threshold.exists(tokenData[i].root) ||
            fee.referrer_threshold[tokenData[i].root] <= x_referrer_fee
        )) {
            x_pool_fee = math.muldivc(x_fee, fee.pool_numerator, fee_numerator);
            x_beneficiary_fee = x_fee - x_referrer_fee - x_pool_fee;
        } else {
            x_referrer_fee = 0;
            x_pool_fee = math.muldivc(x_fee, fee.pool_numerator, fee.beneficiary_numerator + fee.pool_numerator);
            x_beneficiary_fee = x_fee - x_pool_fee;
        }

        uint256 x = xp[i] + math.muldiv(_dx - x_fee, tokenData[i].rate, PRECISION);
        optional(uint256) y_opt = _get_y(i, j, x, xp);

        if (y_opt.hasValue()) {
            uint128 dy = uint128(math.muldiv(xp[j] - y_opt.get(), PRECISION, tokenData[j].rate));
            if (
                dy <= tokenData[j].balance &&
                dy > 0 &&
                (x_pool_fee > 0 || fee.pool_numerator == 0) &&
                (x_beneficiary_fee > 0 || fee.beneficiary_numerator == 0 || x_pool_fee > 0)
            ) {
                result.set(ExpectedExchangeResult(
                    dy,
                    x_pool_fee,
                    x_beneficiary_fee
                ));
            }
        }

        return (result, result.hasValue() ? x_referrer_fee : 0);
    }

    function _get_dx(uint8 i, uint8 j, uint128 _dy) internal view returns (optional(ExpectedExchangeResult)) {
        optional(ExpectedExchangeResult) result;

        if (_dy >= tokenData[j].balance || _dy == 0) {
            return result;
        }

        uint256[] xp = new uint256[](0);

        for (PoolTokenData t: tokenData) {
            xp.push(math.muldiv(t.rate, t.balance, PRECISION));
        }

        uint256 y = xp[j] - math.muldiv(_dy, tokenData[j].rate, PRECISION);
        optional(uint256) x_opt = _get_y(j, i, y, xp);

        if (x_opt.hasValue()) {
            uint128 fee_d_minus_n = uint128(fee.denominator - fee.pool_numerator - fee.beneficiary_numerator - fee.referrer_numerator);
            uint128 dx_raw = uint128(math.muldivc(x_opt.get() - xp[i], PRECISION, tokenData[i].rate));
            uint128 dx = math.muldivc(dx_raw, fee.denominator, fee_d_minus_n);

            uint128 x_fee = math.muldivc(dx, fee.pool_numerator + fee.beneficiary_numerator + fee.referrer_numerator, fee.denominator);

            uint128 x_pool_fee = math.muldivc(x_fee, fee.pool_numerator, fee.beneficiary_numerator + fee.pool_numerator);
            uint128 x_beneficiary_fee = x_fee - x_pool_fee;

            if (
                (x_pool_fee > 0 || fee.pool_numerator == 0) &&
                (x_beneficiary_fee > 0 || fee.beneficiary_numerator == 0 || x_pool_fee > 0)
            ) {
                result.set(ExpectedExchangeResult(
                    dx,
                    x_pool_fee,
                    x_beneficiary_fee
                ));
            }
        }

        return result;
    }

    function _getExpectedDepositAmount(uint8 i, uint128 lp) private view returns (optional(uint128), uint128) {
        AmplificationCoefficient amp = A;
        optional(uint128) result;
        uint128 dy_fee = 0;

        if (lp == 0) {
            return (result, dy_fee);
        }

        uint256[] xp = new uint256[](0);
        for (PoolTokenData t: tokenData) {
            xp.push(math.muldiv(t.rate, t.balance, PRECISION));
        }

        optional(uint256) D0_opt = _get_D(xp);
        if (D0_opt.hasValue()) {
            uint256 D0 = D0_opt.get();

            uint256 D2;
            if (lp_supply > 0) {
                D2 = D0 + math.muldivc(D0, lp, lp_supply);
            } else {
                D2 = lp;
            }

            optional(uint256) y_minus_fee_opt = _get_y_D(amp, i, xp, D2);
            if (!y_minus_fee_opt.hasValue()) {
                return (result, dy_fee);
            }
            if (MAX_DECIMALS >= LP_DECIMALS) {
                uint256 fee_precision_mul = math.max(uint256(10) ** (MAX_DECIMALS - LP_DECIMALS), tokenData[i].precisionMul);
                uint256 dy_minus_fee = math.divc(y_minus_fee_opt.get() - xp[i], fee_precision_mul);
                uint256 dy = math.muldivc(dy_minus_fee, fee.denominator, fee.denominator - (fee.beneficiary_numerator + fee.pool_numerator + fee.referrer_numerator));
                dy_fee = uint128(math.muldivc(dy - dy_minus_fee, fee_precision_mul, tokenData[i].precisionMul));

                result.set(uint128(math.muldivc(dy, fee_precision_mul, tokenData[i].precisionMul)));
            } else {
                uint256 dy_minus_fee = y_minus_fee_opt.get() - xp[i] + 1; // prevent rounding errors
                uint256 dy = math.muldivc(dy_minus_fee, fee.denominator, fee.denominator - (fee.beneficiary_numerator + fee.pool_numerator + fee.referrer_numerator));
                dy_fee = uint128(dy - dy_minus_fee);

                result.set(uint128(dy));
            }
        }

        return (result, dy_fee);
    }

    function _getExpectedLpAmount(uint8 i, uint128 _dy) private view returns (optional(uint128), uint128) {
        optional(uint128) result;
        uint128 dy_fee = 0;

        if (_dy >= tokenData[i].balance || _dy == 0) {
            return (result, dy_fee);
        }

        uint256[] xp_mem = _xp_mem(_reserves());
        uint256[] xp = xp_mem;

        optional(uint256) D0_opt = _get_D(xp_mem);

        uint256 dy = math.muldivc(_dy, tokenData[i].rate, PRECISION);

        xp[i] -= dy;
        optional(uint256) D1_opt = _get_D(xp);

        if (D1_opt.hasValue() && D0_opt.hasValue()) {
            AmplificationCoefficient amp = A;

            uint256 D0 = D0_opt.get();
            uint256 D1 = D1_opt.get();

            uint128 lp_raw = uint128(math.muldivc(lp_supply, (D0 - D1), D0));
            uint128 lp_res = math.muldivc(lp_raw, fee.denominator, fee.denominator - (fee.pool_numerator + fee.beneficiary_numerator + fee.referrer_numerator));

            uint256 D2 = D0 - math.muldiv(lp_res, D0, lp_supply);
            optional(uint128) new_y_opt = _get_y_D(amp, i, xp_mem, D2);

            if (new_y_opt.hasValue()) {
                result.set(lp_res);
                dy_fee = uint128(math.divc(xp_mem[i] - new_y_opt.get() - dy, tokenData[i].precisionMul));
            }
        }

        return (result, dy_fee);
    }

    function _tokenRoots() internal view returns(address[]) {
        address[] r = new address[](0);
        for (PoolTokenData t: tokenData) {
            r.push(t.root);
        }
        return r;
    }

    function _reserves() internal view returns(uint128[]) {
        uint128[] r = new uint128[](0);
        for (PoolTokenData t: tokenData) {
            r.push(t.balance);
        }
        return r;
    }

    function _sync() internal view {
        emit Sync(_reserves(), lp_supply);
    }

    function _expectedDepositLiquidity(
        uint128[] _amounts,
        uint128[] old_balances,
        uint128 old_lp_supply,
        address referrer
    ) private view returns(optional(DepositLiquidityResultV2), uint128[]) {
        optional(DepositLiquidityResultV2) result;

        optional(uint256) D0_opt = _get_D(_xp_mem(old_balances));

        uint128[] new_balances = old_balances;
        uint128[] pool_fees = new uint128[](N_COINS);
        uint128[] beneficiary_fees = new uint128[](N_COINS);
        uint128[] referrer_fees = new uint128[](N_COINS);
        uint128[] result_balances = old_balances;
        uint128[] differences = new uint128[](N_COINS);
        uint128 lp_reward;
        bool[] sell = new bool[](N_COINS);

        bool hasZeroBalance = false;
        for (uint8 i = 0; i < N_COINS; i++) {
            hasZeroBalance = hasZeroBalance || _amounts[i] == 0;
            new_balances[i] += _amounts[i];

            //default
            differences[i] = 0;
            pool_fees[i] = 0;
            beneficiary_fees[i] = 0;
            referrer_fees[i] = 0;
            sell[i] = false;
        }

        optional(uint256) D1_opt = _get_D(_xp_mem(new_balances));

        //  # dev: initial deposit requires all coins
        if (old_lp_supply == 0 && hasZeroBalance || !D0_opt.hasValue() || !D1_opt.hasValue()) {
            return (result, referrer_fees);
        }

        uint256 D0 = D0_opt.get();
        uint256 D1 = D1_opt.get();

        if (D0 >= D1) {
            return (result, referrer_fees);
        }

        optional(uint256) D2_opt;

        if (old_lp_supply > 0) {
            uint128 fee_numerator = math.muldiv(fee.pool_numerator + fee.beneficiary_numerator + fee.referrer_numerator, N_COINS, (4 * (N_COINS - 1)));

            for (uint8 i = 0; i < N_COINS; i++) {
                uint128 ideal_balance = uint128(math.muldiv(D1, old_balances[i], D0));
                uint128 new_balance = new_balances[i];
                uint128 difference = ideal_balance > new_balance ? ideal_balance - new_balance : new_balance - ideal_balance;
                sell[i] = ideal_balance < new_balance;

                uint128 fees = math.muldivc(fee_numerator, difference, fee.denominator);
                uint128 referrer_fee = math.muldiv(fees, fee.referrer_numerator, fee.beneficiary_numerator + fee.pool_numerator + fee.referrer_numerator);

                if (referrer.value != 0 && (
                    !fee.referrer_threshold.exists(tokenData[i].root) ||
                    fee.referrer_threshold[tokenData[i].root] <= referrer_fee
                )) {
                    referrer_fees[i] = referrer_fee;
                    pool_fees[i] = math.muldivc(fees, fee.pool_numerator, fee.beneficiary_numerator + fee.pool_numerator + fee.referrer_numerator);
                    beneficiary_fees[i] =  fees - referrer_fee - pool_fees[i];
                } else {
                    pool_fees[i] = math.muldivc(fees, fee.pool_numerator, fee.beneficiary_numerator + fee.pool_numerator);
                    beneficiary_fees[i] = fees - pool_fees[i];
                }

                result_balances[i] = new_balance - beneficiary_fees[i] - referrer_fees[i];
                new_balances[i] = new_balances[i] - pool_fees[i] - beneficiary_fees[i] - referrer_fees[i];
                differences[i] = difference;
            }
            D2_opt = _get_D(_xp_mem(new_balances));
            if (D2_opt.hasValue()) {
                lp_reward = uint128(math.muldiv(old_lp_supply, (D2_opt.get() - D0), D0));
            }
        } else {
            D2_opt.set(D1);
            result_balances = new_balances;
            uint256 lp_precision = uint256(10) ** LP_DECIMALS;
            if (PRECISION > lp_precision) {
                lp_reward = uint128(math.muldiv(D1, lp_precision, PRECISION));
            } else {
                lp_reward = uint128(D1 * uint256(10) ** (LP_DECIMALS - MAX_DECIMALS));
            }
        }

        if (!D2_opt.hasValue() || lp_reward == 0) {
            return (result, referrer_fees);
        }

        result.set(DepositLiquidityResultV2(
                old_balances,
                _amounts,
                lp_reward,
                result_balances,
                uint128(D1),
                differences,
                sell,
                pool_fees,
                beneficiary_fees
            ));

        return (result, referrer_fees);

    }

    function _expectedOneCoinDepositLiquidity(
        uint128 _amount,
        uint8 i,
        uint128[] old_balances,
        uint128 old_lp_supply,
        address referrer
    ) private view returns(optional(DepositLiquidityResultV2), uint128[] expected_referrer_fees) {
        optional(DepositLiquidityResultV2) result;

        optional(uint256) D0_opt = _get_D(_xp_mem(old_balances));

        uint128[] new_balances = old_balances;
        uint128[] pool_fees = new uint128[](N_COINS);
        uint128[] beneficiary_fees = new uint128[](N_COINS);
        uint128[] referrer_fees = new uint128[](N_COINS);
        uint128[] result_balances = old_balances;
        uint128[] differences = new uint128[](N_COINS);
        uint128[] amounts = new uint128[](N_COINS);
        uint128 lp_reward;
        bool[] sell = new bool[](N_COINS);

        new_balances[i] += _amount;
        amounts[i] = _amount;

        optional(uint256) D1_opt = _get_D(_xp_mem(new_balances));

        //  # dev: initial deposit requires all coins
        if (old_lp_supply == 0 || _amount == 0 || !D0_opt.hasValue() || !D1_opt.hasValue()) {
            return (result, referrer_fees);
        }

        uint256 D0 = D0_opt.get();
        uint256 D1 = D1_opt.get();

        if (D0 >= D1) {
            return (result, referrer_fees);
        }

        optional(uint256) D2_opt;

        for (uint8 j = 0; j < N_COINS; j++) {
            uint128 ideal_balance = uint128(math.muldiv(D1, old_balances[j], D0));
            uint128 new_balance = new_balances[j];
            uint128 difference = ideal_balance > new_balance ? ideal_balance - new_balance : new_balance - ideal_balance;
            differences[i] = difference;
            sell[i] = ideal_balance < new_balance;
        }

        uint128 fee_numerator = fee.beneficiary_numerator + fee.pool_numerator + fee.referrer_numerator;
        uint128 fees = math.muldivc(fee_numerator, _amount, fee.denominator);
        uint128 referrer_fee = math.muldiv(fees, fee.referrer_numerator, fee_numerator);

        if (referrer.value != 0 && (
            !fee.referrer_threshold.exists(tokenData[i].root) ||
            fee.referrer_threshold[tokenData[i].root] <= referrer_fee
        )) {
            referrer_fees[i] = referrer_fee;
            pool_fees[i] = math.muldivc(fees, fee.pool_numerator, fee_numerator);
            beneficiary_fees[i] = fees - referrer_fee - pool_fees[i];
        } else {
            pool_fees[i] = math.muldivc(fees, fee.pool_numerator, fee.beneficiary_numerator + fee.pool_numerator);
            beneficiary_fees[i] = fees - pool_fees[i];
        }

        result_balances[i] = new_balances[i] - beneficiary_fees[i] - referrer_fees[i];
        new_balances[i] = new_balances[i] - pool_fees[i] - beneficiary_fees[i] - referrer_fees[i];

        D2_opt = _get_D(_xp_mem(new_balances));
        if (D2_opt.hasValue()) {
            lp_reward = uint128(math.muldiv(old_lp_supply, (D2_opt.get() - D0), D0));
        }

        if (!D2_opt.hasValue() || lp_reward == 0) {
            return (result, referrer_fees);
        }

        result.set(DepositLiquidityResultV2(
                old_balances,
                amounts,
                lp_reward,
                result_balances,
                uint128(D1),
                differences,
                sell,
                pool_fees,
                beneficiary_fees
            ));

        return (result, referrer_fees);
    }

    function _applyAddLiquidity(
        DepositLiquidityResultV2 r,
        uint128[] referrer_fees,
        uint64 call_id,
        bool via_account,
        address sender_address,
        address recipient,
        address referrer,
        uint128 referrer_value,
        address original_gas_to
    ) private {

        TokenOperation[] spent_tokens;
        TokenOperation[] receive_tokens;
        ExchangeFee[] fees;
        TokenOperation[] referrer_fees_data;
        TokenOperation[] amounts;

        bool is_zero_referrer_fees = true;
        for (uint8 i = 0; i < N_COINS; i++) {
            amounts.push(TokenOperation(r.amounts[i], tokenData[i].root));
            if (r.differences[i] > 0) {
                fees.push(ExchangeFee(tokenData[i].root, r.pool_fees[i], r.beneficiary_fees[i], fee.beneficiary));
                if (r.sell[i]) {
                    spent_tokens.push(TokenOperation(r.differences[i], tokenData[i].root));
                } else {
                    receive_tokens.push(TokenOperation(r.differences[i], tokenData[i].root));
                }
            }

            tokenData[i].balance = r.result_balances[i];
            tokenData[i].accumulatedFee += r.beneficiary_fees[i];

            referrer_fees_data.push(TokenOperation(referrer_fees[i], tokenData[i].root));

            if (referrer_fees[i] > 0) {
                is_zero_referrer_fees = false;

                IDexTokenVault(_expectedTokenVaultAddress(tokenData[i].root)).referralFeeTransfer{
                    value: referrer_value,
                    flag: 0
                }(
                    referrer_fees[i],
                    referrer,
                    original_gas_to,
                    _tokenRoots()
                );
            }
        }

        lp_supply += r.lp_reward;

        emit DepositLiquidityV2(sender_address, recipient, amounts, fees, spent_tokens, receive_tokens, r.lp_reward);
        if (!is_zero_referrer_fees) {
            emit ReferrerFees(referrer_fees_data);
        }

        IDexPairOperationCallback(sender_address).dexPairDepositLiquiditySuccessV2{
            value: DexGas.OPERATION_CALLBACK_BASE + 2,
            flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
            bounce: false
        }(call_id, via_account, r);

        if (recipient != sender_address) {
            IDexPairOperationCallback(recipient).dexPairDepositLiquiditySuccessV2{
                value: DexGas.OPERATION_CALLBACK_BASE,
                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                bounce: false
            }(call_id, via_account, r);
        }
    }

    function _get_y_D(AmplificationCoefficient A_, uint8 i, uint256[] _xp, uint256 D) internal view returns(optional(uint128)) {
        optional(uint128) result;
        if (i >= N_COINS) {
            return result;
        }

        uint256 Ann = A_.value * N_COINS;
        uint256 c = D;
        uint256 S = 0;
        uint256 _x = 0;

        for (uint8 _i = 0; _i < N_COINS; _i++) {
            if (_i == i) {
                continue;
            }
            _x = _xp[_i];
            S += _x;
            c = math.muldiv(c, D, _x * N_COINS);
        }

        c = math.muldiv(c, D * A_.precision, (Ann * N_COINS));
        uint256 b = S + math.muldiv(D, A_.precision, Ann);
        uint256 y_prev = 0;
        uint256 y = D;

        for (uint8 _i = 0; _i <= 255; _i++) {
            y_prev = y;
            y = (y*y + c) / (2 * y + b - D);
            if ((y > y_prev ? (y - y_prev) : (y_prev - y)) <= 1) {
                result.set(uint128(y));
                break;
            }
        }

        return result;
    }

    function _expectedWithdrawLiquidity(uint128 token_amount) internal view returns(optional(WithdrawResultV2)) {
        optional(WithdrawResultV2) result;

        if (lp_supply == 0) {
            return result;
        }

        uint128[] pool_fees = new uint128[](N_COINS);
        uint128[] beneficiary_fees = new uint128[](N_COINS);
        uint128[] differences = new uint128[](N_COINS);
        bool[] sell = new bool[](N_COINS);

        uint128[] old_balances = _reserves();

        uint128[] withdraw_amounts = new uint128[](0);
        uint128[] result_balances = new uint128[](0);

        for (uint8 i = 0; i < N_COINS; i++) {
            uint128 amount = math.muldiv(old_balances[i], token_amount, lp_supply);
            withdraw_amounts.push(amount);
            result_balances.push(old_balances[i] - amount);
        }

        result.set(WithdrawResultV2(
            token_amount,
            old_balances,
            withdraw_amounts,
            result_balances,
            uint128(_get_D(_xp_mem(result_balances)).get()),
            differences,
            sell,
            pool_fees,
            beneficiary_fees
        ));

        return result;
    }

    function _expectedWithdrawLiquidityOneCoin(
        uint128 token_amount,
        uint8 i,
        uint128[] old_balances,
        uint128 old_lp_supply,
        address referrer
    ) internal view returns(optional(WithdrawResultV2), uint128[]) {
        AmplificationCoefficient amp = A;

        optional(WithdrawResultV2) result;

        uint128[] pool_fees = new uint128[](N_COINS);
        uint128[] beneficiary_fees = new uint128[](N_COINS);
        uint128[] referrer_fees = new uint128[](N_COINS);

        uint128[] differences = new uint128[](N_COINS);
        bool[] sell = new bool[](N_COINS);
        uint128[] amounts = new uint128[](N_COINS);

        uint256[] xp_mem = _xp_mem(old_balances);

        uint128[] result_balances = old_balances;

        optional(uint256) D0_opt = _get_D(xp_mem);
        uint256 D0 = D0_opt.get();

        optional(uint256) D1_opt = D0 - math.muldiv(token_amount, D0, old_lp_supply);
        uint256 D1 = D1_opt.get();

        uint128 lp_fee = math.muldivc(token_amount, fee.beneficiary_numerator + fee.pool_numerator + fee.referrer_numerator, fee.denominator);

        optional(uint256) D1_fee_opt = D0 - math.muldiv(token_amount - lp_fee, D0, old_lp_supply);
        uint256 D1_fee = D1_fee_opt.get();

        optional(uint128) new_y0_opt = _get_y_D(amp, i, xp_mem, D1);
        optional(uint128) new_y_opt = _get_y_D(amp, i, xp_mem, D1_fee);

        if (!new_y_opt.hasValue() || !new_y0_opt.hasValue() || new_y_opt.get() > math.muldiv(xp_mem[i], D1, D0)) {
            return (result, referrer_fees);
        }

        uint128 new_y0 = new_y0_opt.get(); // without fee
        // uint256 dy_0 = (xp_mem[i] - new_y0) / tokenData[i].precisionMul; // without fee

        uint128 new_y = new_y_opt.get();
        uint256 dy = (xp_mem[i] - new_y) / tokenData[i].precisionMul;

        for (uint8 j = 0; j < N_COINS; j++) {
            uint256 dx_expected = 0;
            if (j == i) {
                sell[j] = false;
                dx_expected = (math.muldiv(xp_mem[j], D1, D0) - new_y) / tokenData[j].precisionMul;
            } else {
                sell[j] = true;
                dx_expected = (xp_mem[j] - math.muldiv(xp_mem[j], D1, D0)) / tokenData[j].precisionMul;
            }
            differences[j] = uint128(dx_expected);
        }

        uint128 dy_fee = uint128(math.divc(new_y - new_y0, tokenData[i].precisionMul));
        uint128 fee_numerator = fee.pool_numerator + fee.beneficiary_numerator + fee.referrer_numerator;
        uint128 referrer_fee = math.muldiv(dy_fee, fee.referrer_numerator, fee_numerator);

        if (referrer.value != 0 && (
            !fee.referrer_threshold.exists(tokenData[i].root) ||
            fee.referrer_threshold[tokenData[i].root] <= referrer_fee
        )) {
            referrer_fees[i] = referrer_fee;
            pool_fees[i] = math.muldivc(dy_fee, fee.pool_numerator, fee_numerator);
            beneficiary_fees[i] = dy_fee - referrer_fee - pool_fees[i];
        } else {
            pool_fees[i] = math.muldivc(dy_fee, fee.pool_numerator, fee.beneficiary_numerator + fee.pool_numerator);
            beneficiary_fees[i] = dy_fee - pool_fees[i];
        }

        amounts[i] = uint128(dy);
        result_balances[i] = uint128(old_balances[i] - dy - beneficiary_fees[i] - referrer_fees[i]);

        result.set(WithdrawResultV2(
            token_amount,
            old_balances,
            amounts,
            result_balances,
            uint128(D1),
            differences,
            sell,
            pool_fees,
            beneficiary_fees
        ));

        return (result, referrer_fees);
    }

    function _applyWithdrawLiquidity(
        WithdrawResultV2 r,
        uint128[] referrer_fees,
        uint64 call_id,
        bool via_account,
        address sender_address,
        address recipient,
        address referrer,
        uint128 referrer_value,
        address original_gas_to
    ) private {

        TokenOperation[] spent_tokens;
        TokenOperation[] receive_tokens;
        ExchangeFee[] fees;
        TokenOperation[] referrer_fees_data;
        TokenOperation[] amounts;

        bool is_zero_referrer_fees = true;
        for (uint8 i = 0; i < N_COINS; i++) {
            amounts.push(TokenOperation(r.amounts[i], tokenData[i].root));
            if (r.differences[i] > 0) {
                fees.push(ExchangeFee(tokenData[i].root, r.pool_fees[i], r.beneficiary_fees[i], fee.beneficiary));
                if (r.sell[i]) {
                    spent_tokens.push(TokenOperation(r.differences[i], tokenData[i].root));
                } else {
                    receive_tokens.push(TokenOperation(r.differences[i], tokenData[i].root));
                }
            }

            tokenData[i].balance = r.result_balances[i];
            tokenData[i].accumulatedFee += r.beneficiary_fees[i];

            referrer_fees_data.push(TokenOperation(referrer_fees[i], tokenData[i].root));

            if (referrer_fees[i] > 0) {
                is_zero_referrer_fees = false;

                IDexTokenVault(_expectedTokenVaultAddress(tokenData[i].root)).referralFeeTransfer{
                    value: referrer_value,
                    flag: 0
                }(
                    referrer_fees[i],
                    referrer,
                    original_gas_to,
                    _tokenRoots()
                );
            }
        }

        lp_supply -= r.lp_amount;

        emit WithdrawLiquidityV2(sender_address, recipient, r.lp_amount, amounts, fees, spent_tokens, receive_tokens);
        if (!is_zero_referrer_fees) {
            emit ReferrerFees(referrer_fees_data);
        }

        IDexPairOperationCallback(sender_address).dexPairWithdrawSuccessV2{
            value: DexGas.OPERATION_CALLBACK_BASE + 2,
            flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
            bounce: false
        }(call_id, via_account, r);

        if (sender_address != recipient) {
            IDexPairOperationCallback(recipient).dexPairWithdrawSuccessV2{
                value: DexGas.OPERATION_CALLBACK_BASE,
                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                bounce: false
            }(call_id, via_account, r);
        }
    }
}
