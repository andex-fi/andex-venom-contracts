import fs from "fs";
import BigNumber from "bignumber.js";
import { Dimension, Address } from "locklift";

const TOKEN_CONTRACTS_PATH = "node_modules/tip3/build";
const EMPTY_TVM_CELL = "te6ccgEBAQEAAgAAAA==";

BigNumber.config({ EXPONENTIAL_AT: 257 });

const getRandomNonce = () => (Math.random() * 64000) | 0;

const stringToBytesArray = (dataString: string) => {
  return Buffer.from(dataString).toString("hex");
};

const getBalance = async (contract: any) => {
  const amountStr = locklift.utils.convertAmount(
    await locklift.provider.getBalance(contract.address),
    Dimension.FromNano,
  );

  const amountToNum = parseInt(amountStr, 10);
  return amountToNum;
};

const displayAccount = async (contract: any) => {
  return (
    `Account.${contract.name}${contract.index !== undefined ? "#" + contract.index : ""}` +
    `(address="${contract.address}" balance=${await getBalance(contract)})`
  );
};

async function sleep(ms: number) {
  ms = ms === undefined ? 1000 : ms;
  return new Promise(resolve => setTimeout(resolve, ms));
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const afterRun = async (tx: any) => {
  await new Promise(resolve => setTimeout(resolve, 3000));
};

export const displayTx = (_tx: any) => {
  if (locklift.tracing) {
    console.log(`txId: ${_tx.id.hash ? _tx.id.hash : _tx.id}`);
  } else {
    console.log(`txId: ${_tx.transaction.id.hash ? _tx.transaction.id.hash : _tx.transaction.id}`);
  }
};

export const Constants = {
  tokens: {
    foo: {
      name: "Foo",
      symbol: "Foo",
      decimals: 6,
      upgradeable: true,
    },
    bar: {
      name: "Bar",
      symbol: "Bar",
      decimals: 6,
      upgradeable: true,
    },
    qwe: {
      name: "QWE",
      symbol: "Qwe",
      decimals: 6,
      upgradeable: true,
    },
    tst: {
      name: "Tst",
      symbol: "Tst",
      decimals: 18,
      upgradeable: true,
    },
    coin: {
      name: "Coin",
      symbol: "Coin",
      decimals: 9,
      upgradeable: true,
    },
    wever: {
      name: "Wrapped EVER",
      symbol: "WEVER",
      decimals: 9,
      upgradeable: true,
    },
  } as { [key: string]: { name: string; symbol: string; decimals: number; upgradeable: boolean } },
  LP_DECIMALS: 9,

  TESTS_TIMEOUT: 120000,
};

for (let i = 0; i < 20; i++) {
  Constants.tokens["gen" + i] = {
    name: "Gen" + i,
    symbol: "GEN" + i,
    decimals: 9,
    upgradeable: true,
  };
}

export class Migration {
  log_path: string;
  migration_log: Record<string, any>;
  balance_history: any[];
  constructor(log_path = "migration-log.json") {
    this.log_path = log_path;
    this.migration_log = {};
    this.balance_history = [];
    this._loadMigrationLog();
  }

  _loadMigrationLog() {
    if (fs.existsSync(this.log_path)) {
      const data = fs.readFileSync(this.log_path, "utf8");
      if (data) this.migration_log = JSON.parse(data);
    }
  }

  reset() {
    this.migration_log = {};
    this.balance_history = [];
    this._saveMigrationLog();
  }

  _saveMigrationLog() {
    fs.writeFileSync(this.log_path, JSON.stringify(this.migration_log));
  }

  exists(alias: string | number) {
    return this.migration_log[alias] !== undefined;
  }

  load(contract: { setAddress: (arg0: any) => void }, alias: string | number) {
    if (this.migration_log[alias] !== undefined) {
      contract.setAddress(this.migration_log[alias].address);
    } else {
      throw new Error(`Contract ${alias} not found in the migration`);
    }
    return contract;
  }

  getAddressesByName(name: any) {
    const r = [];
    for (const alias in this.migration_log) {
      if (this.migration_log[alias].name === name) {
        r.push(this.migration_log[alias].address);
      }
    }
    return r;
  }

  getAddress(alias: string | number) {
    if (this.migration_log[alias] !== undefined) {
      return new Address(this.migration_log[alias].address);
    } else {
      throw new Error(`Contract ${alias} not found in the migration`);
    }
  }

  store(contract: any, alias: any) {
    this.migration_log = {
      ...this.migration_log,
      [alias]: {
        address: contract.address,
        name: contract.name,
      },
    };
    this._saveMigrationLog();
  }

  async balancesCheckpoint() {
    const b: Record<string, string> = {};
    for (const alias in this.migration_log) {
      await locklift.provider
        .getBalance(this.migration_log[alias].address)
        .then((e: { toString: () => string }) => (b[alias] = e.toString()))
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        .catch((e: any) => {
          /* ignored */
        });
    }
    this.balance_history.push(b);
  }

  async balancesLastDiff() {
    const d: Record<string, BigNumber> = {};
    for (const alias in this.migration_log) {
      const start = this.balance_history[this.balance_history.length - 2][alias];
      const end = this.balance_history[this.balance_history.length - 1][alias];
      if (end !== start) {
        const change = new BigNumber(end).minus(start || 0).shiftedBy(-9);
        d[alias] = change;
      }
    }
    return d;
  }

  async logGas() {
    await this.balancesCheckpoint();
    const diff = await this.balancesLastDiff();
    if (diff) {
      console.log(`### GAS STATS ###`);
      for (const alias in diff) {
        console.log(`${alias}: ${diff[alias].gt(0) ? "+" : ""}${diff[alias].toFixed(9)} EVER`);
      }
    }
  }
}

function logExpectedDepositV2(expected: any, tokens: any) {
  const N_COINS = tokens.length;
  console.log(`Deposit: `);
  for (let i = 0; i < N_COINS; i++) {
    if (new BigNumber(expected.amounts[i]).gt(0)) {
      console.log(
        `    ` +
          `${expected.amounts[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)} ${tokens[i].symbol}`,
      );
    }
  }
  console.log(`Expected LP reward:`);
  console.log(`${expected.lp_reward.shiftedBy(-Constants.LP_DECIMALS).toFixed(Constants.LP_DECIMALS)}`);

  console.log(`Fees: `);
  for (let i = 0; i < N_COINS; i++) {
    if (new BigNumber(expected.pool_fees[i]).gt(0)) {
      console.log(
        `     Pool fee ` +
          `${expected.pool_fees[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)} ${tokens[i].symbol}`,
      );
    }
    if (new BigNumber(expected.beneficiary_fees[i]).gt(0)) {
      console.log(
        `     DAO fee ` +
          `${expected.beneficiary_fees[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)} ${
            tokens[i].symbol
          }`,
      );
    }
  }
  console.log(` ---DEBUG--- `);
  console.log(`Invariant: ${expected.invariant}`);
  for (let i = 0; i < N_COINS; i++) {
    console.log(`${tokens[i].symbol}:`);
    console.log(
      `     old_balances: ` + `${expected.old_balances[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)}`,
    );
    console.log(
      `     result_balances: ` +
        `${expected.result_balances[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)}`,
    );
    console.log(
      `     old_balances: ` + `${expected.old_balances[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)}`,
    );
    console.log(
      `     change: ` +
        `${expected.result_balances[i]
          .minus(expected.old_balances[i])
          .shiftedBy(-tokens[i].decimals)
          .toFixed(tokens[i].decimals)}`,
    );
    console.log(
      `     differences: ` + `${expected.differences[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)}`,
    );
    console.log(
      `     pool_fees: ` + `${expected.pool_fees[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)}`,
    );
    console.log(
      `     beneficiary_fees: ` +
        `${expected.beneficiary_fees[i].shiftedBy(-tokens[i].decimals).toFixed(tokens[i].decimals)}`,
    );
    console.log(`     sell: ${expected.sell[i]}`);
  }
}

module.exports = {
  Migration,
  Constants,
  getRandomNonce,
  stringToBytesArray,
  sleep,
  getBalance,
  displayAccount,
  displayTx,
  afterRun,
  TOKEN_CONTRACTS_PATH,
  EMPTY_TVM_CELL,
  logExpectedDepositV2,
};
