const accountAbi = {"ABIversion":2,"version":"2.2","header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[],"outputs":[]},{"name":"resetGas","inputs":[{"name":"receiver","type":"address"}],"outputs":[]},{"name":"getRoot","inputs":[{"name":"answerId","type":"uint32"}],"outputs":[{"name":"value0","type":"address"}]},{"name":"getOwner","inputs":[{"name":"answerId","type":"uint32"}],"outputs":[{"name":"value0","type":"address"}]},{"name":"getVersion","inputs":[{"name":"answerId","type":"uint32"}],"outputs":[{"name":"value0","type":"uint32"}]},{"name":"getWalletData","inputs":[{"name":"answerId","type":"uint32"},{"name":"token_root","type":"address"}],"outputs":[{"name":"value0","type":"address"},{"name":"value1","type":"uint128"}]},{"name":"requestUpgrade","inputs":[{"name":"send_gas_to","type":"address"}],"outputs":[]},{"name":"upgrade","inputs":[{"name":"code","type":"cell"},{"name":"new_version","type":"uint32"},{"name":"send_gas_to","type":"address"}],"outputs":[]}],"data":[],"events":[],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"root","type":"address"},{"name":"current_version","type":"uint32"},{"name":"owner","type":"address"},{"name":"_wallets","type":"map(address,address)"},{"name":"_balances","type":"map(address,uint128)"},{"name":"platform_code","type":"cell"}]} as const
const pairAbi = {"ABIversion":2,"version":"2.2","header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[],"outputs":[]}],"data":[],"events":[],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"}]} as const

export const factorySource = {
    Account: accountAbi,
    Pair: pairAbi
} as const

export type FactorySource = typeof factorySource
export type AccountAbi = typeof accountAbi
export type PairAbi = typeof pairAbi
