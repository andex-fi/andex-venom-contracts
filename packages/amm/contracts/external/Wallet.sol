pragma ever-solidity >= 0.62.0;

import './Account.sol';
import '../interfaces/IPairOperationCallback.sol';
import "../interfaces/ITokenRootDeployedCallback.sol";
import "../interfaces/IReferralProgramCallbacks.sol";
import "tip3/contracts/interfaces/IAcceptTokensTransferCallback.sol";
import "tip3/contracts/interfaces/IAcceptTokensMintCallback.sol";
import "../interfaces/IAccountOwner.sol";


contract Wallet is Account,
IPairOperationCallback,
IAcceptTokensTransferCallback,
ITokenRootDeployedCallback,
IAcceptTokensMintCallback,
IReferralProgramCallbacks,
IAccountOwner
{

    function dexPairDepositLiquiditySuccess(uint64 id, bool via_account, IDepositLiquidityResult.DepositLiquidityResult result)
        override external {}

    function dexPairDepositLiquiditySuccessV2(uint64 id, bool via_account, IDepositLiquidityResultV2.DepositLiquidityResultV2 result)
        override external {}

    function dexPairExchangeSuccess(uint64 id, bool via_account, IExchangeResult.ExchangeResult result)
        override external {}

    function dexPairExchangeSuccessV2(uint64 id, bool via_account, IExchangeResultV2.ExchangeResultV2 result)
        override external {}

    function dexPairWithdrawSuccess(uint64 id, bool via_account, IWithdrawResult.WithdrawResult result)
        override external {}

    function dexPairWithdrawSuccessV2(uint64 id, bool via_account, IWithdrawResultV2.WithdrawResultV2 result)
        override external {}

    function dexPairOperationCancelled(uint64 id)
        override external {}

    function onAcceptTokensTransfer(
        address tokenRoot,
        uint128 amount,
        address sender,
        address senderWallet,
        address remainingGasTo,
        TvmCell payload
    ) external override {}

    function onAcceptTokensMint(
        address tokenRoot,
        uint128 amount,
        address remainingGasTo,
        TvmCell payload
    ) external override {}

    function onTokenRootDeployed(uint32 callId, address tokenRoot) external override {}

    function onRefLastUpdate(
        address referred,
        address referrer,
        address remainingGasTo
    )  external override {}

    function dexAccountOnSuccess(uint64 nonce) external override {}
    function dexAccountOnBounce(uint64 nonce, uint32 functionId) external override {}
}
