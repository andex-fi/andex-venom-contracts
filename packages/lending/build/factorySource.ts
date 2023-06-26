const platformAbi = {"ABIversion":2,"version":"2.2","header":["time","expire"],"functions":[{"name":"constructor","inputs":[{"name":"contractCode","type":"cell"},{"name":"params","type":"cell"}],"outputs":[]}],"data":[{"key":1,"name":"root","type":"address"},{"key":2,"name":"platformType","type":"uint8"},{"key":3,"name":"initialData","type":"cell"},{"key":4,"name":"platformCode","type":"cell"}],"events":[],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"root","type":"address"},{"name":"platformType","type":"uint8"},{"name":"initialData","type":"cell"},{"name":"platformCode","type":"cell"}]} as const
const sampleAbi = {"ABIversion":2,"version":"2.3","header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]},{"name":"setState","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]},{"name":"getDetails","inputs":[],"outputs":[{"name":"_state","type":"uint256"}]}],"data":[{"key":1,"name":"_nonce","type":"uint16"}],"events":[{"name":"StateChange","inputs":[{"name":"_state","type":"uint256"}],"outputs":[]}],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"_nonce","type":"uint16"},{"name":"state","type":"uint256"}]} as const
const userAccountAbi = {"ABIversion":2,"version":"2.2","header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[],"outputs":[]},{"name":"getKnownMarkets","inputs":[{"name":"answerId","type":"uint32"}],"outputs":[{"name":"value0","type":"map(uint32,bool)"}]},{"name":"getAllMarketsInfo","inputs":[{"name":"answerId","type":"uint32"}],"outputs":[{"components":[{"name":"exists","type":"bool"},{"name":"_marketId","type":"uint32"},{"name":"suppliedTokens","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"accountHealth","type":"tuple"},{"components":[{"name":"tokensBorrowed","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"index","type":"tuple"}],"name":"borrowInfo","type":"tuple"}],"name":"value0","type":"map(uint32,tuple)"}]},{"name":"getMarketInfo","inputs":[{"name":"answerId","type":"uint32"},{"name":"marketId","type":"uint32"}],"outputs":[{"components":[{"name":"exists","type":"bool"},{"name":"_marketId","type":"uint32"},{"name":"suppliedTokens","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"accountHealth","type":"tuple"},{"components":[{"name":"tokensBorrowed","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"index","type":"tuple"}],"name":"borrowInfo","type":"tuple"}],"name":"value0","type":"tuple"}]},{"name":"upgradeContractCode","inputs":[{"name":"code","type":"cell"},{"name":"updateParams","type":"cell"},{"name":"codeVersion","type":"uint32"}],"outputs":[]},{"name":"getOwner","inputs":[{"name":"answerId","type":"uint32"}],"outputs":[{"name":"value0","type":"address"}]},{"name":"writeSupplyInfo","inputs":[{"name":"marketId","type":"uint32"},{"name":"tokensToSupply","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"index","type":"tuple"}],"outputs":[]},{"name":"withdraw","inputs":[{"name":"userTip3Wallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"tokensToWithdraw","type":"uint256"}],"outputs":[]},{"name":"requestWithdrawInfo","inputs":[{"name":"userTip3Wallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"tokensToWithdraw","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"updatedIndexes","type":"map(uint32,tuple)"}],"outputs":[]},{"name":"writeWithdrawInfo","inputs":[{"name":"userTip3Wallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"tokensToWithdraw","type":"uint256"},{"name":"tokensToSend","type":"uint256"}],"outputs":[]},{"name":"borrow","inputs":[{"name":"marketId","type":"uint32"},{"name":"amountToBorrow","type":"uint256"},{"name":"userTip3Wallet","type":"address"}],"outputs":[]},{"name":"borrowUpdateIndexes","inputs":[{"name":"marketId","type":"uint32"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"updatedIndexes","type":"map(uint32,tuple)"},{"name":"userTip3Wallet","type":"address"},{"name":"toBorrow","type":"uint256"}],"outputs":[]},{"name":"writeBorrowInformation","inputs":[{"name":"marketId","type":"uint32"},{"name":"toBorrow","type":"uint256"},{"name":"userTip3Wallet","type":"address"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"marketIndex","type":"tuple"}],"outputs":[]},{"name":"sendRepayInfo","inputs":[{"name":"userTip3Wallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"tokensForRepay","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"updatedIndexes","type":"map(uint32,tuple)"}],"outputs":[]},{"name":"writeRepayInformation","inputs":[{"name":"userTip3Wallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"tokensToReturn","type":"uint256"},{"components":[{"name":"tokensBorrowed","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"index","type":"tuple"}],"name":"bi","type":"tuple"}],"outputs":[]},{"name":"convertVTokens","inputs":[{"name":"amount","type":"uint256"},{"name":"marketId","type":"uint32"}],"outputs":[]},{"name":"requestConversionInfo","inputs":[{"name":"_amount","type":"uint256"},{"name":"_marketId","type":"uint32"}],"outputs":[]},{"name":"writeConversionInfo","inputs":[{"name":"_amount","type":"uint256"},{"name":"positive","type":"bool"},{"name":"marketId","type":"uint32"}],"outputs":[]},{"name":"checkUserAccountHealth","inputs":[{"name":"gasTo","type":"address"}],"outputs":[]},{"name":"updateUserAccountHealth","inputs":[{"name":"gasTo","type":"address"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"_accountHealth","type":"tuple"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"updatedIndexes","type":"map(uint32,tuple)"},{"name":"dataToTransfer","type":"cell"}],"outputs":[]},{"name":"removeMarket","inputs":[{"name":"marketId","type":"uint32"}],"outputs":[]},{"name":"requestLiquidationInformation","inputs":[{"name":"venomWallet","type":"address"},{"name":"tip3UserWallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"marketToLiquidate","type":"uint32"},{"name":"tokensProvided","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"updatedIndexes","type":"map(uint32,tuple)"}],"outputs":[]},{"name":"liquidateVTokens","inputs":[{"name":"venomWallet","type":"address"},{"name":"tip3UserWallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"marketToLiquidate","type":"uint32"},{"name":"tokensToSeize","type":"uint256"},{"name":"tokensToReturn","type":"uint256"},{"components":[{"name":"tokensBorrowed","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"index","type":"tuple"}],"name":"borrowInfo","type":"tuple"}],"outputs":[]},{"name":"grantVTokens","inputs":[{"name":"targetUser","type":"address"},{"name":"tip3UserWallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"marketToLiquidate","type":"uint32"},{"name":"tokensToSeize","type":"uint256"},{"name":"tokensToReturn","type":"uint256"}],"outputs":[]},{"name":"abortLiquidation","inputs":[{"name":"venomWallet","type":"address"},{"name":"tip3UserWallet","type":"address"},{"name":"marketId","type":"uint32"},{"name":"tokensToReturn","type":"uint256"}],"outputs":[]},{"name":"disableBorrowLock","inputs":[],"outputs":[]},{"name":"enterMarket","inputs":[{"name":"marketId","type":"uint32"}],"outputs":[]},{"name":"withdrawExtraVenoms","inputs":[],"outputs":[]},{"name":"borrowLock","inputs":[],"outputs":[{"name":"borrowLock","type":"bool"}]},{"name":"liquidationLock","inputs":[],"outputs":[{"name":"liquidationLock","type":"bool"}]},{"name":"owner","inputs":[],"outputs":[{"name":"owner","type":"address"}]},{"name":"userAccountManager","inputs":[],"outputs":[{"name":"userAccountManager","type":"address"}]},{"name":"contractCodeVersion","inputs":[],"outputs":[{"name":"contractCodeVersion","type":"uint32"}]},{"name":"accountHealth","inputs":[],"outputs":[{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"accountHealth","type":"tuple"}]}],"data":[{"key":1,"name":"owner","type":"address"}],"events":[],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"borrowLock","type":"bool"},{"name":"liquidationLock","type":"bool"},{"name":"owner","type":"address"},{"name":"userAccountManager","type":"address"},{"name":"contractCodeVersion","type":"uint32"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"accountHealth","type":"tuple"},{"name":"knownMarkets","type":"map(uint32,bool)"},{"components":[{"name":"exists","type":"bool"},{"name":"_marketId","type":"uint32"},{"name":"suppliedTokens","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"accountHealth","type":"tuple"},{"components":[{"name":"tokensBorrowed","type":"uint256"},{"components":[{"name":"nom","type":"uint256"},{"name":"denom","type":"uint256"}],"name":"index","type":"tuple"}],"name":"borrowInfo","type":"tuple"}],"name":"markets","type":"map(uint32,tuple)"}]} as const
const userAccountManagerAbi = {"ABIversion":2,"version":"2.2","header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[],"outputs":[]},{"name":"contractCodeVersion","inputs":[],"outputs":[{"name":"contractCodeVersion","type":"uint32"}]},{"name":"marketAddress","inputs":[],"outputs":[{"name":"marketAddress","type":"address"}]},{"name":"modules","inputs":[],"outputs":[{"name":"modules","type":"map(uint8,address)"}]},{"name":"existingModules","inputs":[],"outputs":[{"name":"existingModules","type":"map(address,bool)"}]},{"name":"userAccountCodes","inputs":[],"outputs":[{"name":"userAccountCodes","type":"map(uint32,cell)"}]}],"data":[],"events":[{"name":"AccountCreated","inputs":[{"name":"tonWallet","type":"address"},{"name":"userAddress","type":"address"}],"outputs":[]}],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"},{"name":"contractCodeVersion","type":"uint32"},{"name":"marketAddress","type":"address"},{"name":"modules","type":"map(uint8,address)"},{"name":"existingModules","type":"map(address,bool)"},{"name":"userAccountCodes","type":"map(uint32,cell)"}]} as const

export const factorySource = {
    Platform: platformAbi,
    Sample: sampleAbi,
    UserAccount: userAccountAbi,
    UserAccountManager: userAccountManagerAbi
} as const

export type FactorySource = typeof factorySource
export type PlatformAbi = typeof platformAbi
export type SampleAbi = typeof sampleAbi
export type UserAccountAbi = typeof userAccountAbi
export type UserAccountManagerAbi = typeof userAccountManagerAbi
