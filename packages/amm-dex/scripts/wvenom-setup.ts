/* eslint-disable @typescript-eslint/no-non-null-assertion */
// import fs from "fs";
import BigNumber from "bignumber.js";
import { Constants, Migration, afterRun, EMPTY_TVM_CELL, getRandomNonce, displayTx } from "./utils";
import { Command } from "commander";
import { Dimension, Address, toNano, zeroAddress } from "locklift";

BigNumber.config({ EXPONENTIAL_AT: 257 });

const program = new Command();

let tx;

async function main() {
  const migration = new Migration();

  program.allowUnknownOption().option("-wa, --wrap_amount <wrap_amount>", "wrap amount");

  program.parse(process.argv);

  const options = program.opts();
  options.wrap_amount = options.wrap_amount || "60";

  const tokenData = Constants.tokens["wvenom"];

  const networkConfig = locklift.context.network.config;
  const giver = networkConfig.giver.address;
  const giverAddress = new Address(giver);

  console.log(
    `Giver balance: ${locklift.utils.convertAmount(
      await locklift.provider.getBalance(giverAddress),
      Dimension.FromNano,
    )}`,
  );

  const signer = await locklift.keystore.getSigner("0");

  const Account2 = migration.load(await locklift.factory.getAccountsFactory("Wallet"), "Account2");

  const user = Account2.getAccount(Account2.address, signer!.publicKey);

  Account2.afterRun = afterRun;

  console.log(`Owner: ${Account2.address}`);

  console.log(`Deploying tunnel`);

  // const Tunnel = await locklift.factory.getContractArtifacts("TestWvenomTunnel");

  const { contract: tunnel } = await locklift.factory.deployContract({
    contract: "WvenomTunnel",
    constructorParams: {
      sources: [],
      destinations: [],
      owner_: Account2.address,
    },
    initParams: {
      _randomNonce: getRandomNonce(),
    },
    publicKey: signer!.publicKey,
    value: toNano(5),
  });

  console.log(`Tunnel address: ${tunnel.address}`);
  migration.store(tunnel.address, `${tokenData.symbol}Tunnel`);

  console.log(`Deploying WVENOM`);

  const TokenRoot = await locklift.factory.getContractArtifacts("TokenRootUpgradeable");

  const TokenWallet = await locklift.factory.getContractArtifacts("TokenWalletUpgradeable");

  const TokenWalletPlatform = await locklift.factory.getContractArtifacts("TokenWalletPlatform");

  const { contract: root } = await locklift.factory.deployContract({
    contract: "TokenRootUpgradeable",
    constructorParams: {
      initialSupplyTo: zeroAddress,
      initialSupply: "0",
      deployWalletValue: "0",
      mintDisabled: false,
      burnByRootDisabled: false,
      burnPaused: false,
      remainingGasTo: zeroAddress,
    },
    initParams: {
      randomNonce_: getRandomNonce(),
      deployer_: zeroAddress,
      name_: tokenData.name,
      symbol_: tokenData.symbol,
      decimals_: tokenData.decimals,
      walletCode_: TokenWallet.code,
      rootOwner_: tunnel.address,
      platformCode_: TokenWalletPlatform.code,
    },
    publicKey: signer!.publicKey,
    value: toNano(3),
  });

  // root.afterRun = afterRun;

  console.log(`WVENOM root: ${root.address}`);
  migration.store(TokenRoot, `${tokenData.symbol}Root`);

  console.log(`Deploying vault`);

  // const WrappedVENOMVault = await locklift.factory.getContractArtifacts("TestWvenomVault");

  const { contract: vault } = await locklift.factory.deployContract({
    contract: "WvenomVault",
    constructorParams: {
      owner_: Account2.address,
      root_tunnel: tunnel.address,
      root: root.address,
      receive_safe_fee: toNano(1),
      settings_deploy_wallet_grams: toNano(0.1),
      initial_balance: toNano(1),
    },
    initParams: {
      _randomNonce: getRandomNonce(),
    },
    publicKey: signer!.publicKey,
    value: toNano(2),
  });

  console.log(`Vault address: ${vault.address}`);
  migration.store(vault, `${tokenData.symbol}Vault`);

  console.log(`Adding tunnel (vault, root)`);

  tx = await tunnel.methods
    .__updateTunnel({
      source: vault.address,
      destination: root.address,
    })
    .send({
      from: Account2.address,
      amount: toNano(1),
    });
  displayTx(tx);

  console.log(`Draining vault`);

  tx = await vault.methods
    .drain({
      receiver: Account2.address,
    })
    .send({
      from: Account2.address,
      amount: toNano(1),
    });

  displayTx(tx);

  console.log(`Wrap ${options.wrap_amount} VENOM`);

  tx = await user.run({
    method: "sendTransaction",
    params: {
      dest: vault.address,
      value: toNano(options.wrap_amount),
      bounce: false,
      flags: 1,
      payload: EMPTY_TVM_CELL,
    },
    publicKey: signer!.publicKey,
  });

  displayTx(tx);

  const tokenWalletAddress = (
    await root.methods
      .walletOf({
        answerId: 0,
        walletOwner: Account2.address,
      })
      .call()
  ).value0;

  console.log(`TokenWallet`, tokenWalletAddress);

  migration.store(tokenWalletAddress, tokenData.symbol + "Wallet2");
  const tokenWallet = await locklift.factory.getDeployedContract("TokenWalletUpgradeable", tokenWalletAddress);

  const balance = (await tokenWallet.methods.balance({ answerId: 0 }).call()).value0;
  const balanceToString = new BigNumber(balance).shiftedBy(-9).toString();

  console.log(`Account2 WVENOM balance: ${balanceToString}`);

  console.log(`Giver balance: ${toNano(await locklift.provider.getBalance(giverAddress))}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
