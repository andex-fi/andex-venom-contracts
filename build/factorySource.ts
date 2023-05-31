const accountAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    { name: "resetGas", inputs: [{ name: "receiver", type: "address" }], outputs: [] },
    { name: "getRoot", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "address" }] },
    {
      name: "getOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint32" }],
    },
    {
      name: "getVault",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getWalletData",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "token_root", type: "address" },
      ],
      outputs: [
        { name: "wallet", type: "address" },
        { name: "balance", type: "uint128" },
      ],
    },
    { name: "getWallets", inputs: [], outputs: [{ name: "value0", type: "map(address,address)" }] },
    { name: "getBalances", inputs: [], outputs: [{ name: "value0", type: "map(address,uint128)" }] },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "_tokenRoot", type: "address" },
        { name: "_tokensAmount", type: "uint128" },
        { name: "value2", type: "address" },
        { name: "_senderWallet", type: "address" },
        { name: "_originalGasTo", type: "address" },
        { name: "_payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "checkPoolCallback",
      inputs: [
        { name: "_roots", type: "address[]" },
        { name: "_lpRoot", type: "address" },
      ],
      outputs: [],
    },
    { name: "successCallback", inputs: [{ name: "_callId", type: "uint64" }], outputs: [] },
    { name: "onTokenWallet", inputs: [{ name: "_wallet", type: "address" }], outputs: [] },
    {
      name: "withdraw",
      inputs: [
        { name: "call_id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "token_root", type: "address" },
        { name: "recipient_address", type: "address" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "transfer",
      inputs: [
        { name: "call_id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "token_root", type: "address" },
        { name: "recipient", type: "address" },
        { name: "willing_to_deploy", type: "bool" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "internalAccountTransfer",
      inputs: [
        { name: "call_id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "token_root", type: "address" },
        { name: "sender_owner", type: "address" },
        { name: "willing_to_deploy", type: "bool" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "internalPoolTransfer",
      inputs: [
        { name: "_amount", type: "uint128" },
        { name: "_tokenRoot", type: "address" },
        { name: "_roots", type: "address[]" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "exchange",
      inputs: [
        { name: "call_id", type: "uint64" },
        { name: "spent_amount", type: "uint128" },
        { name: "spent_token_root", type: "address" },
        { name: "receive_token_root", type: "address" },
        { name: "expected_amount", type: "uint128" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "exchangeV2",
      inputs: [
        { name: "_callId", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "_roots", type: "address[]" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "depositLiquidity",
      inputs: [
        { name: "call_id", type: "uint64" },
        { name: "left_root", type: "address" },
        { name: "left_amount", type: "uint128" },
        { name: "right_root", type: "address" },
        { name: "right_amount", type: "uint128" },
        { name: "expected_lp_root", type: "address" },
        { name: "auto_change", type: "bool" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "depositLiquidityV2",
      inputs: [
        { name: "_callId", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operations",
          type: "tuple[]",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "_autoChange", type: "bool" },
        { name: "_remainingGasTo", type: "address" },
        { name: "_referrer", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "withdrawLiquidity",
      inputs: [
        { name: "call_id", type: "uint64" },
        { name: "lp_amount", type: "uint128" },
        { name: "lp_root", type: "address" },
        { name: "left_root", type: "address" },
        { name: "right_root", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "withdrawLiquidityV2",
      inputs: [
        { name: "_callId", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple[]",
        },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "withdrawLiquidityOneCoin",
      inputs: [
        { name: "_callId", type: "uint64" },
        { name: "_roots", type: "address[]" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "addPair",
      inputs: [
        { name: "left_root", type: "address" },
        { name: "right_root", type: "address" },
      ],
      outputs: [],
    },
    { name: "addPool", inputs: [{ name: "_roots", type: "address[]" }], outputs: [] },
    { name: "requestUpgrade", inputs: [{ name: "send_gas_to", type: "address" }], outputs: [] },
    {
      name: "upgrade",
      inputs: [
        { name: "_code", type: "cell" },
        { name: "_newVersion", type: "uint32" },
        { name: "_sendGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "platform_code", inputs: [], outputs: [{ name: "platform_code", type: "cell" }] },
  ],
  data: [],
  events: [
    {
      name: "AddPool",
      inputs: [
        { name: "roots", type: "address[]" },
        { name: "pair", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "WithdrawTokens",
      inputs: [
        { name: "root", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "balance", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "TransferTokens",
      inputs: [
        { name: "root", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "balance", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "ExchangeTokens",
      inputs: [
        { name: "from", type: "address" },
        { name: "to", type: "address" },
        { name: "spent_amount", type: "uint128" },
        { name: "expected_amount", type: "uint128" },
        { name: "balance", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "DepositLiquidity",
      inputs: [
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "operations",
          type: "tuple[]",
        },
        { name: "autoChange", type: "bool" },
      ],
      outputs: [],
    },
    {
      name: "WithdrawLiquidity",
      inputs: [
        { name: "lpAmount", type: "uint128" },
        { name: "lpBalance", type: "uint128" },
        { name: "lpRoot", type: "address" },
        { name: "roots", type: "address[]" },
      ],
      outputs: [],
    },
    {
      name: "TokensReceived",
      inputs: [
        { name: "token_root", type: "address" },
        { name: "tokens_amount", type: "uint128" },
        { name: "balance", type: "uint128" },
        { name: "sender_wallet", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "TokensReceivedFromAccount",
      inputs: [
        { name: "token_root", type: "address" },
        { name: "tokens_amount", type: "uint128" },
        { name: "balance", type: "uint128" },
        { name: "sender", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "TokensReceivedFromPool",
      inputs: [
        { name: "tokenRoot", type: "address" },
        { name: "tokensAmount", type: "uint128" },
        { name: "balance", type: "uint128" },
        { name: "roots", type: "address[]" },
      ],
      outputs: [],
    },
    {
      name: "OperationRollback",
      inputs: [
        { name: "token_root", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "balance", type: "uint128" },
        { name: "from", type: "address" },
      ],
      outputs: [],
    },
    { name: "ExpectedPairNotExist", inputs: [{ name: "pair", type: "address" }], outputs: [] },
    { name: "AccountCodeUpgraded", inputs: [{ name: "version", type: "uint32" }], outputs: [] },
    { name: "CodeUpgradeRequested", inputs: [], outputs: [] },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "platform_code", type: "cell" },
    { name: "_root", type: "address" },
    { name: "_vault", type: "address" },
    { name: "_currentVersion", type: "uint32" },
    { name: "_owner", type: "address" },
    { name: "_wallets", type: "map(address,address)" },
    { name: "_balances", type: "map(address,uint128)" },
    {
      components: [
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "token_operations",
          type: "tuple[]",
        },
        { name: "send_gas_to", type: "address" },
        { name: "expected_callback_sender", type: "address" },
      ],
      name: "_tmpOperations",
      type: "map(uint64,tuple)",
    },
    { name: "_tmpDeployingWallets", type: "map(address,address)" },
  ],
} as const;
const pairAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    {
      name: "buildExchangePayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "expected_amount", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildExchangePayloadV2",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_expectedAmount", type: "uint128" },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_successPayload", type: "optional(cell)" },
        { name: "_cancelPayload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildDepositLiquidityPayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildDepositLiquidityPayloadV2",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_expectedAmount", type: "uint128" },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_successPayload", type: "optional(cell)" },
        { name: "_cancelPayload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildWithdrawLiquidityPayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildWithdrawLiquidityPayloadV2",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_expectedLeftAmount", type: "uint128" },
        { name: "_expectedRightAmount", type: "uint128" },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_successPayload", type: "optional(cell)" },
        { name: "_cancelPayload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildCrossPairExchangePayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "expected_amount", type: "uint128" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "steps",
          type: "tuple[]",
        },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildCrossPairExchangePayloadV2",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_expectedAmount", type: "uint128" },
        { name: "_outcoming", type: "address" },
        { name: "_nextStepIndices", type: "uint32[]" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "roots", type: "address[]" },
            { name: "outcoming", type: "address" },
            { name: "numerator", type: "uint128" },
            { name: "nextStepIndices", type: "uint32[]" },
          ],
          name: "_steps",
          type: "tuple[]",
        },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_successPayload", type: "optional(cell)" },
        { name: "_cancelPayload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "expectedDepositLiquidity",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "left_amount", type: "uint128" },
        { name: "right_amount", type: "uint128" },
        { name: "auto_change", type: "bool" },
      ],
      outputs: [
        {
          components: [
            { name: "step_1_left_deposit", type: "uint128" },
            { name: "step_1_right_deposit", type: "uint128" },
            { name: "step_1_lp_reward", type: "uint128" },
            { name: "step_2_left_to_right", type: "bool" },
            { name: "step_2_right_to_left", type: "bool" },
            { name: "step_2_spent", type: "uint128" },
            { name: "step_2_fee", type: "uint128" },
            { name: "step_2_received", type: "uint128" },
            { name: "step_3_left_deposit", type: "uint128" },
            { name: "step_3_right_deposit", type: "uint128" },
            { name: "step_3_lp_reward", type: "uint128" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "depositLiquidity",
      inputs: [
        { name: "_callId", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operations",
          type: "tuple[]",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "_autoChange", type: "bool" },
        { name: "_accountOwner", type: "address" },
        { name: "value5", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
        { name: "_referrer", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "expectedWithdrawLiquidity",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "lp_amount", type: "uint128" },
      ],
      outputs: [
        { name: "expected_left_amount", type: "uint128" },
        { name: "expected_right_amount", type: "uint128" },
      ],
    },
    {
      name: "withdrawLiquidity",
      inputs: [
        { name: "_callId", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple[]",
        },
        { name: "_accountOwner", type: "address" },
        { name: "value4", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "expectedExchange",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "amount", type: "uint128" },
        { name: "spent_token_root", type: "address" },
      ],
      outputs: [
        { name: "expected_amount", type: "uint128" },
        { name: "expected_fee", type: "uint128" },
      ],
    },
    {
      name: "expectedSpendAmount",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "receive_amount", type: "uint128" },
        { name: "receive_token_root", type: "address" },
      ],
      outputs: [
        { name: "expected_amount", type: "uint128" },
        { name: "expected_fee", type: "uint128" },
      ],
    },
    {
      name: "exchange",
      inputs: [
        { name: "_callId", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "_accountOwner", type: "address" },
        { name: "value4", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "crossPoolExchange",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "value1", type: "uint32" },
        { name: "value2", type: "uint8" },
        { name: "_prevPoolTokenRoots", type: "address[]" },
        { name: "_op", type: "uint8" },
        { name: "_spentTokenRoot", type: "address" },
        { name: "_spentAmount", type: "uint128" },
        { name: "_senderAddress", type: "address" },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_remainingGasTo", type: "address" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_payload", type: "cell" },
        { name: "_notifySuccess", type: "bool" },
        { name: "_successPayload", type: "cell" },
        { name: "_notifyCancel", type: "bool" },
        { name: "_cancelPayload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "_tokenRoot", type: "address" },
        { name: "_tokensAmount", type: "uint128" },
        { name: "_senderAddress", type: "address" },
        { name: "_senderWallet", type: "address" },
        { name: "_remainingGasTo", type: "address" },
        { name: "_payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "getRoot",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "dex_root", type: "address" }],
    },
    {
      name: "getTokenRoots",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        { name: "left", type: "address" },
        { name: "right", type: "address" },
        { name: "lp", type: "address" },
      ],
    },
    {
      name: "getTokenWallets",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        { name: "left", type: "address" },
        { name: "right", type: "address" },
        { name: "lp", type: "address" },
      ],
    },
    {
      name: "getVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "version", type: "uint32" }],
    },
    {
      name: "getVault",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getPoolType",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint8" }],
    },
    {
      name: "getFeeParams",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "getAccumulatedFees",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "accumulatedFees", type: "uint128[]" }],
    },
    { name: "isActive", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "bool" }] },
    {
      name: "getBalances",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "lp_supply", type: "uint128" },
            { name: "left_balance", type: "uint128" },
            { name: "right_balance", type: "uint128" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "setFeeParams",
      inputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "_params",
          type: "tuple",
        },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "withdrawBeneficiaryFee", inputs: [{ name: "send_gas_to", type: "address" }], outputs: [] },
    {
      name: "checkPair",
      inputs: [
        { name: "_accountOwner", type: "address" },
        { name: "value1", type: "uint32" },
      ],
      outputs: [],
    },
    {
      name: "upgrade",
      inputs: [
        { name: "_code", type: "cell" },
        { name: "_newVersion", type: "uint32" },
        { name: "_newType", type: "uint8" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "liquidityTokenRootDeployed",
      inputs: [
        { name: "_lpRootAddress", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "liquidityTokenRootNotDeployed",
      inputs: [
        { name: "value0", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "onTokenWallet", inputs: [{ name: "_wallet", type: "address" }], outputs: [] },
    {
      name: "setActive",
      inputs: [
        { name: "_newActive", type: "bool" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setOracleOptions",
      inputs: [
        {
          components: [
            { name: "minInterval", type: "uint8" },
            { name: "minRateDeltaNumerator", type: "uint128" },
            { name: "minRateDeltaDenominator", type: "uint128" },
            { name: "cardinality", type: "uint16" },
          ],
          name: "_newOptions",
          type: "tuple",
        },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "getOracleOptions",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "minInterval", type: "uint8" },
            { name: "minRateDeltaNumerator", type: "uint128" },
            { name: "minRateDeltaDenominator", type: "uint128" },
            { name: "cardinality", type: "uint16" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "removeLastNPoints",
      inputs: [
        { name: "_count", type: "uint16" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "getObservation",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "_timestamp", type: "uint32" },
      ],
      outputs: [
        {
          components: [
            { name: "timestamp", type: "uint32" },
            { name: "price0To1Cumulative", type: "uint256" },
            { name: "price1To0Cumulative", type: "uint256" },
          ],
          name: "value0",
          type: "optional(tuple)",
        },
      ],
    },
    {
      name: "observation",
      inputs: [
        { name: "_timestamp", type: "uint32" },
        { name: "_callbackTo", type: "address" },
        { name: "_payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "getRate",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "_fromTimestamp", type: "uint32" },
        { name: "_toTimestamp", type: "uint32" },
      ],
      outputs: [
        {
          components: [
            { name: "price0To1", type: "uint256" },
            { name: "price1To0", type: "uint256" },
            { name: "fromTimestamp", type: "uint32" },
            { name: "toTimestamp", type: "uint32" },
          ],
          name: "value0",
          type: "optional(tuple)",
        },
        { name: "value1", type: "uint128[]" },
      ],
    },
    {
      name: "rate",
      inputs: [
        { name: "_fromTimestamp", type: "uint32" },
        { name: "_toTimestamp", type: "uint32" },
        { name: "_callbackTo", type: "address" },
        { name: "_payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "getExpectedAmountByTWAP",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "_amount", type: "uint128" },
        { name: "_tokenRoot", type: "address" },
        { name: "_fromTimestamp", type: "uint32" },
        { name: "_toTimestamp", type: "uint32" },
      ],
      outputs: [{ name: "value0", type: "uint128" }],
    },
    { name: "platform_code", inputs: [], outputs: [{ name: "platform_code", type: "cell" }] },
  ],
  data: [],
  events: [
    {
      name: "OracleInitialized",
      inputs: [
        {
          components: [
            { name: "timestamp", type: "uint32" },
            { name: "price0To1Cumulative", type: "uint256" },
            { name: "price1To0Cumulative", type: "uint256" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "OracleUpdated",
      inputs: [
        {
          components: [
            { name: "timestamp", type: "uint32" },
            { name: "price0To1Cumulative", type: "uint256" },
            { name: "price1To0Cumulative", type: "uint256" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "OracleOptionsUpdated",
      inputs: [
        {
          components: [
            { name: "minInterval", type: "uint8" },
            { name: "minRateDeltaNumerator", type: "uint128" },
            { name: "minRateDeltaDenominator", type: "uint128" },
            { name: "cardinality", type: "uint16" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "PairCodeUpgraded",
      inputs: [
        { name: "version", type: "uint32" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [],
    },
    {
      name: "ActiveStatusUpdated",
      inputs: [
        { name: "current", type: "bool" },
        { name: "previous", type: "bool" },
      ],
      outputs: [],
    },
    {
      name: "FeesParamsUpdated",
      inputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "params",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "DepositLiquidity",
      inputs: [
        { name: "sender", type: "address" },
        { name: "owner", type: "address" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "tokens",
          type: "tuple[]",
        },
        { name: "lp", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "WithdrawLiquidity",
      inputs: [
        { name: "sender", type: "address" },
        { name: "owner", type: "address" },
        { name: "lp", type: "uint128" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "tokens",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "Exchange",
      inputs: [
        { name: "sender", type: "address" },
        { name: "recipient", type: "address" },
        { name: "spentTokenRoot", type: "address" },
        { name: "spentAmount", type: "uint128" },
        { name: "receiveTokenRoot", type: "address" },
        { name: "receiveAmount", type: "uint128" },
        {
          components: [
            { name: "feeTokenRoot", type: "address" },
            { name: "pool_fee", type: "uint128" },
            { name: "beneficiary_fee", type: "uint128" },
            { name: "beneficiary", type: "address" },
          ],
          name: "fees",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "ReferrerFees",
      inputs: [
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "fees",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "Sync",
      inputs: [
        { name: "reserves", type: "uint128[]" },
        { name: "lp_supply", type: "uint128" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "platform_code", type: "cell" },
    {
      components: [
        { name: "price0To1Cumulative", type: "uint256" },
        { name: "price1To0Cumulative", type: "uint256" },
      ],
      name: "_points",
      type: "map(uint32,tuple)",
    },
    { name: "_length", type: "uint16" },
    {
      components: [
        { name: "minInterval", type: "uint8" },
        { name: "minRateDeltaNumerator", type: "uint128" },
        { name: "minRateDeltaDenominator", type: "uint128" },
        { name: "cardinality", type: "uint16" },
      ],
      name: "_options",
      type: "tuple",
    },
    { name: "_root", type: "address" },
    { name: "_vault", type: "address" },
    { name: "_active", type: "bool" },
    { name: "_currentVersion", type: "uint32" },
    {
      components: [
        { name: "denominator", type: "uint128" },
        { name: "pool_numerator", type: "uint128" },
        { name: "beneficiary_numerator", type: "uint128" },
        { name: "referrer_numerator", type: "uint128" },
        { name: "beneficiary", type: "address" },
        { name: "threshold", type: "map(address,uint128)" },
        { name: "referrer_threshold", type: "map(address,uint128)" },
      ],
      name: "_fee",
      type: "tuple",
    },
    { name: "_typeToRootAddresses", type: "map(uint8,address[])" },
    { name: "_typeToWalletAddresses", type: "map(uint8,address[])" },
    { name: "_typeToReserves", type: "map(uint8,uint128[])" },
  ],
} as const;
const platformAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    {
      name: "constructor",
      inputs: [
        { name: "code", type: "cell" },
        { name: "version", type: "uint32" },
        { name: "vault", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
  ],
  data: [
    { key: 1, name: "root", type: "address" },
    { key: 2, name: "type_id", type: "uint8" },
    { key: 3, name: "params", type: "cell" },
  ],
  events: [],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "root", type: "address" },
    { name: "type_id", type: "uint8" },
    { name: "params", type: "cell" },
  ],
} as const;
const rootAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    {
      name: "constructor",
      inputs: [
        { name: "initial_owner", type: "address" },
        { name: "initial_vault", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "getAccountVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint32" }],
    },
    {
      name: "getAccountCode",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "getPairVersion",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [{ name: "value0", type: "uint32" }],
    },
    {
      name: "getPoolVersion",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [{ name: "value0", type: "uint32" }],
    },
    {
      name: "getPairCode",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "getPoolCode",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "getVault",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getTokenVaultCode",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "getTokenVaultVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint32" }],
    },
    {
      name: "getLpTokenPendingCode",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "getLpTokenPendingVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint32" }],
    },
    {
      name: "getTokenFactory",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    { name: "isActive", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "bool" }] },
    {
      name: "getOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "dex_owner", type: "address" }],
    },
    {
      name: "getPendingOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "dex_pending_owner", type: "address" }],
    },
    {
      name: "getExpectedAccountAddress",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "account_owner", type: "address" },
      ],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getExpectedPairAddress",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "left_root", type: "address" },
        { name: "right_root", type: "address" },
      ],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getExpectedPoolAddress",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "_roots", type: "address[]" },
      ],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getExpectedTokenVaultAddress",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "_tokenRoot", type: "address" },
      ],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getManager",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    { name: "setVaultOnce", inputs: [{ name: "new_vault", type: "address" }], outputs: [] },
    { name: "setActive", inputs: [{ name: "new_active", type: "bool" }], outputs: [] },
    { name: "setManager", inputs: [{ name: "_newManager", type: "address" }], outputs: [] },
    { name: "revokeManager", inputs: [], outputs: [] },
    { name: "transferOwner", inputs: [{ name: "new_owner", type: "address" }], outputs: [] },
    { name: "acceptOwner", inputs: [], outputs: [] },
    {
      name: "setTokenFactory",
      inputs: [
        { name: "_newTokenFactory", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "installPlatformOnce", inputs: [{ name: "code", type: "cell" }], outputs: [] },
    { name: "installOrUpdateAccountCode", inputs: [{ name: "code", type: "cell" }], outputs: [] },
    {
      name: "installOrUpdatePairCode",
      inputs: [
        { name: "code", type: "cell" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [],
    },
    {
      name: "installOrUpdatePoolCode",
      inputs: [
        { name: "code", type: "cell" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [],
    },
    {
      name: "installOrUpdateTokenVaultCode",
      inputs: [
        { name: "_newCode", type: "cell" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "installOrUpdateLpTokenPendingCode",
      inputs: [
        { name: "_newCode", type: "cell" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "upgrade", inputs: [{ name: "code", type: "cell" }], outputs: [] },
    { name: "resetGas", inputs: [{ name: "receiver", type: "address" }], outputs: [] },
    {
      name: "deployTokenVault",
      inputs: [
        { name: "_tokenRoot", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "onTokenVaultDeployed",
      inputs: [
        { name: "_version", type: "uint32" },
        { name: "_tokenRoot", type: "address" },
        { name: "_tokenWallet", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "deployLpToken",
      inputs: [
        { name: "_tokenRoots", type: "address[]" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "onLiquidityTokenDeployed",
      inputs: [
        { name: "_lpPendingNonce", type: "uint32" },
        { name: "_pool", type: "address" },
        { name: "_roots", type: "address[]" },
        { name: "_lpRoot", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "onLiquidityTokenNotDeployed",
      inputs: [
        { name: "_lpPendingNonce", type: "uint32" },
        { name: "_pool", type: "address" },
        { name: "_roots", type: "address[]" },
        { name: "_lpRoot", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "upgradeTokenVault",
      inputs: [
        { name: "_tokenRoot", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "upgradeTokenVaults",
      inputs: [
        { name: "_tokenRoots", type: "address[]" },
        { name: "_offset", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "deployAccount",
      inputs: [
        { name: "account_owner", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "requestUpgradeAccount",
      inputs: [
        { name: "current_version", type: "uint32" },
        { name: "send_gas_to", type: "address" },
        { name: "account_owner", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "forceUpgradeAccount",
      inputs: [
        { name: "account_owner", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "upgradeAccounts",
      inputs: [
        { name: "_accountsOwners", type: "address[]" },
        { name: "_offset", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "upgradePair",
      inputs: [
        { name: "left_root", type: "address" },
        { name: "right_root", type: "address" },
        { name: "pool_type", type: "uint8" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "upgradePool",
      inputs: [
        { name: "roots", type: "address[]" },
        { name: "pool_type", type: "uint8" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "upgradePairs",
      inputs: [
        {
          components: [
            { name: "tokenRoots", type: "address[]" },
            { name: "poolType", type: "uint8" },
          ],
          name: "_params",
          type: "tuple[]",
        },
        { name: "_offset", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setPoolActive",
      inputs: [
        {
          components: [
            { name: "tokenRoots", type: "address[]" },
            { name: "newActive", type: "bool" },
          ],
          name: "_param",
          type: "tuple",
        },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setPoolsActive",
      inputs: [
        {
          components: [
            { name: "tokenRoots", type: "address[]" },
            { name: "newActive", type: "bool" },
          ],
          name: "_params",
          type: "tuple[]",
        },
        { name: "_offset", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "deployPair",
      inputs: [
        { name: "left_root", type: "address" },
        { name: "right_root", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "deployStablePool",
      inputs: [
        { name: "roots", type: "address[]" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setPairFeeParams",
      inputs: [
        { name: "_roots", type: "address[]" },
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "_params",
          type: "tuple",
        },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setPairAmplificationCoefficient",
      inputs: [
        { name: "_roots", type: "address[]" },
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "precision", type: "uint128" },
          ],
          name: "_A",
          type: "tuple",
        },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "resetTargetGas",
      inputs: [
        { name: "target", type: "address" },
        { name: "receiver", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "onPoolCreated",
      inputs: [
        { name: "_roots", type: "address[]" },
        { name: "_poolType", type: "uint8" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setOracleOptions",
      inputs: [
        { name: "_leftRoot", type: "address" },
        { name: "_rightRoot", type: "address" },
        {
          components: [
            { name: "minInterval", type: "uint8" },
            { name: "minRateDeltaNumerator", type: "uint128" },
            { name: "minRateDeltaDenominator", type: "uint128" },
            { name: "cardinality", type: "uint16" },
          ],
          name: "_options",
          type: "tuple",
        },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "removeLastNPoints",
      inputs: [
        { name: "_leftRoot", type: "address" },
        { name: "_rightRoot", type: "address" },
        { name: "_count", type: "uint16" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "platform_code", inputs: [], outputs: [{ name: "platform_code", type: "cell" }] },
  ],
  data: [{ key: 1, name: "_nonce", type: "uint32" }],
  events: [
    { name: "AccountCodeUpgraded", inputs: [{ name: "version", type: "uint32" }], outputs: [] },
    {
      name: "PairCodeUpgraded",
      inputs: [
        { name: "version", type: "uint32" },
        { name: "poolType", type: "uint8" },
      ],
      outputs: [],
    },
    {
      name: "PoolCodeUpgraded",
      inputs: [
        { name: "version", type: "uint32" },
        { name: "poolType", type: "uint8" },
      ],
      outputs: [],
    },
    {
      name: "TokenVaultCodeUpgraded",
      inputs: [
        { name: "version", type: "uint32" },
        { name: "codeHash", type: "uint256" },
      ],
      outputs: [],
    },
    {
      name: "LpTokenPendingCodeUpgraded",
      inputs: [
        { name: "version", type: "uint32" },
        { name: "codeHash", type: "uint256" },
      ],
      outputs: [],
    },
    {
      name: "TokenFactoryUpdated",
      inputs: [
        { name: "current", type: "address" },
        { name: "previous", type: "address" },
      ],
      outputs: [],
    },
    { name: "RootCodeUpgraded", inputs: [], outputs: [] },
    { name: "ActiveUpdated", inputs: [{ name: "newActive", type: "bool" }], outputs: [] },
    { name: "RequestedPoolUpgrade", inputs: [{ name: "roots", type: "address[]" }], outputs: [] },
    { name: "RequestedForceAccountUpgrade", inputs: [{ name: "accountOwner", type: "address" }], outputs: [] },
    {
      name: "RequestedOwnerTransfer",
      inputs: [
        { name: "oldOwner", type: "address" },
        { name: "newOwner", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "OwnerTransferAccepted",
      inputs: [
        { name: "oldOwner", type: "address" },
        { name: "newOwner", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "NewPoolCreated",
      inputs: [
        { name: "roots", type: "address[]" },
        { name: "poolType", type: "uint8" },
      ],
      outputs: [],
    },
    {
      name: "NewTokenVaultCreated",
      inputs: [
        { name: "vault", type: "address" },
        { name: "tokenRoot", type: "address" },
        { name: "tokenWallet", type: "address" },
        { name: "version", type: "uint32" },
      ],
      outputs: [],
    },
    {
      name: "NewLpTokenRootCreated",
      inputs: [
        { name: "pool", type: "address" },
        { name: "poolTokenRoots", type: "address[]" },
        { name: "lpTokenRoot", type: "address" },
        { name: "lpPendingNonce", type: "uint32" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "platform_code", type: "cell" },
    { name: "_nonce", type: "uint32" },
    { name: "_accountCode", type: "cell" },
    { name: "_accountVersion", type: "uint32" },
    { name: "_pairCodes", type: "map(uint8,cell)" },
    { name: "_pairVersions", type: "map(uint8,uint32)" },
    { name: "_poolCodes", type: "map(uint8,cell)" },
    { name: "_poolVersions", type: "map(uint8,uint32)" },
    { name: "_vaultCode", type: "cell" },
    { name: "_vaultVersion", type: "uint32" },
    { name: "_lpTokenPendingCode", type: "cell" },
    { name: "_lpTokenPendingVersion", type: "uint32" },
    { name: "_tokenFactory", type: "address" },
    { name: "_active", type: "bool" },
    { name: "_owner", type: "address" },
    { name: "_vault", type: "address" },
    { name: "_pendingOwner", type: "address" },
    { name: "_manager", type: "address" },
  ],
} as const;
const stablePairAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    {
      name: "getRoot",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "dex_root", type: "address" }],
    },
    {
      name: "getTokenRoots",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        { name: "left", type: "address" },
        { name: "right", type: "address" },
        { name: "lp", type: "address" },
      ],
    },
    {
      name: "getTokenWallets",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        { name: "left", type: "address" },
        { name: "right", type: "address" },
        { name: "lp", type: "address" },
      ],
    },
    {
      name: "getVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "version", type: "uint32" }],
    },
    {
      name: "getVault",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getPoolType",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint8" }],
    },
    {
      name: "getAccumulatedFees",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "accumulatedFees", type: "uint128[]" }],
    },
    {
      name: "getFeeParams",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "getAmplificationCoefficient",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "precision", type: "uint128" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    { name: "isActive", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "bool" }] },
    {
      name: "getBalances",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "lp_supply", type: "uint128" },
            { name: "left_balance", type: "uint128" },
            { name: "right_balance", type: "uint128" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "setActive",
      inputs: [
        { name: "_newActive", type: "bool" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setAmplificationCoefficient",
      inputs: [
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "precision", type: "uint128" },
          ],
          name: "_A",
          type: "tuple",
        },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setFeeParams",
      inputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "params",
          type: "tuple",
        },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    { name: "withdrawBeneficiaryFee", inputs: [{ name: "send_gas_to", type: "address" }], outputs: [] },
    {
      name: "buildExchangePayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "expected_amount", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildExchangePayloadV2",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_expectedAmount", type: "uint128" },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_successPayload", type: "optional(cell)" },
        { name: "_cancelPayload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildDepositLiquidityPayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildDepositLiquidityPayloadV2",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_expectedAmount", type: "uint128" },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_successPayload", type: "optional(cell)" },
        { name: "_cancelPayload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildWithdrawLiquidityPayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildWithdrawLiquidityPayloadV2",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_expectedLeftAmount", type: "uint128" },
        { name: "_expectedRightAmount", type: "uint128" },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_successPayload", type: "optional(cell)" },
        { name: "_cancelPayload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildCrossPairExchangePayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "expected_amount", type: "uint128" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "steps",
          type: "tuple[]",
        },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildCrossPairExchangePayloadV2",
      inputs: [
        { name: "_id", type: "uint64" },
        { name: "_deployWalletGrams", type: "uint128" },
        { name: "_expectedAmount", type: "uint128" },
        { name: "_outcoming", type: "address" },
        { name: "_nextStepIndices", type: "uint32[]" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "roots", type: "address[]" },
            { name: "outcoming", type: "address" },
            { name: "numerator", type: "uint128" },
            { name: "nextStepIndices", type: "uint32[]" },
          ],
          name: "_steps",
          type: "tuple[]",
        },
        { name: "_recipient", type: "address" },
        { name: "_referrer", type: "address" },
        { name: "_successPayload", type: "optional(cell)" },
        { name: "_cancelPayload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "token_root", type: "address" },
        { name: "tokens_amount", type: "uint128" },
        { name: "sender_address", type: "address" },
        { name: "sender_wallet", type: "address" },
        { name: "original_gas_to", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "expectedDepositLiquidityV2",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "amounts", type: "uint128[]" },
      ],
      outputs: [
        {
          components: [
            { name: "old_balances", type: "uint128[]" },
            { name: "amounts", type: "uint128[]" },
            { name: "lp_reward", type: "uint128" },
            { name: "result_balances", type: "uint128[]" },
            { name: "invariant", type: "uint128" },
            { name: "differences", type: "uint128[]" },
            { name: "sell", type: "bool[]" },
            { name: "pool_fees", type: "uint128[]" },
            { name: "beneficiary_fees", type: "uint128[]" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "depositLiquidity",
      inputs: [
        { name: "call_id", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operations",
          type: "tuple[]",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "auto_change", type: "bool" },
        { name: "account_owner", type: "address" },
        { name: "value5", type: "uint32" },
        { name: "send_gas_to", type: "address" },
        { name: "referrer", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "expectedWithdrawLiquidity",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "lp_amount", type: "uint128" },
      ],
      outputs: [
        { name: "expected_left_amount", type: "uint128" },
        { name: "expected_right_amount", type: "uint128" },
      ],
    },
    {
      name: "withdrawLiquidity",
      inputs: [
        { name: "call_id", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple[]",
        },
        { name: "account_owner", type: "address" },
        { name: "value4", type: "uint32" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "expectedExchange",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "amount", type: "uint128" },
        { name: "spent_token_root", type: "address" },
      ],
      outputs: [
        { name: "expected_amount", type: "uint128" },
        { name: "expected_fee", type: "uint128" },
      ],
    },
    {
      name: "expectedSpendAmount",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "receive_amount", type: "uint128" },
        { name: "receive_token_root", type: "address" },
      ],
      outputs: [
        { name: "expected_amount", type: "uint128" },
        { name: "expected_fee", type: "uint128" },
      ],
    },
    {
      name: "exchange",
      inputs: [
        { name: "call_id", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "account_owner", type: "address" },
        { name: "value4", type: "uint32" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "crossPoolExchange",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "value1", type: "uint32" },
        { name: "value2", type: "uint8" },
        { name: "prev_pool_token_roots", type: "address[]" },
        { name: "op", type: "uint8" },
        { name: "spent_token_root", type: "address" },
        { name: "spent_amount", type: "uint128" },
        { name: "sender_address", type: "address" },
        { name: "recipient", type: "address" },
        { name: "referrer", type: "address" },
        { name: "original_gas_to", type: "address" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "payload", type: "cell" },
        { name: "notify_success", type: "bool" },
        { name: "success_payload", type: "cell" },
        { name: "notify_cancel", type: "bool" },
        { name: "cancel_payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "checkPair",
      inputs: [
        { name: "account_owner", type: "address" },
        { name: "value1", type: "uint32" },
      ],
      outputs: [],
    },
    {
      name: "upgrade",
      inputs: [
        { name: "code", type: "cell" },
        { name: "new_version", type: "uint32" },
        { name: "new_type", type: "uint8" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    { name: "onTokenWallet", inputs: [{ name: "wallet", type: "address" }], outputs: [] },
    { name: "onTokenDecimals", inputs: [{ name: "_decimals", type: "uint8" }], outputs: [] },
    {
      name: "liquidityTokenRootDeployed",
      inputs: [
        { name: "lp_root_", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "liquidityTokenRootNotDeployed",
      inputs: [
        { name: "value0", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "getVirtualPrice",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "optional(uint256)" }],
    },
    {
      name: "getPriceImpact",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "spent_token_root", type: "address" },
        { name: "price_amount", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "optional(uint256)" }],
    },
    { name: "platform_code", inputs: [], outputs: [{ name: "platform_code", type: "cell" }] },
  ],
  data: [],
  events: [
    {
      name: "AmplificationCoefficientUpdated",
      inputs: [
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "precision", type: "uint128" },
          ],
          name: "A",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "PairCodeUpgraded",
      inputs: [
        { name: "version", type: "uint32" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [],
    },
    {
      name: "ActiveStatusUpdated",
      inputs: [
        { name: "current", type: "bool" },
        { name: "previous", type: "bool" },
      ],
      outputs: [],
    },
    {
      name: "FeesParamsUpdated",
      inputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "params",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "DepositLiquidity",
      inputs: [
        { name: "sender", type: "address" },
        { name: "owner", type: "address" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "tokens",
          type: "tuple[]",
        },
        { name: "lp", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "WithdrawLiquidity",
      inputs: [
        { name: "sender", type: "address" },
        { name: "owner", type: "address" },
        { name: "lp", type: "uint128" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "tokens",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "Exchange",
      inputs: [
        { name: "sender", type: "address" },
        { name: "recipient", type: "address" },
        { name: "spentTokenRoot", type: "address" },
        { name: "spentAmount", type: "uint128" },
        { name: "receiveTokenRoot", type: "address" },
        { name: "receiveAmount", type: "uint128" },
        {
          components: [
            { name: "feeTokenRoot", type: "address" },
            { name: "pool_fee", type: "uint128" },
            { name: "beneficiary_fee", type: "uint128" },
            { name: "beneficiary", type: "address" },
          ],
          name: "fees",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "ReferrerFees",
      inputs: [
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "fees",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "Sync",
      inputs: [
        { name: "reserves", type: "uint128[]" },
        { name: "lp_supply", type: "uint128" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "platform_code", type: "cell" },
    { name: "root", type: "address" },
    { name: "vault", type: "address" },
    { name: "active", type: "bool" },
    { name: "current_version", type: "uint32" },
    {
      components: [
        { name: "root", type: "address" },
        { name: "wallet", type: "address" },
        { name: "balance", type: "uint128" },
        { name: "decimals", type: "uint8" },
        { name: "accumulatedFee", type: "uint128" },
        { name: "rate", type: "uint256" },
        { name: "precisionMul", type: "uint256" },
        { name: "decimalsLoaded", type: "bool" },
        { name: "initialized", type: "bool" },
      ],
      name: "tokenData",
      type: "tuple[]",
    },
    { name: "tokenIndex", type: "map(address,uint8)" },
    { name: "PRECISION", type: "uint256" },
    { name: "lp_root", type: "address" },
    { name: "lp_wallet", type: "address" },
    { name: "lp_supply", type: "uint128" },
    {
      components: [
        { name: "denominator", type: "uint128" },
        { name: "pool_numerator", type: "uint128" },
        { name: "beneficiary_numerator", type: "uint128" },
        { name: "referrer_numerator", type: "uint128" },
        { name: "beneficiary", type: "address" },
        { name: "threshold", type: "map(address,uint128)" },
        { name: "referrer_threshold", type: "map(address,uint128)" },
      ],
      name: "fee",
      type: "tuple",
    },
    {
      components: [
        { name: "value", type: "uint128" },
        { name: "precision", type: "uint128" },
      ],
      name: "A",
      type: "tuple",
    },
  ],
} as const;
const stablePoolAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    {
      name: "getRoot",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "dex_root", type: "address" }],
    },
    {
      name: "getTokenRoots",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        { name: "roots", type: "address[]" },
        { name: "lp", type: "address" },
      ],
    },
    {
      name: "getTokenWallets",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        { name: "token_wallets", type: "address[]" },
        { name: "lp", type: "address" },
      ],
    },
    {
      name: "getVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "version", type: "uint32" }],
    },
    {
      name: "getVault",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getPoolType",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint8" }],
    },
    {
      name: "getAccumulatedFees",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "accumulatedFees", type: "uint128[]" }],
    },
    {
      name: "getFeeParams",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "getAmplificationCoefficient",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "precision", type: "uint128" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    { name: "isActive", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "bool" }] },
    {
      name: "getBalances",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "balances", type: "uint128[]" },
            { name: "lp_supply", type: "uint128" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "setActive",
      inputs: [
        { name: "_newActive", type: "bool" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setAmplificationCoefficient",
      inputs: [
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "precision", type: "uint128" },
          ],
          name: "_A",
          type: "tuple",
        },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "setFeeParams",
      inputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "params",
          type: "tuple",
        },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    { name: "withdrawBeneficiaryFee", inputs: [{ name: "send_gas_to", type: "address" }], outputs: [] },
    {
      name: "buildExchangePayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "expected_amount", type: "uint128" },
        { name: "outcoming", type: "address" },
        { name: "recipient", type: "address" },
        { name: "referrer", type: "address" },
        { name: "success_payload", type: "optional(cell)" },
        { name: "cancel_payload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildDepositLiquidityPayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "expected_amount", type: "uint128" },
        { name: "recipient", type: "address" },
        { name: "referrer", type: "address" },
        { name: "success_payload", type: "optional(cell)" },
        { name: "cancel_payload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildWithdrawLiquidityPayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "expected_amounts", type: "uint128[]" },
        { name: "recipient", type: "address" },
        { name: "referrer", type: "address" },
        { name: "success_payload", type: "optional(cell)" },
        { name: "cancel_payload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildWithdrawLiquidityOneCoinPayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "expected_amount", type: "uint128" },
        { name: "outcoming", type: "address" },
        { name: "recipient", type: "address" },
        { name: "referrer", type: "address" },
        { name: "success_payload", type: "optional(cell)" },
        { name: "cancel_payload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildCrossPairExchangePayload",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "deployWalletGrams", type: "uint128" },
        { name: "expectedAmount", type: "uint128" },
        { name: "outcoming", type: "address" },
        { name: "nextStepIndices", type: "uint32[]" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "roots", type: "address[]" },
            { name: "outcoming", type: "address" },
            { name: "numerator", type: "uint128" },
            { name: "nextStepIndices", type: "uint32[]" },
          ],
          name: "steps",
          type: "tuple[]",
        },
        { name: "recipient", type: "address" },
        { name: "referrer", type: "address" },
        { name: "success_payload", type: "optional(cell)" },
        { name: "cancel_payload", type: "optional(cell)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "token_root", type: "address" },
        { name: "tokens_amount", type: "uint128" },
        { name: "sender_address", type: "address" },
        { name: "sender_wallet", type: "address" },
        { name: "original_gas_to", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "expectedDepositLiquidityV2",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "amounts", type: "uint128[]" },
      ],
      outputs: [
        {
          components: [
            { name: "old_balances", type: "uint128[]" },
            { name: "amounts", type: "uint128[]" },
            { name: "lp_reward", type: "uint128" },
            { name: "result_balances", type: "uint128[]" },
            { name: "invariant", type: "uint128" },
            { name: "differences", type: "uint128[]" },
            { name: "sell", type: "bool[]" },
            { name: "pool_fees", type: "uint128[]" },
            { name: "beneficiary_fees", type: "uint128[]" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "expectedDepositLiquidityOneCoin",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "spent_token_root", type: "address" },
        { name: "amount", type: "uint128" },
      ],
      outputs: [
        {
          components: [
            { name: "old_balances", type: "uint128[]" },
            { name: "amounts", type: "uint128[]" },
            { name: "lp_reward", type: "uint128" },
            { name: "result_balances", type: "uint128[]" },
            { name: "invariant", type: "uint128" },
            { name: "differences", type: "uint128[]" },
            { name: "sell", type: "bool[]" },
            { name: "pool_fees", type: "uint128[]" },
            { name: "beneficiary_fees", type: "uint128[]" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "depositLiquidity",
      inputs: [
        { name: "call_id", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operations",
          type: "tuple[]",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "auto_change", type: "bool" },
        { name: "account_owner", type: "address" },
        { name: "value5", type: "uint32" },
        { name: "send_gas_to", type: "address" },
        { name: "referrer", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "expectedDepositSpendAmount",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "lp_amount", type: "uint128" },
        { name: "spent_token_root", type: "address" },
      ],
      outputs: [
        { name: "tokens_amount", type: "uint128" },
        { name: "expected_fee", type: "uint128" },
      ],
    },
    {
      name: "expectedWithdrawLiquidity",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "lp_amount", type: "uint128" },
      ],
      outputs: [
        {
          components: [
            { name: "lp_amount", type: "uint128" },
            { name: "old_balances", type: "uint128[]" },
            { name: "amounts", type: "uint128[]" },
            { name: "result_balances", type: "uint128[]" },
            { name: "invariant", type: "uint128" },
            { name: "differences", type: "uint128[]" },
            { name: "sell", type: "bool[]" },
            { name: "pool_fees", type: "uint128[]" },
            { name: "beneficiary_fees", type: "uint128[]" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "expectedOneCoinWithdrawalSpendAmount",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "receive_amount", type: "uint128" },
        { name: "receive_token_root", type: "address" },
      ],
      outputs: [
        { name: "lp", type: "uint128" },
        { name: "expected_fee", type: "uint128" },
      ],
    },
    {
      name: "expectedWithdrawLiquidityOneCoin",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "lp_amount", type: "uint128" },
        { name: "outcoming", type: "address" },
      ],
      outputs: [
        {
          components: [
            { name: "lp_amount", type: "uint128" },
            { name: "old_balances", type: "uint128[]" },
            { name: "amounts", type: "uint128[]" },
            { name: "result_balances", type: "uint128[]" },
            { name: "invariant", type: "uint128" },
            { name: "differences", type: "uint128[]" },
            { name: "sell", type: "bool[]" },
            { name: "pool_fees", type: "uint128[]" },
            { name: "beneficiary_fees", type: "uint128[]" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "withdrawLiquidity",
      inputs: [
        { name: "call_id", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple[]",
        },
        { name: "account_owner", type: "address" },
        { name: "value4", type: "uint32" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "expectedExchange",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "amount", type: "uint128" },
        { name: "spent_token_root", type: "address" },
        { name: "receive_token_root", type: "address" },
      ],
      outputs: [
        { name: "expected_amount", type: "uint128" },
        { name: "expected_fee", type: "uint128" },
      ],
    },
    {
      name: "expectedSpendAmount",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "receive_amount", type: "uint128" },
        { name: "receive_token_root", type: "address" },
        { name: "spent_token_root", type: "address" },
      ],
      outputs: [
        { name: "expected_amount", type: "uint128" },
        { name: "expected_fee", type: "uint128" },
      ],
    },
    {
      name: "exchange",
      inputs: [
        { name: "call_id", type: "uint64" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_operation",
          type: "tuple",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "_expected",
          type: "tuple",
        },
        { name: "account_owner", type: "address" },
        { name: "value4", type: "uint32" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "crossPoolExchange",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "value1", type: "uint32" },
        { name: "value2", type: "uint8" },
        { name: "prev_pool_token_roots", type: "address[]" },
        { name: "op", type: "uint8" },
        { name: "spent_token_root", type: "address" },
        { name: "spent_amount", type: "uint128" },
        { name: "sender_address", type: "address" },
        { name: "recipient", type: "address" },
        { name: "referrer", type: "address" },
        { name: "original_gas_to", type: "address" },
        { name: "deploy_wallet_grams", type: "uint128" },
        { name: "payload", type: "cell" },
        { name: "notify_success", type: "bool" },
        { name: "success_payload", type: "cell" },
        { name: "notify_cancel", type: "bool" },
        { name: "cancel_payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "checkPair",
      inputs: [
        { name: "account_owner", type: "address" },
        { name: "value1", type: "uint32" },
      ],
      outputs: [],
    },
    {
      name: "upgrade",
      inputs: [
        { name: "code", type: "cell" },
        { name: "new_version", type: "uint32" },
        { name: "new_type", type: "uint8" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    { name: "onTokenWallet", inputs: [{ name: "wallet", type: "address" }], outputs: [] },
    { name: "onTokenDecimals", inputs: [{ name: "_decimals", type: "uint8" }], outputs: [] },
    {
      name: "liquidityTokenRootDeployed",
      inputs: [
        { name: "lp_root_", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "liquidityTokenRootNotDeployed",
      inputs: [
        { name: "value0", type: "address" },
        { name: "send_gas_to", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "getVirtualPrice",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "optional(uint256)" }],
    },
    {
      name: "getPriceImpact",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "spent_token_root", type: "address" },
        { name: "receive_token_root", type: "address" },
        { name: "price_amount", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "optional(uint256)" }],
    },
    {
      name: "getDepositPriceImpact",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "spent_token_root", type: "address" },
        { name: "price_amount", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "optional(uint256)" }],
    },
    {
      name: "getWithdrawalPriceImpact",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "receive_token_root", type: "address" },
        { name: "price_amount", type: "uint128" },
      ],
      outputs: [{ name: "value0", type: "optional(uint256)" }],
    },
    { name: "platform_code", inputs: [], outputs: [{ name: "platform_code", type: "cell" }] },
  ],
  data: [],
  events: [
    {
      name: "AmplificationCoefficientUpdated",
      inputs: [
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "precision", type: "uint128" },
          ],
          name: "A",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "DepositLiquidityV2",
      inputs: [
        { name: "sender", type: "address" },
        { name: "owner", type: "address" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "tokens",
          type: "tuple[]",
        },
        {
          components: [
            { name: "feeTokenRoot", type: "address" },
            { name: "pool_fee", type: "uint128" },
            { name: "beneficiary_fee", type: "uint128" },
            { name: "beneficiary", type: "address" },
          ],
          name: "fees",
          type: "tuple[]",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "spent_differences",
          type: "tuple[]",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "receive_differences",
          type: "tuple[]",
        },
        { name: "lp", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "WithdrawLiquidityV2",
      inputs: [
        { name: "sender", type: "address" },
        { name: "owner", type: "address" },
        { name: "lp", type: "uint128" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "tokens",
          type: "tuple[]",
        },
        {
          components: [
            { name: "feeTokenRoot", type: "address" },
            { name: "pool_fee", type: "uint128" },
            { name: "beneficiary_fee", type: "uint128" },
            { name: "beneficiary", type: "address" },
          ],
          name: "fees",
          type: "tuple[]",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "spent_differences",
          type: "tuple[]",
        },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "receive_differences",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "PoolCodeUpgraded",
      inputs: [
        { name: "version", type: "uint32" },
        { name: "pool_type", type: "uint8" },
      ],
      outputs: [],
    },
    {
      name: "ActiveStatusUpdated",
      inputs: [
        { name: "current", type: "bool" },
        { name: "previous", type: "bool" },
      ],
      outputs: [],
    },
    {
      name: "FeesParamsUpdated",
      inputs: [
        {
          components: [
            { name: "denominator", type: "uint128" },
            { name: "pool_numerator", type: "uint128" },
            { name: "beneficiary_numerator", type: "uint128" },
            { name: "referrer_numerator", type: "uint128" },
            { name: "beneficiary", type: "address" },
            { name: "threshold", type: "map(address,uint128)" },
            { name: "referrer_threshold", type: "map(address,uint128)" },
          ],
          name: "params",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "DepositLiquidity",
      inputs: [
        { name: "sender", type: "address" },
        { name: "owner", type: "address" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "tokens",
          type: "tuple[]",
        },
        { name: "lp", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "WithdrawLiquidity",
      inputs: [
        { name: "sender", type: "address" },
        { name: "owner", type: "address" },
        { name: "lp", type: "uint128" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "tokens",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "Exchange",
      inputs: [
        { name: "sender", type: "address" },
        { name: "recipient", type: "address" },
        { name: "spentTokenRoot", type: "address" },
        { name: "spentAmount", type: "uint128" },
        { name: "receiveTokenRoot", type: "address" },
        { name: "receiveAmount", type: "uint128" },
        {
          components: [
            { name: "feeTokenRoot", type: "address" },
            { name: "pool_fee", type: "uint128" },
            { name: "beneficiary_fee", type: "uint128" },
            { name: "beneficiary", type: "address" },
          ],
          name: "fees",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "ReferrerFees",
      inputs: [
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "root", type: "address" },
          ],
          name: "fees",
          type: "tuple[]",
        },
      ],
      outputs: [],
    },
    {
      name: "Sync",
      inputs: [
        { name: "reserves", type: "uint128[]" },
        { name: "lp_supply", type: "uint128" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "platform_code", type: "cell" },
    { name: "root", type: "address" },
    { name: "vault", type: "address" },
    { name: "active", type: "bool" },
    { name: "current_version", type: "uint32" },
    {
      components: [
        { name: "root", type: "address" },
        { name: "wallet", type: "address" },
        { name: "balance", type: "uint128" },
        { name: "decimals", type: "uint8" },
        { name: "accumulatedFee", type: "uint128" },
        { name: "rate", type: "uint256" },
        { name: "precisionMul", type: "uint256" },
        { name: "decimalsLoaded", type: "bool" },
        { name: "initialized", type: "bool" },
      ],
      name: "tokenData",
      type: "tuple[]",
    },
    { name: "tokenIndex", type: "map(address,uint8)" },
    { name: "PRECISION", type: "uint256" },
    { name: "MAX_DECIMALS", type: "uint8" },
    { name: "lp_root", type: "address" },
    { name: "lp_wallet", type: "address" },
    { name: "lp_supply", type: "uint128" },
    {
      components: [
        { name: "denominator", type: "uint128" },
        { name: "pool_numerator", type: "uint128" },
        { name: "beneficiary_numerator", type: "uint128" },
        { name: "referrer_numerator", type: "uint128" },
        { name: "beneficiary", type: "address" },
        { name: "threshold", type: "map(address,uint128)" },
        { name: "referrer_threshold", type: "map(address,uint128)" },
      ],
      name: "fee",
      type: "tuple",
    },
    {
      components: [
        { name: "value", type: "uint128" },
        { name: "precision", type: "uint128" },
      ],
      name: "A",
      type: "tuple",
    },
    { name: "N_COINS", type: "uint8" },
  ],
} as const;
const testWeverTunnelAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    {
      name: "constructor",
      inputs: [
        { name: "sources", type: "address[]" },
        { name: "destinations", type: "address[]" },
        { name: "owner_", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "__getTunnels",
      inputs: [],
      outputs: [
        { name: "sources", type: "address[]" },
        { name: "destinations", type: "address[]" },
      ],
    },
    {
      name: "__updateTunnel",
      inputs: [
        { name: "source", type: "address" },
        { name: "destination", type: "address" },
      ],
      outputs: [],
    },
    { name: "__removeTunnel", inputs: [{ name: "source", type: "address" }], outputs: [] },
    { name: "pause", inputs: [], outputs: [] },
    { name: "unpause", inputs: [], outputs: [] },
    { name: "transferOwnership", inputs: [{ name: "newOwner", type: "address" }], outputs: [] },
    { name: "renounceOwnership", inputs: [], outputs: [] },
    { name: "owner", inputs: [], outputs: [{ name: "owner", type: "address" }] },
    { name: "paused", inputs: [], outputs: [{ name: "paused", type: "bool" }] },
  ],
  data: [{ key: 1, name: "_randomNonce", type: "uint256" }],
  events: [
    { name: "Pause", inputs: [], outputs: [] },
    { name: "Unpause", inputs: [], outputs: [] },
    {
      name: "OwnershipTransferred",
      inputs: [
        { name: "previousOwner", type: "address" },
        { name: "newOwner", type: "address" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "owner", type: "address" },
    { name: "paused", type: "bool" },
    { name: "_randomNonce", type: "uint256" },
    { name: "tunnels", type: "map(address,address)" },
  ],
} as const;
const testWeverVaultAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    {
      name: "constructor",
      inputs: [
        { name: "owner_", type: "address" },
        { name: "root", type: "address" },
        { name: "root_tunnel", type: "address" },
        { name: "receive_safe_fee", type: "uint128" },
        { name: "settings_deploy_wallet_grams", type: "uint128" },
        { name: "initial_balance", type: "uint128" },
      ],
      outputs: [],
    },
    { name: "receiveTokenWalletAddress", inputs: [{ name: "wallet", type: "address" }], outputs: [] },
    { name: "drain", inputs: [{ name: "receiver", type: "address" }], outputs: [] },
    {
      name: "setConfiguration",
      inputs: [
        {
          components: [
            { name: "root_tunnel", type: "address" },
            { name: "root", type: "address" },
            { name: "receive_safe_fee", type: "uint128" },
            { name: "settings_deploy_wallet_grams", type: "uint128" },
            { name: "initial_balance", type: "uint128" },
          ],
          name: "_configuration",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    { name: "withdraw", inputs: [{ name: "amount", type: "uint128" }], outputs: [] },
    { name: "grant", inputs: [{ name: "amount", type: "uint128" }], outputs: [] },
    {
      name: "wrap",
      inputs: [
        { name: "tokens", type: "uint128" },
        { name: "owner_address", type: "address" },
        { name: "gas_back_address", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "tokenRoot", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "sender", type: "address" },
        { name: "senderWallet", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "transferOwnership", inputs: [{ name: "newOwner", type: "address" }], outputs: [] },
    { name: "renounceOwnership", inputs: [], outputs: [] },
    { name: "_randomNonce", inputs: [], outputs: [{ name: "_randomNonce", type: "uint256" }] },
    { name: "owner", inputs: [], outputs: [{ name: "owner", type: "address" }] },
    {
      name: "configuration",
      inputs: [],
      outputs: [
        {
          components: [
            { name: "root_tunnel", type: "address" },
            { name: "root", type: "address" },
            { name: "receive_safe_fee", type: "uint128" },
            { name: "settings_deploy_wallet_grams", type: "uint128" },
            { name: "initial_balance", type: "uint128" },
          ],
          name: "configuration",
          type: "tuple",
        },
      ],
    },
    { name: "token_wallet", inputs: [], outputs: [{ name: "token_wallet", type: "address" }] },
    { name: "total_wrapped", inputs: [], outputs: [{ name: "total_wrapped", type: "uint128" }] },
  ],
  data: [{ key: 1, name: "_randomNonce", type: "uint256" }],
  events: [
    {
      name: "OwnershipTransferred",
      inputs: [
        { name: "previousOwner", type: "address" },
        { name: "newOwner", type: "address" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "_randomNonce", type: "uint256" },
    { name: "owner", type: "address" },
    {
      components: [
        { name: "root_tunnel", type: "address" },
        { name: "root", type: "address" },
        { name: "receive_safe_fee", type: "uint128" },
        { name: "settings_deploy_wallet_grams", type: "uint128" },
        { name: "initial_balance", type: "uint128" },
      ],
      name: "configuration",
      type: "tuple",
    },
    { name: "token_wallet", type: "address" },
    { name: "total_wrapped", type: "uint128" },
  ],
} as const;
const tip3ToVenomAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    { name: "onWeverWallet", inputs: [{ name: "_weverWallet", type: "address" }], outputs: [] },
    {
      name: "buildExchangePayload",
      inputs: [
        { name: "pair", type: "address" },
        { name: "id", type: "uint64" },
        { name: "expectedAmount", type: "uint128" },
        { name: "referrer", type: "address" },
        { name: "outcoming", type: "optional(address)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildCrossPairExchangePayload",
      inputs: [
        { name: "pool", type: "address" },
        { name: "id", type: "uint64" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "expectedAmount", type: "uint128" },
        { name: "outcoming", type: "address" },
        { name: "nextStepIndices", type: "uint32[]" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "pool", type: "address" },
            { name: "outcoming", type: "address" },
            { name: "numerator", type: "uint128" },
            { name: "nextStepIndices", type: "uint32[]" },
          ],
          name: "steps",
          type: "tuple[]",
        },
        { name: "referrer", type: "address" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "tokenRoot", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "sender", type: "address" },
        { name: "value3", type: "address" },
        { name: "user", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensBurn",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "value1", type: "address" },
        { name: "value2", type: "address" },
        { name: "user", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "weverRoot", inputs: [], outputs: [{ name: "weverRoot", type: "address" }] },
    { name: "weverVault", inputs: [], outputs: [{ name: "weverVault", type: "address" }] },
    { name: "weverWallet", inputs: [], outputs: [{ name: "weverWallet", type: "address" }] },
  ],
  data: [
    { key: 1, name: "randomNonce_", type: "uint32" },
    { key: 2, name: "weverRoot", type: "address" },
    { key: 3, name: "weverVault", type: "address" },
  ],
  events: [
    {
      name: "SwapVenomToTip3Start",
      inputs: [
        { name: "pair", type: "address" },
        { name: "operationType", type: "uint8" },
        { name: "id", type: "uint64" },
        { name: "user", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "SwapVenomToTip3Success",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "tokenRoot", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "SwapVenomToTip3Partial",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "tokenRoot", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "SwapVenomToTip3Cancel",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "SwapTip3EverSuccessTransfer",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "SwapTip3EverCancelTransfer",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "tokenRoot", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "SwapVenomWvenomToTip3Unwrap",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "randomNonce_", type: "uint32" },
    { name: "weverRoot", type: "address" },
    { name: "weverVault", type: "address" },
    { name: "weverWallet", type: "address" },
  ],
} as const;
const tokenFactoryAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["time"],
  functions: [
    { name: "constructor", inputs: [{ name: "_owner", type: "address" }], outputs: [] },
    { name: "owner", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "address" }] },
    {
      name: "pendingOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    { name: "rootCode", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "cell" }] },
    { name: "walletCode", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "cell" }] },
    {
      name: "walletPlatformCode",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "createToken",
      inputs: [
        { name: "callId", type: "uint32" },
        { name: "name", type: "string" },
        { name: "symbol", type: "string" },
        { name: "decimals", type: "uint8" },
        { name: "initialSupplyTo", type: "address" },
        { name: "initialSupply", type: "uint128" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "mintDisabled", type: "bool" },
        { name: "burnByRootDisabled", type: "bool" },
        { name: "burnPaused", type: "bool" },
        { name: "remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "transferOwner",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "newOwner", type: "address" },
      ],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "acceptOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    { name: "setRootCode", inputs: [{ name: "_rootCode", type: "cell" }], outputs: [] },
    { name: "setWalletCode", inputs: [{ name: "_walletCode", type: "cell" }], outputs: [] },
    { name: "setWalletPlatformCode", inputs: [{ name: "_walletPlatformCode", type: "cell" }], outputs: [] },
    { name: "upgrade", inputs: [{ name: "code", type: "cell" }], outputs: [] },
  ],
  data: [{ key: 1, name: "randomNonce_", type: "uint32" }],
  events: [{ name: "TokenCreated", inputs: [{ name: "tokenRoot", type: "address" }], outputs: [] }],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "randomNonce_", type: "uint32" },
    { name: "owner_", type: "address" },
    { name: "pendingOwner_", type: "address" },
    { name: "rootCode_", type: "cell" },
    { name: "walletCode_", type: "cell" },
    { name: "walletPlatformCode_", type: "cell" },
  ],
} as const;
const tokenRootAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    {
      name: "constructor",
      inputs: [
        { name: "initialSupplyTo", type: "address" },
        { name: "initialSupply", type: "uint128" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "mintDisabled", type: "bool" },
        { name: "burnByRootDisabled", type: "bool" },
        { name: "burnPaused", type: "bool" },
        { name: "remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "supportsInterface",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "interfaceID", type: "uint32" },
      ],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "disableMint",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "mintDisabled",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "burnTokens",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "walletOwner", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "callbackTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "disableBurnByRoot",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "burnByRootDisabled",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "bool" }],
    },
    { name: "burnPaused", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "bool" }] },
    {
      name: "setBurnPaused",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "paused", type: "bool" },
      ],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "transferOwnership",
      inputs: [
        { name: "newOwner", type: "address" },
        { name: "remainingGasTo", type: "address" },
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "payload", type: "cell" },
          ],
          name: "callbacks",
          type: "map(address,tuple)",
        },
      ],
      outputs: [],
    },
    { name: "name", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "string" }] },
    { name: "symbol", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "string" }] },
    { name: "decimals", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "uint8" }] },
    {
      name: "totalSupply",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint128" }],
    },
    { name: "walletCode", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "cell" }] },
    {
      name: "rootOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "walletOf",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "walletOwner", type: "address" },
      ],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "deployWallet",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "walletOwner", type: "address" },
        { name: "deployWalletValue", type: "uint128" },
      ],
      outputs: [{ name: "tokenWallet", type: "address" }],
    },
    {
      name: "mint",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "recipient", type: "address" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "acceptBurn",
      id: "0x192B51B1",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "walletOwner", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "callbackTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "sendSurplusGas", inputs: [{ name: "to", type: "address" }], outputs: [] },
  ],
  data: [
    { key: 1, name: "name_", type: "string" },
    { key: 2, name: "symbol_", type: "string" },
    { key: 3, name: "decimals_", type: "uint8" },
    { key: 4, name: "rootOwner_", type: "address" },
    { key: 5, name: "walletCode_", type: "cell" },
    { key: 6, name: "randomNonce_", type: "uint256" },
    { key: 7, name: "deployer_", type: "address" },
  ],
  events: [],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "name_", type: "string" },
    { name: "symbol_", type: "string" },
    { name: "decimals_", type: "uint8" },
    { name: "rootOwner_", type: "address" },
    { name: "walletCode_", type: "cell" },
    { name: "totalSupply_", type: "uint128" },
    { name: "burnPaused_", type: "bool" },
    { name: "burnByRootDisabled_", type: "bool" },
    { name: "mintDisabled_", type: "bool" },
    { name: "randomNonce_", type: "uint256" },
    { name: "deployer_", type: "address" },
  ],
} as const;
const tokenRootUpgradeableAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    {
      name: "constructor",
      inputs: [
        { name: "initialSupplyTo", type: "address" },
        { name: "initialSupply", type: "uint128" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "mintDisabled", type: "bool" },
        { name: "burnByRootDisabled", type: "bool" },
        { name: "burnPaused", type: "bool" },
        { name: "remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "supportsInterface",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "interfaceID", type: "uint32" },
      ],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "walletVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint32" }],
    },
    {
      name: "platformCode",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "requestUpgradeWallet",
      inputs: [
        { name: "currentVersion", type: "uint32" },
        { name: "walletOwner", type: "address" },
        { name: "remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "setWalletCode", inputs: [{ name: "code", type: "cell" }], outputs: [] },
    { name: "upgrade", inputs: [{ name: "code", type: "cell" }], outputs: [] },
    {
      name: "disableMint",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "mintDisabled",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "burnTokens",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "walletOwner", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "callbackTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "disableBurnByRoot",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "burnByRootDisabled",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "bool" }],
    },
    { name: "burnPaused", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "bool" }] },
    {
      name: "setBurnPaused",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "paused", type: "bool" },
      ],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "transferOwnership",
      inputs: [
        { name: "newOwner", type: "address" },
        { name: "remainingGasTo", type: "address" },
        {
          components: [
            { name: "value", type: "uint128" },
            { name: "payload", type: "cell" },
          ],
          name: "callbacks",
          type: "map(address,tuple)",
        },
      ],
      outputs: [],
    },
    { name: "name", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "string" }] },
    { name: "symbol", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "string" }] },
    { name: "decimals", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "uint8" }] },
    {
      name: "totalSupply",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint128" }],
    },
    { name: "walletCode", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "cell" }] },
    {
      name: "rootOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "walletOf",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "walletOwner", type: "address" },
      ],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "deployWallet",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "walletOwner", type: "address" },
        { name: "deployWalletValue", type: "uint128" },
      ],
      outputs: [{ name: "tokenWallet", type: "address" }],
    },
    {
      name: "mint",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "recipient", type: "address" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "acceptBurn",
      id: "0x192B51B1",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "walletOwner", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "callbackTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "sendSurplusGas", inputs: [{ name: "to", type: "address" }], outputs: [] },
  ],
  data: [
    { key: 1, name: "name_", type: "string" },
    { key: 2, name: "symbol_", type: "string" },
    { key: 3, name: "decimals_", type: "uint8" },
    { key: 4, name: "rootOwner_", type: "address" },
    { key: 5, name: "walletCode_", type: "cell" },
    { key: 6, name: "randomNonce_", type: "uint256" },
    { key: 7, name: "deployer_", type: "address" },
    { key: 8, name: "platformCode_", type: "cell" },
  ],
  events: [],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "name_", type: "string" },
    { name: "symbol_", type: "string" },
    { name: "decimals_", type: "uint8" },
    { name: "rootOwner_", type: "address" },
    { name: "walletCode_", type: "cell" },
    { name: "totalSupply_", type: "uint128" },
    { name: "burnPaused_", type: "bool" },
    { name: "burnByRootDisabled_", type: "bool" },
    { name: "mintDisabled_", type: "bool" },
    { name: "randomNonce_", type: "uint256" },
    { name: "deployer_", type: "address" },
    { name: "platformCode_", type: "cell" },
    { name: "walletVersion_", type: "uint32" },
  ],
} as const;
const tokenVaultAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    {
      name: "redeploy",
      id: "0x15A038FB",
      inputs: [
        { name: "value0", type: "cell" },
        { name: "value1", type: "uint32" },
        { name: "value2", type: "address" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "getRoot", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "address" }] },
    {
      name: "getVersion",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint32" }],
    },
    {
      name: "getPlatformCode",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "getTokenRoot",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getTokenWallet",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getVault",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getTargetBalance",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "uint128" }],
    },
    {
      name: "withdraw",
      inputs: [
        { name: "_callId", type: "uint64" },
        { name: "_amount", type: "uint128" },
        { name: "_recipient", type: "address" },
        { name: "_deployRecipientWalletGrams", type: "uint128" },
        { name: "_accountOwner", type: "address" },
        { name: "value5", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "transfer",
      inputs: [
        { name: "_amount", type: "uint128" },
        { name: "_recipient", type: "address" },
        { name: "_deployRecipientWalletGrams", type: "uint128" },
        { name: "_notifyRecipient", type: "bool" },
        { name: "_payload", type: "cell" },
        { name: "_poolTokenRoots", type: "address[]" },
        { name: "value6", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "referralFeeTransfer",
      inputs: [
        { name: "_amount", type: "uint128" },
        { name: "_referrer", type: "address" },
        { name: "_referral", type: "address" },
        { name: "_poolTokenRoots", type: "address[]" },
      ],
      outputs: [],
    },
    { name: "resetGas", inputs: [{ name: "_remainingGasTo", type: "address" }], outputs: [] },
    {
      name: "upgrade",
      inputs: [
        { name: "_newCode", type: "cell" },
        { name: "_newVersion", type: "uint32" },
        { name: "_remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensMint",
      inputs: [
        { name: "value0", type: "address" },
        { name: "_amount", type: "uint128" },
        { name: "_remainingGasTo", type: "address" },
        { name: "_payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "onTokenWallet", inputs: [{ name: "_wallet", type: "address" }], outputs: [] },
    { name: "onVaultTokenWallet", inputs: [{ name: "_wallet", type: "address" }], outputs: [] },
    { name: "platform_code", inputs: [], outputs: [{ name: "platform_code", type: "cell" }] },
  ],
  data: [],
  events: [
    {
      name: "TokenVaultCodeUpgraded",
      inputs: [
        { name: "currentVersion", type: "uint32" },
        { name: "previousVersion", type: "uint32" },
      ],
      outputs: [],
    },
    { name: "TokenWalletSet", inputs: [{ name: "wallet", type: "address" }], outputs: [] },
    { name: "VaultTokenWalletDeployed", inputs: [{ name: "wallet", type: "address" }], outputs: [] },
    {
      name: "WithdrawTokens",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "accountOwner", type: "address" },
        { name: "recipient", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "PairTransferTokens",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "poolTokenRoots", type: "address[]" },
        { name: "recipient", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "ReferralFeeTransfer",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "poolTokenRoots", type: "address[]" },
        { name: "referrer", type: "address" },
        { name: "referral", type: "address" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "platform_code", type: "cell" },
    { name: "_root", type: "address" },
    { name: "_vault", type: "address" },
    { name: "_version", type: "uint32" },
    { name: "_tokenRoot", type: "address" },
    { name: "_tokenWallet", type: "address" },
    { name: "_remainingGasToAfterDeploy", type: "address" },
  ],
} as const;
const tokenWalletAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    {
      name: "supportsInterface",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "interfaceID", type: "uint32" },
      ],
      outputs: [{ name: "value0", type: "bool" }],
    },
    { name: "destroy", inputs: [{ name: "remainingGasTo", type: "address" }], outputs: [] },
    {
      name: "burnByRoot",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "callbackTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "burn",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "callbackTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "balance", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "uint128" }] },
    { name: "owner", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "address" }] },
    { name: "root", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "address" }] },
    { name: "walletCode", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "cell" }] },
    {
      name: "transfer",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "recipient", type: "address" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "transferToWallet",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "recipientTokenWallet", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "acceptTransfer",
      id: "0x67A0B95F",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "sender", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "acceptMint",
      id: "0x4384F298",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "sendSurplusGas", inputs: [{ name: "to", type: "address" }], outputs: [] },
  ],
  data: [
    { key: 1, name: "root_", type: "address" },
    { key: 2, name: "owner_", type: "address" },
  ],
  events: [],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "root_", type: "address" },
    { name: "owner_", type: "address" },
    { name: "balance_", type: "uint128" },
  ],
} as const;
const tokenWalletPlatformAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["time"],
  functions: [
    {
      name: "constructor",
      id: "0x15A038FB",
      inputs: [
        { name: "walletCode", type: "cell" },
        { name: "walletVersion", type: "uint32" },
        { name: "sender", type: "address" },
        { name: "remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
  ],
  data: [
    { key: 1, name: "root", type: "address" },
    { key: 2, name: "owner", type: "address" },
  ],
  events: [],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "root", type: "address" },
    { name: "owner", type: "address" },
  ],
} as const;
const tokenWalletUpgradeableAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    {
      name: "supportsInterface",
      inputs: [
        { name: "answerId", type: "uint32" },
        { name: "interfaceID", type: "uint32" },
      ],
      outputs: [{ name: "value0", type: "bool" }],
    },
    {
      name: "platformCode",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "onDeployRetry",
      id: "0x15A038FB",
      inputs: [
        { name: "value0", type: "cell" },
        { name: "value1", type: "uint32" },
        { name: "sender", type: "address" },
        { name: "remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "version", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "uint32" }] },
    { name: "upgrade", inputs: [{ name: "remainingGasTo", type: "address" }], outputs: [] },
    {
      name: "acceptUpgrade",
      inputs: [
        { name: "newCode", type: "cell" },
        { name: "newVersion", type: "uint32" },
        { name: "remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "burnByRoot",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "callbackTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "destroy", inputs: [{ name: "remainingGasTo", type: "address" }], outputs: [] },
    {
      name: "burn",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "callbackTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "balance", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "uint128" }] },
    { name: "owner", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "address" }] },
    { name: "root", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "address" }] },
    { name: "walletCode", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "cell" }] },
    {
      name: "transfer",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "recipient", type: "address" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "transferToWallet",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "recipientTokenWallet", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "acceptTransfer",
      id: "0x67A0B95F",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "sender", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "acceptMint",
      id: "0x4384F298",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "notify", type: "bool" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "sendSurplusGas", inputs: [{ name: "to", type: "address" }], outputs: [] },
  ],
  data: [
    { key: 1, name: "root_", type: "address" },
    { key: 2, name: "owner_", type: "address" },
  ],
  events: [],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "root_", type: "address" },
    { name: "owner_", type: "address" },
    { name: "balance_", type: "uint128" },
    { name: "version_", type: "uint32" },
    { name: "platformCode_", type: "cell" },
  ],
} as const;
const vaultAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    {
      name: "constructor",
      inputs: [
        { name: "owner_", type: "address" },
        { name: "root_", type: "address" },
      ],
      outputs: [],
    },
    { name: "migrateLiquidity", inputs: [], outputs: [] },
    { name: "continueMigrateLiquidity", inputs: [{ name: "_fromTokenRoot", type: "address" }], outputs: [] },
    { name: "migrateToken", inputs: [{ name: "_tokenRoot", type: "address" }], outputs: [] },
    { name: "_migrateNext", inputs: [{ name: "_startTokenRoot", type: "address" }], outputs: [] },
    { name: "onTokenBalance", inputs: [{ name: "_amount", type: "uint128" }], outputs: [] },
    { name: "installPlatformOnce", inputs: [{ name: "code", type: "cell" }], outputs: [] },
    { name: "transferOwner", inputs: [{ name: "new_owner", type: "address" }], outputs: [] },
    { name: "acceptOwner", inputs: [], outputs: [] },
    {
      name: "getOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getPendingOwner",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    {
      name: "getManager",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [{ name: "value0", type: "address" }],
    },
    { name: "setManager", inputs: [{ name: "_newManager", type: "address" }], outputs: [] },
    { name: "revokeManager", inputs: [], outputs: [] },
    { name: "getRoot", inputs: [{ name: "answerId", type: "uint32" }], outputs: [{ name: "value0", type: "address" }] },
    {
      name: "getReferralProgramParams",
      inputs: [{ name: "answerId", type: "uint32" }],
      outputs: [
        {
          components: [
            { name: "projectId", type: "uint256" },
            { name: "projectAddress", type: "address" },
            { name: "systemAddress", type: "address" },
          ],
          name: "value0",
          type: "tuple",
        },
      ],
    },
    {
      name: "setReferralProgramParams",
      inputs: [
        {
          components: [
            { name: "projectId", type: "uint256" },
            { name: "projectAddress", type: "address" },
            { name: "systemAddress", type: "address" },
          ],
          name: "params",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    { name: "upgrade", inputs: [{ name: "code", type: "cell" }], outputs: [] },
    { name: "resetGas", inputs: [{ name: "receiver", type: "address" }], outputs: [] },
    {
      name: "resetTargetGas",
      inputs: [
        { name: "target", type: "address" },
        { name: "receiver", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "_tokenRoot", type: "address" },
        { name: "_amount", type: "uint128" },
        { name: "_sender", type: "address" },
        { name: "value3", type: "address" },
        { name: "_remainingGasTo", type: "address" },
        { name: "_payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "platform_code", inputs: [], outputs: [{ name: "platform_code", type: "cell" }] },
    { name: "_vaultWallets", inputs: [], outputs: [{ name: "_vaultWallets", type: "map(address,address)" }] },
    {
      name: "_vaultWalletsToRoots",
      inputs: [],
      outputs: [{ name: "_vaultWalletsToRoots", type: "map(address,address)" }],
    },
  ],
  data: [{ key: 1, name: "_nonce", type: "uint32" }],
  events: [
    { name: "VaultCodeUpgraded", inputs: [], outputs: [] },
    {
      name: "RequestedOwnerTransfer",
      inputs: [
        { name: "old_owner", type: "address" },
        { name: "new_owner", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "OwnerTransferAccepted",
      inputs: [
        { name: "old_owner", type: "address" },
        { name: "new_owner", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "ReferralFeeTransfer",
      inputs: [
        { name: "tokenRoot", type: "address" },
        { name: "vaultWallet", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "roots", type: "address[]" },
        { name: "referrer", type: "address" },
        { name: "referral", type: "address" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "platform_code", type: "cell" },
    { name: "_nonce", type: "uint32" },
    { name: "_root", type: "address" },
    { name: "_owner", type: "address" },
    { name: "_pendingOwner", type: "address" },
    { name: "_manager", type: "address" },
    { name: "_vaultWallets", type: "map(address,address)" },
    { name: "_vaultWalletsToRoots", type: "map(address,address)" },
    {
      components: [
        { name: "projectId", type: "uint256" },
        { name: "projectAddress", type: "address" },
        { name: "systemAddress", type: "address" },
      ],
      name: "_refProgramParams",
      type: "tuple",
    },
  ],
} as const;
const vaultLpTokenPendingAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["time"],
  functions: [
    {
      name: "constructor",
      inputs: [
        { name: "token_factory_", type: "address" },
        { name: "send_gas_to_", type: "address" },
      ],
      outputs: [],
    },
    { name: "terminate", inputs: [], outputs: [] },
    { name: "onSymbol", inputs: [{ name: "symbol", type: "string" }], outputs: [] },
    {
      name: "onTokenRootDeployed",
      inputs: [
        { name: "value0", type: "uint32" },
        { name: "token_root", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "onTransferTokenRootOwnership",
      inputs: [
        { name: "oldOwner", type: "address" },
        { name: "newOwner", type: "address" },
        { name: "value2", type: "address" },
        { name: "value3", type: "cell" },
      ],
      outputs: [],
    },
  ],
  data: [
    { key: 1, name: "_nonce", type: "uint32" },
    { key: 2, name: "root", type: "address" },
    { key: 3, name: "pool", type: "address" },
    { key: 4, name: "roots", type: "address[]" },
  ],
  events: [],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "LP_TOKEN_SYMBOL_PREFIX", type: "string" },
    { name: "LP_TOKEN_SYMBOL_SEPARATOR", type: "string" },
    { name: "LP_TOKEN_DECIMALS", type: "uint8" },
    { name: "_nonce", type: "uint32" },
    { name: "root", type: "address" },
    { name: "pool", type: "address" },
    { name: "roots", type: "address[]" },
    { name: "token_index", type: "map(address,uint8)" },
    { name: "token_factory", type: "address" },
    { name: "lp_token_root", type: "address" },
    { name: "send_gas_to", type: "address" },
    { name: "pending_messages", type: "uint8" },
    { name: "root_symbols", type: "string[]" },
    { name: "root_symbols_received", type: "bool[]" },
    { name: "root_symbols_amt", type: "uint8" },
    { name: "N_COINS", type: "uint8" },
  ],
} as const;
const venomToTip3Abi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    { name: "onWeverWallet", inputs: [{ name: "_weverWallet", type: "address" }], outputs: [] },
    {
      name: "buildExchangePayload",
      inputs: [
        { name: "pair", type: "address" },
        { name: "id", type: "uint64" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "expectedAmount", type: "uint128" },
        { name: "referrer", type: "address" },
        { name: "outcoming", type: "optional(address)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildCrossPairExchangePayload",
      inputs: [
        { name: "pool", type: "address" },
        { name: "id", type: "uint64" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "expectedAmount", type: "uint128" },
        { name: "outcoming", type: "address" },
        { name: "nextStepIndices", type: "uint32[]" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "pool", type: "address" },
            { name: "outcoming", type: "address" },
            { name: "numerator", type: "uint128" },
            { name: "nextStepIndices", type: "uint32[]" },
          ],
          name: "steps",
          type: "tuple[]",
        },
        { name: "referrer", type: "address" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "onAcceptTokensMint",
      inputs: [
        { name: "value0", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "user", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "tokenRoot", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "sender", type: "address" },
        { name: "value3", type: "address" },
        { name: "user", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensBurn",
      inputs: [
        { name: "amount", type: "uint128" },
        { name: "value1", type: "address" },
        { name: "value2", type: "address" },
        { name: "user", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "weverRoot", inputs: [], outputs: [{ name: "weverRoot", type: "address" }] },
    { name: "weverVault", inputs: [], outputs: [{ name: "weverVault", type: "address" }] },
    { name: "weverWallet", inputs: [], outputs: [{ name: "weverWallet", type: "address" }] },
  ],
  data: [
    { key: 1, name: "randomNonce_", type: "uint32" },
    { key: 2, name: "weverRoot", type: "address" },
    { key: 3, name: "weverVault", type: "address" },
  ],
  events: [
    {
      name: "SwapVenomToTip3Start",
      inputs: [
        { name: "pair", type: "address" },
        { name: "operationType", type: "uint8" },
        { name: "id", type: "uint64" },
        { name: "user", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "SwapVenomToTip3Success",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "tokenRoot", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "SwapVenomToTip3Partial",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "tokenRoot", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "SwapVenomToTip3Cancel",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "SwapTip3EverSuccessTransfer",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
      ],
      outputs: [],
    },
    {
      name: "SwapTip3EverCancelTransfer",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
        { name: "amount", type: "uint128" },
        { name: "tokenRoot", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "SwapVenomWvenomToTip3Unwrap",
      inputs: [
        { name: "user", type: "address" },
        { name: "id", type: "uint64" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "randomNonce_", type: "uint32" },
    { name: "weverRoot", type: "address" },
    { name: "weverVault", type: "address" },
    { name: "weverWallet", type: "address" },
  ],
} as const;
const venomWvenomToTip3Abi = {
  ABIversion: 2,
  version: "2.2",
  header: ["pubkey", "time", "expire"],
  functions: [
    { name: "constructor", inputs: [], outputs: [] },
    { name: "onWeverWallet", inputs: [{ name: "_weverWallet", type: "address" }], outputs: [] },
    {
      name: "buildExchangePayload",
      inputs: [
        { name: "pair", type: "address" },
        { name: "id", type: "uint64" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "expectedAmount", type: "uint128" },
        { name: "amount", type: "uint128" },
        { name: "referrer", type: "address" },
        { name: "outcoming", type: "optional(address)" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "buildCrossPairExchangePayload",
      inputs: [
        { name: "pool", type: "address" },
        { name: "id", type: "uint64" },
        { name: "deployWalletValue", type: "uint128" },
        { name: "expectedAmount", type: "uint128" },
        { name: "outcoming", type: "address" },
        { name: "nextStepIndices", type: "uint32[]" },
        {
          components: [
            { name: "amount", type: "uint128" },
            { name: "pool", type: "address" },
            { name: "outcoming", type: "address" },
            { name: "numerator", type: "uint128" },
            { name: "nextStepIndices", type: "uint32[]" },
          ],
          name: "steps",
          type: "tuple[]",
        },
        { name: "amount", type: "uint128" },
        { name: "referrer", type: "address" },
      ],
      outputs: [{ name: "value0", type: "cell" }],
    },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "value0", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "sender", type: "address" },
        { name: "value3", type: "address" },
        { name: "user", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensBurn",
      inputs: [
        { name: "value0", type: "uint128" },
        { name: "value1", type: "address" },
        { name: "value2", type: "address" },
        { name: "user", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "weverRoot", inputs: [], outputs: [{ name: "weverRoot", type: "address" }] },
    { name: "weverVault", inputs: [], outputs: [{ name: "weverVault", type: "address" }] },
    { name: "everToTip3", inputs: [], outputs: [{ name: "everToTip3", type: "address" }] },
    { name: "weverWallet", inputs: [], outputs: [{ name: "weverWallet", type: "address" }] },
  ],
  data: [
    { key: 1, name: "randomNonce_", type: "uint32" },
    { key: 2, name: "weverRoot", type: "address" },
    { key: 3, name: "weverVault", type: "address" },
    { key: 4, name: "everToTip3", type: "address" },
  ],
  events: [],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "randomNonce_", type: "uint32" },
    { name: "weverRoot", type: "address" },
    { name: "weverVault", type: "address" },
    { name: "everToTip3", type: "address" },
    { name: "weverWallet", type: "address" },
  ],
} as const;
const walletAbi = {
  ABIversion: 2,
  version: "2.2",
  header: ["time"],
  functions: [
    {
      name: "dexPairDepositLiquiditySuccess",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "via_account", type: "bool" },
        {
          components: [
            { name: "step_1_left_deposit", type: "uint128" },
            { name: "step_1_right_deposit", type: "uint128" },
            { name: "step_1_lp_reward", type: "uint128" },
            { name: "step_2_left_to_right", type: "bool" },
            { name: "step_2_right_to_left", type: "bool" },
            { name: "step_2_spent", type: "uint128" },
            { name: "step_2_fee", type: "uint128" },
            { name: "step_2_received", type: "uint128" },
            { name: "step_3_left_deposit", type: "uint128" },
            { name: "step_3_right_deposit", type: "uint128" },
            { name: "step_3_lp_reward", type: "uint128" },
          ],
          name: "result",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "dexPairDepositLiquiditySuccessV2",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "via_account", type: "bool" },
        {
          components: [
            { name: "old_balances", type: "uint128[]" },
            { name: "amounts", type: "uint128[]" },
            { name: "lp_reward", type: "uint128" },
            { name: "result_balances", type: "uint128[]" },
            { name: "invariant", type: "uint128" },
            { name: "differences", type: "uint128[]" },
            { name: "sell", type: "bool[]" },
            { name: "pool_fees", type: "uint128[]" },
            { name: "beneficiary_fees", type: "uint128[]" },
          ],
          name: "result",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "dexPairExchangeSuccess",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "via_account", type: "bool" },
        {
          components: [
            { name: "left_to_right", type: "bool" },
            { name: "spent", type: "uint128" },
            { name: "fee", type: "uint128" },
            { name: "received", type: "uint128" },
          ],
          name: "result",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "dexPairExchangeSuccessV2",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "via_account", type: "bool" },
        {
          components: [
            { name: "spent_token", type: "address" },
            { name: "received_token", type: "address" },
            { name: "spent", type: "uint128" },
            { name: "fee", type: "uint128" },
            { name: "received", type: "uint128" },
          ],
          name: "result",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "dexPairWithdrawSuccess",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "via_account", type: "bool" },
        {
          components: [
            { name: "lp", type: "uint128" },
            { name: "left", type: "uint128" },
            { name: "right", type: "uint128" },
          ],
          name: "result",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    {
      name: "dexPairWithdrawSuccessV2",
      inputs: [
        { name: "id", type: "uint64" },
        { name: "via_account", type: "bool" },
        {
          components: [
            { name: "lp_amount", type: "uint128" },
            { name: "old_balances", type: "uint128[]" },
            { name: "amounts", type: "uint128[]" },
            { name: "result_balances", type: "uint128[]" },
            { name: "invariant", type: "uint128" },
            { name: "differences", type: "uint128[]" },
            { name: "sell", type: "bool[]" },
            { name: "pool_fees", type: "uint128[]" },
            { name: "beneficiary_fees", type: "uint128[]" },
          ],
          name: "result",
          type: "tuple",
        },
      ],
      outputs: [],
    },
    { name: "dexPairOperationCancelled", inputs: [{ name: "id", type: "uint64" }], outputs: [] },
    {
      name: "onAcceptTokensTransfer",
      inputs: [
        { name: "tokenRoot", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "sender", type: "address" },
        { name: "senderWallet", type: "address" },
        { name: "remainingGasTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "onAcceptTokensMint",
      inputs: [
        { name: "tokenRoot", type: "address" },
        { name: "amount", type: "uint128" },
        { name: "remainingGasTo", type: "address" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    {
      name: "onTokenRootDeployed",
      inputs: [
        { name: "callId", type: "uint32" },
        { name: "tokenRoot", type: "address" },
      ],
      outputs: [],
    },
    {
      name: "onRefLastUpdate",
      inputs: [
        { name: "referred", type: "address" },
        { name: "referrer", type: "address" },
        { name: "remainingGasTo", type: "address" },
      ],
      outputs: [],
    },
    { name: "dexAccountOnSuccess", inputs: [{ name: "nonce", type: "uint64" }], outputs: [] },
    {
      name: "dexAccountOnBounce",
      inputs: [
        { name: "nonce", type: "uint64" },
        { name: "functionId", type: "uint32" },
      ],
      outputs: [],
    },
    {
      name: "sendTransaction",
      inputs: [
        { name: "dest", type: "address" },
        { name: "value", type: "uint128" },
        { name: "bounce", type: "bool" },
        { name: "flags", type: "uint8" },
        { name: "payload", type: "cell" },
      ],
      outputs: [],
    },
    { name: "transferOwnership", inputs: [{ name: "newOwner", type: "uint256" }], outputs: [] },
    { name: "constructor", inputs: [], outputs: [] },
    { name: "owner", inputs: [], outputs: [{ name: "owner", type: "uint256" }] },
    { name: "_randomNonce", inputs: [], outputs: [{ name: "_randomNonce", type: "uint256" }] },
  ],
  data: [{ key: 1, name: "_randomNonce", type: "uint256" }],
  events: [
    {
      name: "OwnershipTransferred",
      inputs: [
        { name: "previousOwner", type: "uint256" },
        { name: "newOwner", type: "uint256" },
      ],
      outputs: [],
    },
  ],
  fields: [
    { name: "_pubkey", type: "uint256" },
    { name: "_timestamp", type: "uint64" },
    { name: "_constructorFlag", type: "bool" },
    { name: "owner", type: "uint256" },
    { name: "_randomNonce", type: "uint256" },
  ],
} as const;

export const factorySource = {
  Account: accountAbi,
  Pair: pairAbi,
  Platform: platformAbi,
  Root: rootAbi,
  StablePair: stablePairAbi,
  StablePool: stablePoolAbi,
  TestWeverTunnel: testWeverTunnelAbi,
  TestWeverVault: testWeverVaultAbi,
  Tip3ToVenom: tip3ToVenomAbi,
  TokenFactory: tokenFactoryAbi,
  TokenRoot: tokenRootAbi,
  TokenRootUpgradeable: tokenRootUpgradeableAbi,
  TokenVault: tokenVaultAbi,
  TokenWallet: tokenWalletAbi,
  TokenWalletPlatform: tokenWalletPlatformAbi,
  TokenWalletUpgradeable: tokenWalletUpgradeableAbi,
  Vault: vaultAbi,
  VaultLpTokenPending: vaultLpTokenPendingAbi,
  VenomToTip3: venomToTip3Abi,
  VenomWvenomToTip3: venomWvenomToTip3Abi,
  Wallet: walletAbi,
} as const;

export type FactorySource = typeof factorySource;
export type AccountAbi = typeof accountAbi;
export type PairAbi = typeof pairAbi;
export type PlatformAbi = typeof platformAbi;
export type RootAbi = typeof rootAbi;
export type StablePairAbi = typeof stablePairAbi;
export type StablePoolAbi = typeof stablePoolAbi;
export type TestWeverTunnelAbi = typeof testWeverTunnelAbi;
export type TestWeverVaultAbi = typeof testWeverVaultAbi;
export type Tip3ToVenomAbi = typeof tip3ToVenomAbi;
export type TokenFactoryAbi = typeof tokenFactoryAbi;
export type TokenRootAbi = typeof tokenRootAbi;
export type TokenRootUpgradeableAbi = typeof tokenRootUpgradeableAbi;
export type TokenVaultAbi = typeof tokenVaultAbi;
export type TokenWalletAbi = typeof tokenWalletAbi;
export type TokenWalletPlatformAbi = typeof tokenWalletPlatformAbi;
export type TokenWalletUpgradeableAbi = typeof tokenWalletUpgradeableAbi;
export type VaultAbi = typeof vaultAbi;
export type VaultLpTokenPendingAbi = typeof vaultLpTokenPendingAbi;
export type VenomToTip3Abi = typeof venomToTip3Abi;
export type VenomWvenomToTip3Abi = typeof venomWvenomToTip3Abi;
export type WalletAbi = typeof walletAbi;
