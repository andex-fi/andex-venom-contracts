import { expect } from "chai";
import { Address } from "locklift";
import { TonClient } from "@eversdk/core";

const logger = require("mocha-logger");
const client = new TonClient()

async function sleep(ms: any) {
    return;
}

const isValidVenomAddress = (address: string) => /^(?:-1|0):[0-9a-fA-F]{64}$/.test(address);

const afterRun = async (tx: any) => {
    await sleep(100000)
}

const wait_acc_deployed = async function (addr: Address) {
    await client.net.wait_for_collection({
        collection: 'accounts',
        filter: {
            id: { eq: addr },
            balance: { gt: `0x0` }
        },
        result: 'id'
    });
}

const calcExpectedReward = function(prevRewardTime: any, newRewardTime: any, _rewardPerSec: any) {
    const time_passed = newRewardTime - prevRewardTime;
    return _rewardPerSec * time_passed;
}

const checkReward = async function(
    userWallet: any, 
    prevBalance: any, 
    prevRewardTime: any, 
    newRewardTime: any, 
    _rewardPerSec: any
) {
    const user_bal_after = await userWallet.balance();
    // console.log(user_bal_after.toString());
    // console.log(prevBalance.toString());
    const reward = user_bal_after - prevBalance;
    // console.log(user_bal_after, prevBalance)

    const expected_reward = calcExpectedReward(prevRewardTime, newRewardTime, _rewardPerSec);

    expect(reward).to.be.equal(expected_reward, 'Bad reward');
    return expected_reward;
}