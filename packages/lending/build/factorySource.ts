const platformAbi = {"ABIversion":2,"version":"2.2","header":["time","expire"],"functions":[{"name":"constructor","inputs":[{"name":"contractCode","type":"cell"},{"name":"params","type":"cell"}],"outputs":[]}],"data":[{"key":1,"name":"root","type":"address"},{"key":2,"name":"platformType","type":"uint8"},{"key":3,"name":"initialData","type":"cell"},{"key":4,"name":"platformCode","type":"cell"}],"events":[],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"root","type":"address"},{"name":"platformType","type":"uint8"},{"name":"initialData","type":"cell"},{"name":"platformCode","type":"cell"}]} as const
const sampleAbi = {"ABIversion":2,"version":"2.3","header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]},{"name":"setState","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]},{"name":"getDetails","inputs":[],"outputs":[{"name":"_state","type":"uint256"}]}],"data":[{"key":1,"name":"_nonce","type":"uint16"}],"events":[{"name":"StateChange","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]}],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"_nonce","type":"uint16"},{"name":"state","type":"uint256"}]} as const

export const factorySource = {
    Platform: platformAbi,
    Sample: sampleAbi
} as const

export type FactorySource = typeof factorySource
export type PlatformAbi = typeof platformAbi
export type SampleAbi = typeof sampleAbi
