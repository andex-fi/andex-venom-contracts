pragma ever-solidity >= 0.62.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;


import "tip3/contracts/interfaces/ITokenWallet.tsol";
import "tip3/contracts/interfaces/IBurnableByRootTokenRoot.tsol";
import "tip3/contracts/interfaces/IBurnableTokenWallet.tsol";
import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.tsol";

import "./abstract/PairBase.sol";

import "./interfaces/IUpgradableByRequest.sol";
import "./interfaces/IPair.sol";
import "./interfaces/ISuccessCallback.sol";
import "./interfaces/IPairOperationCallback.sol";
import "./interfaces/ITokenVault.sol";

import "./libraries/PlatformTypes.sol";
import "./libraries/Errors.sol";
import "./libraries/Math.sol";
import "./libraries/PairPayload.sol";
import "./libraries/DirectOperationErrors.sol";
import "./libraries/MsgFlag.sol";

import "./structures/IExchangeResult.sol";
import "./structures/IWithdrawResult.sol";
import "./structures/INextExchangeData.sol";

import "./DexPlatform.sol";

/// @title DEX Pair
/// @notice Constant product formulae DEX pair
contract DexPair is PairBase, INextExchangeData {
    // Cant be deployed directly
    constructor() public {
        revert();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // BUILD PAYLOADS

    function buildExchangePayload(
        uint64 id,
        uint128 deploy_wallet_grams,
        uint128 expected_amount
    ) external pure override returns (TvmCell) {
        return PairPayload.buildExchangePayload(
            id,
            deploy_wallet_grams,
            expected_amount
        );
    }

    function buildExchangePayloadV2(
        uint64 _id,
        uint128 _deployWalletGrams,
        uint128 _expectedAmount,
        address _recipient,
        address _referrer,
        optional(TvmCell) _successPayload,
        optional(TvmCell) _cancelPayload
    ) external pure override returns (TvmCell) {
        return PairPayload.buildExchangePayloadV2(
            _id,
            _deployWalletGrams,
            _expectedAmount,
            _recipient,
            address(0),
            _referrer,
            _successPayload,
            _cancelPayload
        );
    }

    function buildDepositLiquidityPayload(
        uint64 id,
        uint128 deploy_wallet_grams
    ) external pure override returns (TvmCell) {
        return PairPayload.buildDepositLiquidityPayload(
            id,
            deploy_wallet_grams
        );
    }

    function buildDepositLiquidityPayloadV2(
        uint64 _id,
        uint128 _deployWalletGrams,
        uint128 _expectedAmount,
        address _recipient,
        address _referrer,
        optional(TvmCell) _successPayload,
        optional(TvmCell) _cancelPayload
    ) external pure override returns (TvmCell) {
        return PairPayload.buildDepositLiquidityPayloadV2(
            _id,
            _deployWalletGrams,
            _expectedAmount,
            _recipient,
            _referrer,
            _successPayload,
            _cancelPayload
        );
    }

    function buildWithdrawLiquidityPayload(
        uint64 id,
        uint128 deploy_wallet_grams
    ) external pure override returns (TvmCell) {
        return PairPayload.buildWithdrawLiquidityPayload(
            id,
            deploy_wallet_grams
        );
    }

    function buildWithdrawLiquidityPayloadV2(
        uint64 _id,
        uint128 _deployWalletGrams,
        uint128 _expectedLeftAmount,
        uint128 _expectedRightAmount,
        address _recipient,
        address _referrer,
        optional(TvmCell) _successPayload,
        optional(TvmCell) _cancelPayload
    ) external pure override returns (TvmCell) {
        return PairPayload.buildWithdrawLiquidityPayloadV2(
            _id,
            _deployWalletGrams,
            [_expectedLeftAmount, _expectedRightAmount],
            _recipient,
            _referrer,
            _successPayload,
            _cancelPayload
        );
    }

    function buildCrossPairExchangePayload(
        uint64 id,
        uint128 deploy_wallet_grams,
        uint128 expected_amount,
        TokenOperation[] steps
    ) external pure override returns (TvmCell) {
        return PairPayload.buildCrossPairExchangePayload(
            id,
            deploy_wallet_grams,
            expected_amount,
            steps
        );
    }

    function buildCrossPairExchangePayloadV2(
        uint64 _id,
        uint128 _deployWalletGrams,
        uint128 _expectedAmount,
        address _outcoming,
        uint32[] _nextStepIndices,
        ExchangeStep[] _steps,
        address _recipient,
        address _referrer,
        optional(TvmCell) _successPayload,
        optional(TvmCell) _cancelPayload
    ) external view returns (TvmCell) {
        address[] pools;

        // Calculate pools' addresses by token roots
        for (uint32 i = 0; i < _steps.length; i++) {
            pools.push(_expectedPoolAddress(_steps[i].roots));
        }

        return PairPayload.buildCrossPairExchangePayloadV2(
            _id,
            _deployWalletGrams,
            _recipient,
            _expectedAmount,
            _outcoming,
            _nextStepIndices,
            _steps,
            pools,
            _referrer,
            _successPayload,
            _cancelPayload
        );
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DEPOSIT LIQUIDITY

    function expectedDepositLiquidity(
        uint128 left_amount,
        uint128 right_amount,
        bool auto_change
    ) override external view responsible returns (DepositLiquidityResult) {
        (DepositLiquidityResult result,,,) = Math.calculateExpectedDepositLiquidity(
            left_amount,
            right_amount,
            auto_change,
            _typeToReserves[ReserveType.POOL][0],
            _typeToReserves[ReserveType.POOL][1],
            _typeToReserves[ReserveType.LP][0],
            _fee,
            address(0),
            _tokenRoots()[0],
            _tokenRoots()[1]
        );

        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } result;
    }

    function depositLiquidity(
        uint64 _callId,
        TokenOperation[] _operations,
        TokenOperation _expected,
        bool _autoChange,
        address _accountOwner,
        uint32,
        address _remainingGasTo,
        address _referrer
    ) override external onlyActive onlyAccount(_accountOwner) {
        require(_expected.root == _lpRoot(), Errors.NOT_LP_TOKEN_ROOT);
        require(_lpReserve() != 0 || (_operations[0].amount > 0 && _operations[1].amount > 0), Errors.WRONG_LIQUIDITY);
        require(
            (_operations[0].amount > 0 && _operations[1].amount > 0) ||
            (_autoChange && (_operations[0].amount + _operations[1].amount > 0)),
            Errors.AMOUNT_TOO_LOW
        );

        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        address[] tokenRoots = _tokenRoots();
        uint128[] tokenReserves = _reserves();

        uint128 referrerValue = _referrer.value != 0 ? Constants.REFERRER_FEE_EXTRA_VALUE : 0;

        TokenOperation[] operations = _operations[0].root == tokenRoots[1] ? [_operations[1], _operations[0]] : _operations;

        (
            DepositLiquidityResult result,
            uint128 step2PoolFee,
            uint128 step2BeneficiaryFee,
            uint128 step2ReferrerFee
        ) = Math.calculateExpectedDepositLiquidity(
            operations[0].amount,
            operations[1].amount,
            _autoChange,
            tokenReserves[0],
            tokenReserves[1],
            _lpReserve(),
            _fee,
            _referrer,
            operations[0].root,
            operations[1].root
        );

        require(result.step_1_lp_reward + result.step_3_lp_reward >= _expected.amount, Errors.WRONG_LIQUIDITY);

        if (_lpReserve() == 0) {
            for (uint i = 0; i < operations.length; i++) {
                _typeToReserves[ReserveType.POOL][i] = operations[i].amount;
            }
        } else {
            if (_autoChange) {
                for (uint i = 0; i < operations.length; i++) {
                    _typeToReserves[ReserveType.POOL][i] += operations[i].amount;
                }

                if (result.step_2_right_to_left) {
                    require(result.step_2_received <= _typeToReserves[ReserveType.POOL][0] + result.step_1_left_deposit, Errors.NOT_ENOUGH_FUNDS);

                    _typeToReserves[ReserveType.POOL][1] -= step2BeneficiaryFee + step2ReferrerFee;
                    _typeToReserves[ReserveType.FEE][1] += step2BeneficiaryFee;
                } else if (result.step_2_left_to_right) {
                    require(result.step_2_received <= _typeToReserves[ReserveType.POOL][1] + result.step_1_right_deposit, Errors.NOT_ENOUGH_FUNDS);

                    _typeToReserves[ReserveType.POOL][0] -= step2BeneficiaryFee + step2ReferrerFee;
                    _typeToReserves[ReserveType.FEE][0] += step2BeneficiaryFee;
                }

                _exchangeBase(
                    _callId,
                    true,
                    result.step_2_left_to_right ? 0 : 1,
                    result.step_2_left_to_right ? 1 : 0,
                    result.step_2_spent,
                    step2BeneficiaryFee,
                    step2PoolFee,
                    step2ReferrerFee,
                    result.step_2_received,
                    _accountOwner,
                    _remainingGasTo,
                    _accountOwner,
                    true,
                    _referrer,
                    referrerValue
                );
            } else {
                _typeToReserves[ReserveType.POOL][0] += result.step_1_left_deposit;
                _typeToReserves[ReserveType.POOL][1] += result.step_1_right_deposit;

                if (result.step_1_left_deposit < operations[0].amount) {
                    IAccount(msg.sender)
                        .internalPoolTransfer{ value: Constants.INTERNAL_PAIR_TRANSFER_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                        (
                            operations[0].amount - result.step_1_left_deposit,
                            tokenRoots[0],
                            _typeToRootAddresses[AddressType.RESERVE],
                            _remainingGasTo
                        );
                }

                if (result.step_1_right_deposit < operations[1].amount) {
                    IAccount(msg.sender)
                        .internalPoolTransfer{ value: Constants.INTERNAL_PAIR_TRANSFER_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                        (
                            operations[1].amount - result.step_1_right_deposit,
                            tokenRoots[1],
                            _typeToRootAddresses[AddressType.RESERVE],
                            _remainingGasTo
                        );
                }
            }
        }

        _depositLiquidityBase(
            _callId,
            true,
            result,
            _accountOwner,
            _accountOwner
        );

        _sync();

        TvmCell empty;

        ITokenRoot(_lpRoot())
            .mint{
                value: Constants.DEPLOY_MINT_VALUE_BASE + Constants.DEPLOY_EMPTY_WALLET_GRAMS,
                flag: MsgFlag.SENDER_PAYS_FEES
            }(
                result.step_1_lp_reward + result.step_3_lp_reward,
                _accountOwner,
                Constants.DEPLOY_EMPTY_WALLET_GRAMS,
                _remainingGasTo,
                _remainingGasTo == _accountOwner,
                empty
            );

        ISuccessCallback(msg.sender)
            .successCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
            (_callId);
    }

    /// @dev Internal deposit liquidity common part
    /// @param _callId ID of the call
    /// @param _isViaAccount Whether or not call was made from DEX account
    /// @param _result Calculated liquidity deposit steps
    /// @param _senderAddress Address of the sender
    function _depositLiquidityBase(
        uint64 _callId,
        bool _isViaAccount,
        DepositLiquidityResult _result,
        address _senderAddress,
        address _recipient
    ) private {
        uint128[] oldReserves = _reserves();

        _typeToReserves[ReserveType.LP][0] += _result.step_1_lp_reward + _result.step_3_lp_reward;

        _write(
            oldReserves[0],
            oldReserves[1],
            now
        );

        if (_result.step_1_lp_reward > 0) {
            TokenOperation[] step1Operations;

            step1Operations.push(
                TokenOperation(
                    _result.step_1_left_deposit,
                    _tokenRoots()[0]
                )
            );

            step1Operations.push(
                TokenOperation(
                    _result.step_1_right_deposit,
                    _tokenRoots()[1]
                )
            );

            emit DepositLiquidity(
                _senderAddress,
                _recipient,
                step1Operations,
                _result.step_1_lp_reward
            );
        }

        if (_result.step_3_lp_reward > 0) {
            TokenOperation[] step3Operations;

            step3Operations.push(
                TokenOperation(
                    _result.step_3_left_deposit,
                    _tokenRoots()[0]
                )
            );

            step3Operations.push(
                TokenOperation(
                    _result.step_3_right_deposit,
                    _tokenRoots()[1]
                )
            );

            emit DepositLiquidity(
                _senderAddress,
                _recipient,
                step3Operations,
                _result.step_3_lp_reward
            );
        }

        IPairOperationCallback(_senderAddress)
            .dexPairDepositLiquiditySuccess{
                value: Constants.OPERATION_CALLBACK_BASE + 2,
                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                bounce: false
            }(
                _callId,
                _isViaAccount,
                _result
            );

        if (_recipient != _senderAddress) {
            IPairOperationCallback(_recipient)
                .dexPairDepositLiquiditySuccess{
                    value: Constants.OPERATION_CALLBACK_BASE,
                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                    bounce: false
                }(
                    _callId,
                    _isViaAccount,
                    _result
                );
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Withdraw liquidity

    function _withdrawLiquidityBase(
        uint128 _lpAmount,
        address _sender
    ) private returns (TokenOperation[]) {
        uint128 leftBackAmount =  math.muldiv(
            _reserves()[0],
            _lpAmount,
            _lpReserve()
        );

        uint128 rightBackAmount = math.muldiv(
            _reserves()[1],
            _lpAmount,
            _lpReserve()
        );

        // Update reserves
        _typeToReserves[ReserveType.POOL][0] -= leftBackAmount;
        _typeToReserves[ReserveType.POOL][1] -= rightBackAmount;
        _typeToReserves[ReserveType.LP][0] -= _lpAmount;

        // Save operations
        TokenOperation[] operations = new TokenOperation[](0);

        operations.push(
            TokenOperation(
                leftBackAmount,
                _tokenRoots()[0]
            )
        );

        operations.push(
            TokenOperation(
                rightBackAmount,
                _tokenRoots()[1]
            )
        );

        // Emit event
        emit WithdrawLiquidity(
            _sender,
            _sender,
            _lpAmount,
            operations
        );

        return operations;
    }

    function expectedWithdrawLiquidity(
        uint128 lp_amount
    ) override external view responsible returns (
        uint128 expected_left_amount,
        uint128 expected_right_amount
    ) {
        uint128 leftBackAmount = math.muldiv(
            _reserves()[0],
            lp_amount,
            _lpReserve()
        );

        uint128 rightBackAmount = math.muldiv(
            _reserves()[1],
            lp_amount,
            _lpReserve()
        );

        return {
            value: 0,
            bounce: false,
            flag: MsgFlag.REMAINING_GAS
        } (
            leftBackAmount,
            rightBackAmount
        );
    }

    function withdrawLiquidity(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation[] _expected,
        address _accountOwner,
        uint32,
        address _remainingGasTo
    ) override external onlyActive onlyAccount(_accountOwner) {
        require(_operation.root == _lpRoot(), Errors.NOT_LP_TOKEN_ROOT);

        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        TokenOperation[] expected = _expected[0].root == _tokenRoots()[1] ? [_expected[1], _expected[0]] : _expected;

        uint128 leftBackAmount =  math.muldiv(_reserves()[0], _operation.amount, _lpReserve());
        uint128 rightBackAmount = math.muldiv(_reserves()[1], _operation.amount, _lpReserve());
        require(leftBackAmount >= expected[0].amount && rightBackAmount >= expected[1].amount, Errors.WRONG_LIQUIDITY);

        TvmCell empty;

        _withdrawBase(
            _callId,
            true,
            _operation.amount,
            _accountOwner,
            _accountOwner,
            _remainingGasTo,
            0,
            false,
            empty
        );

        _sync();

        IBurnableByRootTokenRoot(_lpRoot())
            .burnTokens{ value: Constants.BURN_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
            (
                _operation.amount,
                _expectedTokenVaultAddress(_lpRoot()),
                _remainingGasTo,
                address.makeAddrStd(0, 0),
                empty
            );

        ISuccessCallback(msg.sender)
            .successCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
            (_callId);
    }

    /// @dev Internal withdraw liquidity common part
    /// @param _callId ID of the call
    /// @param _isViaAccount Whether or not call was made from DEX account
    /// @param _lpAmount Amount of LP tokens to withdraw
    /// @param _senderAddress Address of the sender
    /// @param _remainingGasTo Receiver of the remaining gas
    /// @param _deployWalletGrams Amount for a new wallet deploy
    /// @param _notifySuccess Whether or not notify sender about success withdrawal
    /// @param _successPayload Payload for success callback
    function _withdrawBase(
        uint64 _callId,
        bool _isViaAccount,
        uint128 _lpAmount,
        address _senderAddress,
        address _recipient,
        address _remainingGasTo,
        uint128 _deployWalletGrams,
        bool _notifySuccess,
        TvmCell _successPayload
    ) private {
        uint128[] oldReserves = _reserves();

        TokenOperation[] operations = _withdrawLiquidityBase(_lpAmount, _senderAddress);

        _write(
            oldReserves[0],
            oldReserves[1],
            now
        );

        IWithdrawResult.WithdrawResult result = IWithdrawResult.WithdrawResult(
            _lpAmount,
            operations[0].amount,
            operations[1].amount
        );

        IPairOperationCallback(_senderAddress)
            .dexPairWithdrawSuccess{
                value: Constants.OPERATION_CALLBACK_BASE + 3,
                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                bounce: false
            }(
                _callId,
                _isViaAccount,
                result
            );

        if (_recipient != _senderAddress) {
            IPairOperationCallback(_recipient)
                .dexPairWithdrawSuccess{
                    value: Constants.OPERATION_CALLBACK_BASE,
                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                    bounce: false
                }(
                    _callId,
                    _isViaAccount,
                    result
                );
        }

        for (TokenOperation op : operations) {
            if (op.amount > 0) {
                if (_isViaAccount) {
                    IAccount(msg.sender)
                        .internalPoolTransfer{ value: Constants.INTERNAL_PAIR_TRANSFER_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                        (
                            op.amount,
                            op.root,
                            _tokenRoots(),
                            _remainingGasTo
                        );
                } else {
                    ITokenVault(_expectedTokenVaultAddress(op.root))
                        .transfer{
                            value: Constants.VAULT_TRANSFER_BASE_VALUE_V2 + _deployWalletGrams,
                            flag: MsgFlag.SENDER_PAYS_FEES
                        }(
                            op.amount,
                            _recipient,
                            _deployWalletGrams,
                            _notifySuccess,
                            _successPayload,
                            _typeToRootAddresses[AddressType.RESERVE],
                            _currentVersion,
                            _remainingGasTo
                        );
                }
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Exchange

    function expectedExchange(
        uint128 amount,
        address spent_token_root
    ) override external view responsible returns (
        uint128 expected_amount,
        uint128 expected_fee
    ) {
        uint8 spentTokenIndex = spent_token_root == _tokenRoots()[0] ? 0 : 1;
        uint8 receiveTokenIndex = spent_token_root == _tokenRoots()[0] ? 1 : 0;

        if (
            spent_token_root == _tokenRoots()[0] ||
            spent_token_root == _tokenRoots()[1]
        ) {
            (
                uint128 expectedAmount,
                uint128 poolFee,
                uint128 beneficiaryFee,
            ) = Math.calculateExpectedExchange(
                amount,
                _reserves()[spentTokenIndex],
                _reserves()[receiveTokenIndex],
                _fee,
                address(0),
                _tokenRoots()[spentTokenIndex]
            );

            return {
                value: 0,
                bounce: false,
                flag: MsgFlag.REMAINING_GAS
            } (
                expectedAmount,
                poolFee + beneficiaryFee
            );
        } else {
            revert(Errors.NOT_TOKEN_ROOT);
        }
    }

    function expectedSpendAmount(
        uint128 receive_amount,
        address receive_token_root
    ) override external view responsible returns (
        uint128 expected_amount,
        uint128 expected_fee
    ) {
        uint8 spentTokenIndex = receive_token_root == _tokenRoots()[1] ? 0 : 1;
        uint8 receiveTokenIndex = receive_token_root == _tokenRoots()[1] ? 1 : 0;

        if (
            receive_token_root == _tokenRoots()[0] ||
            receive_token_root == _tokenRoots()[1]
        ) {
            return {
                value: 0,
                bounce: false,
                flag: MsgFlag.REMAINING_GAS
            } Math.calculateExpectedSpendAmount(
                receive_amount,
                _reserves()[spentTokenIndex],
                _reserves()[receiveTokenIndex],
                _fee
            );
        } else {
            revert(Errors.NOT_TOKEN_ROOT);
        }
    }

    function exchange(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation _expected,
        address _accountOwner,
        uint32,
        address _remainingGasTo
    ) override external onlyActive onlyAccount(_accountOwner) {
        if (
            (_operation.root == _tokenRoots()[0] && _expected.root == _tokenRoots()[1]) ||
            (_operation.root == _tokenRoots()[1] && _expected.root == _tokenRoots()[0])
        ) {
            uint8 spentTokenIndex = _operation.root == _tokenRoots()[0] ? 0 : 1;
            uint8 receiveTokenIndex = _operation.root == _tokenRoots()[0] ? 1 : 0;

            (
                uint128 amount,
                uint128 poolFee,
                uint128 beneficiaryFee,
                uint128 referrerFee
            ) = Math.calculateExpectedExchange(
                _operation.amount,
                _reserves()[spentTokenIndex],
                _reserves()[receiveTokenIndex],
                _fee,
                address(0),
                _tokenRoots()[spentTokenIndex]
            );

            require(amount <= _reserves()[receiveTokenIndex], Errors.NOT_ENOUGH_FUNDS);
            require(amount >= _expected.amount, Errors.LOW_EXCHANGE_RATE);
            require(amount > 0, Errors.AMOUNT_TOO_LOW);
            require(poolFee > 0 || _fee.pool_numerator == 0, Errors.AMOUNT_TOO_LOW);
            require(beneficiaryFee > 0 || _fee.beneficiary_numerator == 0, Errors.AMOUNT_TOO_LOW);

            tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

            _exchangeBase(
                _callId,
                true,
                spentTokenIndex,
                receiveTokenIndex,
                _operation.amount,
                beneficiaryFee,
                poolFee,
                referrerFee,
                amount,
                _accountOwner,
                _remainingGasTo,
                _accountOwner,
                false,
                address(0),
                0
            );

            _sync();

            IAccount(msg.sender)
                .internalPoolTransfer{ value: Constants.INTERNAL_PAIR_TRANSFER_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                (
                    amount,
                    _tokenRoots()[receiveTokenIndex],
                    _tokenRoots(),
                    _remainingGasTo
                );

            ISuccessCallback(msg.sender)
                .successCallback{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                (_callId);
        } else {
            revert(Errors.NOT_TOKEN_ROOT);
        }
    }

    /// @dev Internal exchange common part
    /// @param _callId ID of the call
    /// @param _isViaAccount Whether or not call was made from DEX account
    /// @param _spentAmount Amount for exchange
    /// @param _beneficiaryFee Calculated fee for beneficiary
    /// @param _poolFee Calculated fee for liquidity providers
    /// @param _amount Amount to exchange
    /// @param _senderAddress Address of the sender
    /// @param _remainingGasTo Receiver of the remaining gas
    function _exchangeBase(
        uint64 _callId,
        bool _isViaAccount,
        uint8 spentTokenIndex,
        uint8 receiveTokenIndex,
        uint128 _spentAmount,
        uint128 _beneficiaryFee,
        uint128 _poolFee,
        uint128 _referrerFee,
        uint128 _amount,
        address _senderAddress,
        address _remainingGasTo,
        address _recipient,
        bool _isNominal,
        address _referrer,
        uint128 _referrerValue
    ) private {
        uint128[] oldReserves = _reserves();

        // Update reserves
        _typeToReserves[ReserveType.POOL][spentTokenIndex] += _isNominal ? 0 : _spentAmount - _beneficiaryFee - _referrerFee;
        _typeToReserves[ReserveType.POOL][receiveTokenIndex] -= _isNominal ? 0 : _amount;

        if (!_isViaAccount || !_isNominal) {
            // Update accumulated fees
            if (_beneficiaryFee > 0) {
                _typeToReserves[ReserveType.FEE][spentTokenIndex] += _beneficiaryFee;

                _processBeneficiaryFees(false, _remainingGasTo);
            }
        }

        if (_referrerFee > 0) {
            ITokenVault(_expectedTokenVaultAddress(_tokenRoots()[spentTokenIndex]))
                .referralFeeTransfer{
                    value: _referrerValue,
                    flag: 0
                }(
                    _referrerFee,
                    _referrer,
                    _remainingGasTo,
                    _tokenRoots()
                );

            emit ReferrerFees([TokenOperation(_referrerFee, _tokenRoots()[spentTokenIndex])]);
        }

        ExchangeFee[] fees;

        fees.push(
            ExchangeFee(
                _tokenRoots()[spentTokenIndex],
                _poolFee,
                _beneficiaryFee,
                _fee.beneficiary
            )
        );

        // Emit event
        emit Exchange(
            _senderAddress,
            _recipient,
            _tokenRoots()[spentTokenIndex],
            _spentAmount,
            _tokenRoots()[receiveTokenIndex],
            _amount,
            fees
        );

        _write(
            oldReserves[0],
            oldReserves[1],
            now
        );

        IExchangeResult.ExchangeResult result =  IExchangeResult.ExchangeResult(
            spentTokenIndex == 0 && receiveTokenIndex == 1,
            _spentAmount,
            _poolFee + _beneficiaryFee + _referrerFee,
            _amount
        );

        IPairOperationCallback(_senderAddress)
            .dexPairExchangeSuccess{
                value: Constants.OPERATION_CALLBACK_BASE + 1,
                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                bounce: false
            }(
                _callId,
                _isViaAccount,
                result
            );

        if (_recipient != _senderAddress) {
            IPairOperationCallback(_recipient)
                .dexPairExchangeSuccess{
                    value: Constants.OPERATION_CALLBACK_BASE,
                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                    bounce: false
                }(
                    _callId,
                    _isViaAccount,
                    result
                );
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Cross-pair exchange

    function crossPoolExchange(
        uint64 _id,
        uint32,
        uint8,
        address[] _prevPoolTokenRoots,
        uint8 _op,
        address _spentTokenRoot,
        uint128 _spentAmount,
        address _senderAddress,
        address _recipient,
        address _referrer,
        address _remainingGasTo,
        uint128 _deployWalletGrams,
        TvmCell _payload,
        bool _notifySuccess,
        TvmCell _successPayload,
        bool _notifyCancel,
        TvmCell _cancelPayload
    ) override external onlyPoolOrTokenVault(_prevPoolTokenRoots, _spentTokenRoot) onlyActive notSelfCall {
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        // Decode data from payload
        (
            uint128 expectedAmount,
            /*address outcoming*/,
            NextExchangeData[] nextSteps
        ) = PairPayload.decodeCrossPoolExchangePayload(_payload, _op);

        uint8 spentTokenIndex = _spentTokenRoot == _tokenRoots()[0] ? 0 : 1;
        uint8 receiveTokenIndex = _spentTokenRoot == _tokenRoots()[0] ? 1 : 0;

        if (_op == OperationTypes.CROSS_PAIR_EXCHANGE && nextSteps.length > 0) {
            // actually poolRoot is a tokenRoot here, so
            nextSteps[0].poolRoot = _expectedPoolAddress([_tokenRoots()[receiveTokenIndex], nextSteps[0].poolRoot]);
        }

        uint128 referrerValue = _referrer.value != 0 ? Constants.REFERRER_FEE_EXTRA_VALUE : 0;

        if (
            _spentTokenRoot == _tokenRoots()[0] ||
            _spentTokenRoot == _tokenRoots()[1]
        ) {
            uint16 errorCode = !_active ? DirectOperationErrors.NOT_ACTIVE
                : msg.sender == address(this) ? DirectOperationErrors.WRONG_PREVIOUS_POOL
                : 0;

            if (errorCode == 0) {
                // Calculate exchange result
                (
                    uint128 amount,
                    uint128 poolFee,
                    uint128 beneficiaryFee,
                    uint128 referrerFee
                ) = Math.calculateExpectedExchange(
                    _spentAmount,
                    _reserves()[spentTokenIndex],
                    _reserves()[receiveTokenIndex],
                    _fee,
                    _referrer,
                    _tokenRoots()[spentTokenIndex]
                );

                // Check reserves, fees and expected amount
                if (
                    amount > _reserves()[receiveTokenIndex] ||
                    amount == 0 ||
                    poolFee == 0 && _fee.pool_numerator > 0 ||
                    beneficiaryFee == 0 && _fee.beneficiary_numerator > 0 && poolFee == 0
                ) {
                    errorCode = DirectOperationErrors.INVALID_RECEIVED_AMOUNT;
                } else if (amount < expectedAmount) {
                    errorCode = DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;
                } else {
                    // Process exchange
                    _exchangeBase(
                        _id,
                        false,
                        spentTokenIndex,
                        receiveTokenIndex,
                        _spentAmount,
                        beneficiaryFee,
                        poolFee,
                        referrerFee,
                        amount,
                        _senderAddress,
                        _remainingGasTo,
                        _recipient,
                        false,
                        _referrer,
                        referrerValue
                    );

                    uint16 postSwapErrorCode = 0;

                    uint256 denominator = 0;
                    uint32 allNestedNodes = uint32(nextSteps.length);
                    uint32 allLeaves = 0;
                    uint32 maxNestedNodes = 0;
                    uint32 maxNestedNodesIdx = 0;
                    for (uint32 i = 0; i < nextSteps.length; i++) {
                        NextExchangeData nextStep = nextSteps[i];
                        if (nextStep.poolRoot.value == 0 || nextStep.poolRoot == address(this) ||
                            nextStep.numerator == 0 || nextStep.leaves == 0) {

                            postSwapErrorCode = DirectOperationErrors.INVALID_NEXT_STEPS;
                            break;
                        }
                        if (nextStep.nestedNodes > maxNestedNodes) {
                            maxNestedNodes = nextStep.nestedNodes;
                            maxNestedNodesIdx = i;
                        }
                        denominator += nextStep.numerator;
                        allNestedNodes += nextStep.nestedNodes;
                        allLeaves += nextStep.leaves;
                    }

                    if (postSwapErrorCode == 0 && msg.value < (Constants.CROSS_POOL_EXCHANGE_MIN_VALUE + referrerValue) * (1 + allNestedNodes)) {
                        postSwapErrorCode = DirectOperationErrors.VALUE_TOO_LOW;
                    }

                    if (postSwapErrorCode == 0 && nextSteps.length > 0) {
                        // Continue cross-pair exchange
                        uint128 extraValue = msg.value - (Constants.CROSS_POOL_EXCHANGE_MIN_VALUE + referrerValue) * (1 + allNestedNodes);

                        for (uint32 i = 0; i < nextSteps.length; i++) {
                            NextExchangeData nextStep = nextSteps[i];

                            uint128 nextPoolAmount = uint128(math.muldiv(amount, nextStep.numerator, denominator));
                            uint128 currentExtraValue = math.muldiv(uint128(nextStep.leaves), extraValue, uint128(allLeaves));

                            IBasePool(nextStep.poolRoot).crossPoolExchange{
                                value: i == maxNestedNodesIdx ? 0 : (nextStep.nestedNodes + 1) * (Constants.CROSS_POOL_EXCHANGE_MIN_VALUE + referrerValue) + currentExtraValue,
                                flag: i == maxNestedNodesIdx ? MsgFlag.ALL_NOT_RESERVED : MsgFlag.SENDER_PAYS_FEES
                            }(
                                _id,
                                _currentVersion,
                                PoolTypes.CONSTANT_PRODUCT,
                                _tokenRoots(),
                                _op,
                                _tokenRoots()[receiveTokenIndex],
                                nextPoolAmount,
                                _senderAddress,
                                _recipient,
                                _referrer,
                                _remainingGasTo,
                                _deployWalletGrams,
                                nextStep.payload,
                                _notifySuccess,
                                _successPayload,
                                _notifyCancel,
                                _cancelPayload
                            );
                        }
                    } else {
                        bool isLastStep = nextSteps.length == 0;

                        if (!isLastStep) {
                            IPairOperationCallback(_senderAddress).dexPairOperationCancelled{
                                value: Constants.OPERATION_CALLBACK_BASE + 44,
                                flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                                bounce: false
                            }(_id);

                            if (_recipient != _senderAddress) {
                                IPairOperationCallback(_recipient).dexPairOperationCancelled{
                                    value: Constants.OPERATION_CALLBACK_BASE,
                                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                                    bounce: false
                                }(_id);
                            }
                        }
                        // Transfer final token to recipient in the case of success or to sender otherwise
                        ITokenVault(_expectedTokenVaultAddress(_tokenRoots()[receiveTokenIndex]))
                            .transfer{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                            (
                                amount,
                                isLastStep ? _recipient : _senderAddress,
                                _deployWalletGrams,
                                isLastStep ? _notifySuccess : _notifyCancel,
                                isLastStep
                                    ? PairPayload.buildSuccessPayload(_op, _successPayload, _senderAddress)
                                    : PairPayload.buildCancelPayload(_op, postSwapErrorCode, _cancelPayload, nextSteps),
                                _tokenRoots(),
                                _currentVersion,
                                _remainingGasTo
                            );
                    }
                }
            }

            if (errorCode != 0) {
                // Send callback about failed cross-pool exchange to user
                IPairOperationCallback(_senderAddress)
                    .dexPairOperationCancelled{
                        value: Constants.OPERATION_CALLBACK_BASE + 44,
                        flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                        bounce: false
                    }(_id);

                if (_recipient != _senderAddress) {
                    IPairOperationCallback(_recipient)
                        .dexPairOperationCancelled{
                            value: Constants.OPERATION_CALLBACK_BASE,
                            flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                            bounce: false
                        }(_id);
                }

                // Refund incoming token to sender
                ITokenVault(_expectedTokenVaultAddress(_spentTokenRoot))
                    .transfer{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                    (
                        _spentAmount,
                        _senderAddress,
                        _deployWalletGrams,
                        _notifyCancel,
                        PairPayload.buildCancelPayload(_op, errorCode, _cancelPayload, nextSteps),
                        _tokenRoots(),
                        _currentVersion,
                        _remainingGasTo
                    );
            } else {
                _sync();
            }
        } else {
            revert(Errors.NOT_TOKEN_ROOT);
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Callbacks

    function onAcceptTokensTransfer(
        address _tokenRoot,
        uint128 _tokensAmount,
        address _senderAddress,
        address _senderWallet,
        address _remainingGasTo,
        TvmCell _payload
    ) override external {
        tvm.rawReserve(Constants.PAIR_INITIAL_BALANCE, 0);

        // Decode base data from payload
        (
            bool isPayloadValid,
            uint8 op,
            uint64 id,
            uint128 deployWalletGrams,
            address recipient,
            uint128[] expectedAmounts,
            /*address outcoming*/,
            NextExchangeData[] nextSteps,
            address referrer
        ) = PairPayload.decodeOnAcceptTokensTransferData(_payload);

        uint128 expectedAmount = expectedAmounts.length == 1 ? expectedAmounts[0] : 0;
        if (expectedAmounts.length == 0) {
            expectedAmounts = new uint128[](2);
        }

        // Set sender as recipient if it's empty
        recipient = recipient.value == 0 ? _senderAddress : recipient;

        // Decode payloads for callbacks
        (
            bool notifySuccess,
            TvmCell successPayload,
            bool notifyCancel,
            TvmCell cancelPayload
        ) = PairPayload.decodeOnAcceptTokensTransferPayloads(_payload, op);

        TvmCell empty;
        uint128 referrerValue = referrer.value != 0 ? Constants.REFERRER_FEE_EXTRA_VALUE : 0;

        uint16 errorCode = _checkOperationData(
            msg.sender,
            msg.value,
            isPayloadValid,
            deployWalletGrams,
            op,
            _tokenRoot,
            referrerValue
        );

        if (errorCode == 0) {
            if (_tokenRoot == _tokenRoots()[0] || _tokenRoot == _tokenRoots()[1]) {
                uint8 spentTokenIndex = _tokenRoot == _typeToRootAddresses[AddressType.RESERVE][0] ? 0 : 1;
                uint8 receiveTokenIndex = _tokenRoot == _typeToRootAddresses[AddressType.RESERVE][0] ? 1 : 0;

                if (op == OperationTypes.EXCHANGE || op == OperationTypes.EXCHANGE_V2) {
                    // Calculate exchange result
                    (
                        uint128 amount,
                        uint128 poolFee,
                        uint128 beneficiaryFee,
                        uint128 referrerFee
                    ) = Math.calculateExpectedExchange(
                        _tokensAmount,
                        _reserves()[spentTokenIndex],
                        _reserves()[receiveTokenIndex],
                        _fee,
                        referrer,
                        _tokenRoots()[spentTokenIndex]
                    );

                    // Check reserves, fees and expected amount
                    if (
                        amount > _reserves()[receiveTokenIndex] ||
                        amount == 0 ||
                        poolFee == 0 && _fee.pool_numerator > 0 ||
                        beneficiaryFee == 0 && _fee.beneficiary_numerator > 0 && poolFee == 0
                    ) {
                        errorCode = DirectOperationErrors.INVALID_RECEIVED_AMOUNT;
                    } else if (amount < expectedAmount) {
                        errorCode = DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;
                    } else {
                        // Process exchange
                        _exchangeBase(
                            id,
                            false,
                            spentTokenIndex,
                            receiveTokenIndex,
                            _tokensAmount,
                            beneficiaryFee,
                            poolFee,
                            referrerFee,
                            amount,
                            _senderAddress,
                            _remainingGasTo,
                            recipient,
                            false,
                            referrer,
                            referrerValue
                        );

                        // Transfer incoming token to token vault
                        ITokenWallet(msg.sender)
                            .transfer{ value: Constants.TRANSFER_TOKENS_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                            (
                                _tokensAmount,
                                _expectedTokenVaultAddress(_tokenRoot),
                                0,
                                _remainingGasTo,
                                false,
                                empty
                            );

                        ITokenVault(_expectedTokenVaultAddress(_tokenRoots()[receiveTokenIndex]))
                            .transfer{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                            (
                                amount,
                                recipient,
                                deployWalletGrams,
                                notifySuccess,
                                PairPayload.buildSuccessPayload(op, successPayload, _senderAddress),
                                _tokenRoots(),
                                _currentVersion,
                                _remainingGasTo
                            );
                    }
                } else if (op == OperationTypes.DEPOSIT_LIQUIDITY || op == OperationTypes.DEPOSIT_LIQUIDITY_V2) {
                    // Calculate deposit result
                    (
                        DepositLiquidityResult r,
                        uint128 step2PoolFee,
                        uint128 step2BeneficiaryFee,
                        uint128 step2ReferrerFee
                    ) = Math.calculateExpectedDepositLiquidity(
                        _tokenRoot == _tokenRoots()[0] ? _tokensAmount : 0,
                        _tokenRoot == _tokenRoots()[1] ? _tokensAmount : 0,
                        true,
                        _reserves()[0],
                        _reserves()[1],
                        _lpReserve(),
                        _fee,
                        referrer,
                        _tokenRoots()[0],
                        _tokenRoots()[1]
                    );

                    // Check reserves, fees and expected amount
                    if (
                        r.step_3_lp_reward == 0 ||
                        r.step_2_received > _reserves()[receiveTokenIndex] ||
                        r.step_2_received == 0 ||
                        step2PoolFee == 0 && _fee.pool_numerator > 0 ||
                        step2BeneficiaryFee == 0 && _fee.beneficiary_numerator > 0
                    ) {
                        errorCode = DirectOperationErrors.INVALID_RECEIVED_AMOUNT;
                    } else if (r.step_3_lp_reward < expectedAmount) {
                        errorCode = DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;
                    } else {
                        _typeToReserves[ReserveType.POOL][spentTokenIndex] += _tokensAmount - step2BeneficiaryFee - step2ReferrerFee;

                        _exchangeBase(
                            id,
                            false,
                            spentTokenIndex,
                            receiveTokenIndex,
                            r.step_2_spent,
                            step2BeneficiaryFee,
                            step2PoolFee,
                            step2ReferrerFee,
                            r.step_2_received,
                            _senderAddress,
                            _remainingGasTo,
                            recipient,
                            true,
                            referrer,
                            referrerValue
                        );

                        _depositLiquidityBase(
                            id,
                            false,
                            r,
                            _senderAddress,
                            recipient
                        );

                        ITokenWallet(msg.sender)
                            .transfer{ value: Constants.TRANSFER_TOKENS_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                            (
                                _tokensAmount,
                                _expectedTokenVaultAddress(_tokenRoot),
                                0,
                                _remainingGasTo,
                                false,
                                empty
                            );

                        ITokenRoot(_lpRoot())
                            .mint{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                            (
                                r.step_3_lp_reward,
                                recipient,
                                deployWalletGrams,
                                _remainingGasTo,
                                notifySuccess,
                                PairPayload.buildSuccessPayload(op, successPayload, _senderAddress)
                            );
                    }
                } else if (op == OperationTypes.CROSS_PAIR_EXCHANGE || op == OperationTypes.CROSS_PAIR_EXCHANGE_V2) {

                    if (nextSteps.length == 0) errorCode = DirectOperationErrors.INVALID_NEXT_STEPS;

                    if (errorCode == 0 && op == OperationTypes.CROSS_PAIR_EXCHANGE) {
                        // actually poolRoot is a tokenRoot here, so
                        nextSteps[0].poolRoot = _expectedPoolAddress([_tokenRoots()[receiveTokenIndex], nextSteps[0].poolRoot]);
                    }

                    // Calculate exchange result
                    (
                        uint128 amount,
                        uint128 poolFee,
                        uint128 beneficiaryFee,
                        uint128 referrerFee
                    ) = Math.calculateExpectedExchange(
                        _tokensAmount,
                        _reserves()[spentTokenIndex],
                        _reserves()[receiveTokenIndex],
                        _fee,
                        referrer,
                        _tokenRoots()[spentTokenIndex]
                    );

                    uint256 denominator = 0;
                    uint32 allNestedNodes = uint32(nextSteps.length);
                    uint32 allLeaves = 0;
                    uint32 maxNestedNodes = 0;
                    uint32 maxNestedNodesIdx = 0;
                    for (uint32 i = 0; i < nextSteps.length; i++) {
                        NextExchangeData nextStep = nextSteps[i];
                        if (nextStep.poolRoot.value == 0 || nextStep.poolRoot == address(this) ||
                            nextStep.numerator == 0 || nextStep.leaves == 0) {

                            errorCode = DirectOperationErrors.INVALID_NEXT_STEPS;
                            break;
                        }
                        if (nextStep.nestedNodes > maxNestedNodes) {
                            maxNestedNodes = nextStep.nestedNodes;
                            maxNestedNodesIdx = i;
                        }
                        denominator += nextStep.numerator;
                        allNestedNodes += nextStep.nestedNodes;
                        allLeaves += nextStep.leaves;
                    }

                    // Check reserves, fees, msg.value and expected amount
                    if (errorCode == 0 && msg.value < (Constants.CROSS_POOL_EXCHANGE_MIN_VALUE + referrerValue) * (1 + allNestedNodes)) {
                        errorCode = DirectOperationErrors.VALUE_TOO_LOW;
                    } else if (
                        amount > _reserves()[receiveTokenIndex] ||
                        amount == 0 ||
                        poolFee == 0 && _fee.pool_numerator > 0 ||
                        beneficiaryFee == 0 && _fee.beneficiary_numerator > 0 && poolFee == 0
                    ) {
                        errorCode = DirectOperationErrors.INVALID_RECEIVED_AMOUNT;
                    } else if (amount < expectedAmount) {
                        errorCode = DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;
                    }

                    if (errorCode == 0) {
                        // Process exchange
                        _exchangeBase(
                            id,
                            false,
                            spentTokenIndex,
                            receiveTokenIndex,
                            _tokensAmount,
                            beneficiaryFee,
                            poolFee,
                            referrerFee,
                            amount,
                            _senderAddress,
                            _remainingGasTo,
                            recipient,
                            false,
                            referrer,
                            referrerValue
                        );

                        // Transfer incoming token to token vault
                        ITokenWallet(msg.sender)
                            .transfer{ value: Constants.TRANSFER_TOKENS_VALUE, flag: MsgFlag.SENDER_PAYS_FEES }
                            (
                                _tokensAmount,
                                _expectedTokenVaultAddress(_tokenRoot),
                                0,
                                _remainingGasTo,
                                false,
                                empty
                            );

                        // Continue cross-pair exchange
                        uint128 extraValue = msg.value - (Constants.CROSS_POOL_EXCHANGE_MIN_VALUE + referrerValue) * (1 + allNestedNodes);

                        for (uint32 i = 0; i < nextSteps.length; i++) {
                            NextExchangeData nextStep = nextSteps[i];

                            uint128 nextPoolAmount = uint128(math.muldiv(amount, nextStep.numerator, denominator));
                            uint128 currentExtraValue = math.muldiv(uint128(nextStep.leaves), extraValue, uint128(allLeaves));

                            IBasePool(nextStep.poolRoot).crossPoolExchange{
                                value: i == maxNestedNodesIdx ? 0 : (nextStep.nestedNodes + 1) * (Constants.CROSS_POOL_EXCHANGE_MIN_VALUE + referrerValue) + currentExtraValue,
                                flag: i == maxNestedNodesIdx ? MsgFlag.ALL_NOT_RESERVED : MsgFlag.SENDER_PAYS_FEES
                            }(
                                id,
                                _currentVersion,
                                PoolTypes.CONSTANT_PRODUCT,
                                _tokenRoots(),
                                op,
                                _tokenRoots()[receiveTokenIndex],
                                nextPoolAmount,
                                _senderAddress,
                                recipient,
                                referrer,
                                _remainingGasTo,
                                deployWalletGrams,
                                nextStep.payload,
                                notifySuccess,
                                successPayload,
                                notifyCancel,
                                cancelPayload
                            );
                        }
                    }
                } else {
                    errorCode = DirectOperationErrors.WRONG_OPERATION_TYPE;
                }
            } else if (op == OperationTypes.WITHDRAW_LIQUIDITY || op == OperationTypes.WITHDRAW_LIQUIDITY_V2) {
                // Calculate withdrawal result
                uint128 leftBackAmount =  math.muldiv(_reserves()[0], _tokensAmount, _lpReserve());
                uint128 rightBackAmount = math.muldiv(_reserves()[1], _tokensAmount, _lpReserve());

                // Check expected amounts
                if (
                    leftBackAmount < expectedAmounts[0] ||
                    rightBackAmount < expectedAmounts[1]
                ) {
                    errorCode = DirectOperationErrors.RECEIVED_AMOUNT_IS_LESS_THAN_EXPECTED;
                } else {
                    _withdrawBase(
                        id,
                        false,
                        _tokensAmount,
                        _senderAddress,
                        recipient,
                        _remainingGasTo,
                        deployWalletGrams,
                        notifySuccess,
                        PairPayload.buildSuccessPayload(op, successPayload, _senderAddress)
                    );

                    // Burn LP tokens
                    IBurnableTokenWallet(msg.sender)
                        .burn{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                        (
                            _tokensAmount,
                            _remainingGasTo,
                            address.makeAddrStd(0, 0),
                            empty
                        );
                }
            } else {
                errorCode = DirectOperationErrors.WRONG_OPERATION_TYPE;
            }
        }

        if (errorCode != 0) {
            // Send callback about failed operation to user
            IPairOperationCallback(_senderAddress)
                .dexPairOperationCancelled{
                    value: Constants.OPERATION_CALLBACK_BASE,
                    flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                    bounce: false
                }(id);

            if (recipient != _senderAddress) {
                IPairOperationCallback(recipient)
                    .dexPairOperationCancelled{
                        value: Constants.OPERATION_CALLBACK_BASE,
                        flag: MsgFlag.SENDER_PAYS_FEES + MsgFlag.IGNORE_ERRORS,
                        bounce: false
                    }(id);
            }

            // Refund incoming token
            ITokenWallet(msg.sender)
                .transferToWallet{ value: 0, flag: MsgFlag.ALL_NOT_RESERVED }
                (
                    _tokensAmount,
                    _senderWallet,
                    _remainingGasTo,
                    notifyCancel,
                    PairPayload.buildCancelPayload(op, errorCode, cancelPayload, nextSteps)
                );
        } else {
            _sync();
        }
    }

    function _checkOperationData(
        address _msgSender,
        uint128 _msgValue,
        bool _isPayloadValid,
        uint128 _deployWalletGrams,
        uint8 op,
        address _tokenRoot,
        uint128 _referrerValue
    ) private view returns (uint16) {

        if (!_active) return DirectOperationErrors.NOT_ACTIVE;
        if (!_isPayloadValid) return DirectOperationErrors.INVALID_PAYLOAD;
        if (_lpReserve() == 0) return DirectOperationErrors.NON_POSITIVE_LP_SUPPLY;
        if (_msgValue < Constants.DIRECT_PAIR_OP_MIN_VALUE_V2 + _deployWalletGrams + _referrerValue) return DirectOperationErrors.VALUE_TOO_LOW;

        if (_tokenRoot == _lpRoot() && _msgSender != _typeToWalletAddresses[AddressType.LP][0]) return DirectOperationErrors.NOT_LP_TOKEN_WALLET;
        if (_tokenRoot != _lpRoot()) {
            address[] roots = _tokenRoots();
            address[] wallets = _typeToWalletAddresses[AddressType.RESERVE];
            if (_tokenRoot != roots[0] && _tokenRoot != roots[1]) return DirectOperationErrors.NOT_TOKEN_ROOT;
            if (_tokenRoot == roots[0] && _msgSender != wallets[0] || _tokenRoot == roots[1] && _msgSender != wallets[1]) return DirectOperationErrors.NOT_TOKEN_WALLET;
        }

        if (!(_msgSender == _typeToWalletAddresses[AddressType.LP][0] && (op == OperationTypes.WITHDRAW_LIQUIDITY || op == OperationTypes.WITHDRAW_LIQUIDITY_V2) ||
            _msgSender != _typeToWalletAddresses[AddressType.LP][0] && (
                op == OperationTypes.DEPOSIT_LIQUIDITY || op == OperationTypes.DEPOSIT_LIQUIDITY_V2 ||
                op == OperationTypes.EXCHANGE || op == OperationTypes.EXCHANGE_V2 ||
                op == OperationTypes.CROSS_PAIR_EXCHANGE || op == OperationTypes.CROSS_PAIR_EXCHANGE_V2
            )
        )) return DirectOperationErrors.WRONG_OPERATION_TYPE;

        if ((op == OperationTypes.WITHDRAW_LIQUIDITY || op == OperationTypes.WITHDRAW_LIQUIDITY_V2) && _msgValue < Constants.DIRECT_PAIR_OP_MIN_VALUE_V2 + 2 * _deployWalletGrams + _referrerValue) {
            return DirectOperationErrors.VALUE_TOO_LOW;
        }

        return 0;
    }
}
