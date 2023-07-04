const sampleAbi = {"ABIversion":2,"version":"2.2","header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]},{"name":"setState","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]},{"name":"getDetails","inputs":[],"outputs":[{"name":"_state","type":"uint256"}]}],"data":[{"key":1,"name":"_nonce","type":"uint16"}],"events":[{"name":"StateChange","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]}],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"_nonce","type":"uint16"},{"name":"state","type":"uint256"}]} as const
const userDataAbi = {"ABIversion":2,"version":"2.2","header":["time","expire"],"functions":[{"name":"constructor","inputs":[],"outputs":[]},{"name":"getDetails","inputs":[{"name":"answerId","type":"uint32"}],"outputs":[{"components":[{"name":"faucet","type":"address"},{"name":"user","type":"address"},{"name":"current_version","type":"uint32"},{"name":"lastClaimTime","type":"uint32"}],"name":"value0","type":"tuple"}]},{"name":"processClaim","inputs":[{"name":"send_gas_to","type":"address"},{"name":"nonce","type":"uint32"},{"name":"code_version","type":"uint32"}],"outputs":[]},{"name":"upgrade","inputs":[{"name":"new_code","type":"cell"},{"name":"new_version","type":"uint32"},{"name":"send_gas_to","type":"address"}],"outputs":[]}],"data":[],"events":[{"name":"UserDataUpdated","inputs":[{"name":"prev_version","type":"uint32"},{"name":"new_version","type":"uint32"}],"outputs":[]}],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"current_version","type":"uint32"},{"name":"platform_code","type":"cell"},{"name":"faucet","type":"address"},{"name":"user","type":"address"},{"name":"claimAmount","type":"uint128"},{"name":"lastClaimTime","type":"map(address,uint32)"}]} as const
const walletAbi = {"ABIversion":2,"version":"2.2","header":["pubkey","time","expire"],"functions":[{"name":"sendTransaction","inputs":[{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"bounce","type":"bool"},{"name":"flags","type":"uint8"},{"name":"payload","type":"cell"}],"outputs":[]},{"name":"transferOwnership","inputs":[{"name":"newOwner","type":"uint256"}],"outputs":[]},{"name":"constructor","inputs":[],"outputs":[]},{"name":"owner","inputs":[],"outputs":[{"name":"owner","type":"uint256"}]},{"name":"_randomNonce","inputs":[],"outputs":[{"name":"_randomNonce","type":"uint256"}]}],"data":[{"key":1,"name":"_randomNonce","type":"uint256"}],"events":[{"name":"OwnershipTransferred","inputs":[{"name":"previousOwner","type":"uint256"},{"name":"newOwner","type":"uint256"}],"outputs":[]}],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"owner","type":"uint256"},{"name":"_randomNonce","type":"uint256"}]} as const

export const factorySource = {
    Sample: sampleAbi,
    UserData: userDataAbi,
    Wallet: walletAbi
} as const

export type FactorySource = typeof factorySource
export type SampleAbi = typeof sampleAbi
export type UserDataAbi = typeof userDataAbi
export type WalletAbi = typeof walletAbi
