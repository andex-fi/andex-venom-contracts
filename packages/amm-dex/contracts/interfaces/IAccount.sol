pragma ever-solidity >= 0.62.0;

import "../structures/IWithdrawalParams.sol";
import "../structures/IOperation.sol";

import "./ISuccessCallback.sol";

interface IAccount is
    ISuccessCallback,
    IOperation,
    IWithdrawalParams
{
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // EVENTS

    event AddPool(
        address[] roots,
        address pair
    );

    event WithdrawTokens(
        address root,
        uint128 amount,
        uint128 balance
    );

    event TransferTokens(
        address root,
        uint128 amount,
        uint128 balance
    );

    event ExchangeTokens(
        address from,
        address to,
        uint128 spent_amount,
        uint128 expected_amount,
        uint128 balance
    );

    event DepositLiquidity(
        TokenOperation[] operations,
        bool autoChange
    );

    event WithdrawLiquidity(
        uint128 lpAmount,
        uint128 lpBalance,
        address lpRoot,
        address[] roots
    );

    event TokensReceived(
        address token_root,
        uint128 tokens_amount,
        uint128 balance,
        address sender_wallet
    );

    event TokensReceivedFromAccount(
        address token_root,
        uint128 tokens_amount,
        uint128 balance,
        address sender
    );

    event TokensReceivedFromPool(
        address tokenRoot,
        uint128 tokensAmount,
        uint128 balance,
        address[] roots
    );

    event OperationRollback(
        address token_root,
        uint128 amount,
        uint128 balance,
        address from
    );

    event ExpectedPairNotExist(address pair);

    event AccountCodeUpgraded(uint32 version);

    event CodeUpgradeRequested();

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // GETTERS

    function getRoot() external view responsible returns (address);

    function getOwner() external view responsible returns (address);

    function getVersion() external view responsible returns (uint32);

    function getVault() external view responsible returns (address);

    function getWalletData(address token_root) external view responsible returns (
        address wallet,
        uint128 balance
    );

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // ACCOUNT ACTIONS

    function withdraw(
        uint64 call_id,
        uint128 amount,
        address token_root,
        address recipient_address,
        uint128 deploy_wallet_grams,
        address send_gas_to
    ) external;

    function transfer(
        uint64 call_id,
        uint128 amount,
        address token_root,
        address to_dex_account,
        bool willing_to_deploy,
        address send_gas_to
    ) external;

    function addPair(
        address left_root,
        address right_root
    ) external;

    function addPool(address[] _roots) external;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // SWAP

    function exchange(
        uint64 call_id,
        uint128 spent_amount,
        address spent_token_root,
        address receive_token_root,
        uint128 expected_amount,
        address send_gas_to
    ) external;

    function exchangeV2(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation _expected,
        address[] _roots,
        address _remainingGasTo
    ) external;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // WITHDRAW LIQUIDITY

    function withdrawLiquidity(
        uint64 call_id,
        uint128 lp_amount,
        address lp_root,
        address left_root,
        address right_root,
        address send_gas_to
    ) external;

    function withdrawLiquidityV2(
        uint64 _callId,
        TokenOperation _operation,
        TokenOperation[] _expected,
        address _remainingGasTo
    ) external;

    function withdrawLiquidityOneCoin(
        uint64 _callId,
        address[] _roots,
        TokenOperation _operation,
        TokenOperation _expected,
        address _remainingGasTo
    ) external;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // DEPOSIT LIQUIDITY

    function depositLiquidity(
        uint64 call_id,
        address left_root,
        uint128 left_amount,
        address right_root,
        uint128 right_amount,
        address expected_lp_root,
        bool auto_change,
        address send_gas_to
    ) external;

    function depositLiquidityV2(
        uint64 _callId,
        TokenOperation[] _operations,
        TokenOperation _expected,
        bool _autoChange,
        address _remainingGasTo,
        address _referrer
    ) external;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // INTERNAL

    function checkPoolCallback(
        address[] _roots,
        address _lpRoot
    ) external;

    function internalAccountTransfer(
        uint64 _callId,
        uint128 _amount,
        address _tokenRoot,
        address _senderOwner,
        bool _willingToDeploy,
        address _remainingGasTo
    ) external;

    function internalPoolTransfer(
        uint128 _amount,
        address _tokenRoot,
        address[] _roots,
        address _remainingGasTo
    ) external;
}
