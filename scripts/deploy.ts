/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { Migration, displayTx, Constants } from "./utils";
import { Command } from "commander";
import { toNano, WalletTypes, getRandomNonce, zeroAddress, Address, Dimension } from "locklift";
// import BigNumber from "bignumber.js";

async function main() {
  const program = new Command();
  const migration = new Migration();

  migration.reset();

  program
    .allowUnknownOption()
    .option("-o, --owner <owner>", "owner")
    .option("-wa, --wrap_amount <wrap_amount>", "wrap_amount");

  program.parse(process.argv);

  const options = program.opts();
  options.wrap_amount = options.wrap_amount || "60";

  const newOwner = new Address(options.owner);

  const tokenData = Constants.tokens["wvenom"];

  const networkConfig = locklift.context.network.config;
  const giver = networkConfig.giver.address;
  const giverAddress = new Address(giver);

  console.log(
    `Giver balance: ${locklift.utils.convertAmount(
      await locklift.provider.getBalance(giverAddress),
      Dimension.ToNano,
    )}`,
  );

  // ============ DEPLOYER ACCOUNT ============

  const signer = await locklift.keystore.getSigner("0");
  const account = (
    await locklift.factory.accounts.addNewAccount({
      type: WalletTypes.EverWallet,
      value: toNano(10),
      publicKey: signer!.publicKey,
    })
  ).account;

  await locklift.provider.sendMessage({
    sender: account.address,
    recipient: account.address,
    amount: toNano(1),
    bounce: false,
  });

  const name = `Account1`;
  migration.store(account, name);
  console.log(`${name}: ${account.address}`);

  const account2 = (
    await locklift.factory.accounts.addNewAccount({
      type: WalletTypes.EverWallet,
      value: toNano(10),
      publicKey: signer!.publicKey,
    })
  ).account;

  await locklift.provider.sendMessage({
    sender: account2.address,
    recipient: account2.address,
    amount: toNano(1),
    bounce: false,
  });

  const name2 = `Account2`;
  migration.store(account2, name2);
  console.log(`${name2}: ${account2.address}`);

  // ============ TOKEN FACTORY ============
  // const TokenFactory = await locklift.factory.getContractArtifacts(
  //   'TokenFactory',
  // );

  const TokenRoot = await locklift.factory.getContractArtifacts("TokenRootUpgradeable");
  const TokenWallet = await locklift.factory.getContractArtifacts("TokenWalletUpgradeable");
  const TokenWalletPlatform = await locklift.factory.getContractArtifacts("TokenWalletPlatform");

  const { contract: tokenFactory } = await locklift.factory.deployContract({
    contract: "TokenFactory",
    constructorParams: {
      _owner: account.address,
    },
    initParams: {
      randomNonce_: getRandomNonce(),
    },
    publicKey: signer!.publicKey,
    value: toNano(2),
  });
  migration.store(tokenFactory, "TokenFactory");

  console.log(`TokenFactory: ${tokenFactory.address}`);

  console.log(`TokenFactory.setRootCode`);
  await tokenFactory.methods.setRootCode({ _rootCode: TokenRoot.code }).send({
    from: account.address,
    amount: toNano(2),
  });

  console.log(`TokenFactory.setWalletCode`);
  await tokenFactory.methods.setWalletCode({ _walletCode: TokenWallet.code }).send({
    from: account.address,
    amount: toNano(2),
  });

  console.log(`TokenFactory.setWalletPlatformCode`);
  await tokenFactory.methods.setWalletPlatformCode({ _walletPlatformCode: TokenWalletPlatform.code }).send({
    from: account.address,
    amount: toNano(2),
  });

  // ============ ROOT AND VAULT ============
  const Platform = await locklift.factory.getContractArtifacts("Platform");
  const Account = await locklift.factory.getContractArtifacts("Account");
  const Pair = await locklift.factory.getContractArtifacts("Pair");
  const StablePair = await locklift.factory.getContractArtifacts("StablePair");
  const StablePool = await locklift.factory.getContractArtifacts("StablePool");
  const TokenVault = await locklift.factory.getContractArtifacts("TokenVault");
  const VaultLpTokenPending = await locklift.factory.getContractArtifacts("VaultLpTokenPending");

  console.log(`Deploying Root...`);
  const { contract: dexRoot, tx: dexTx } = await locklift.factory.deployContract({
    contract: "Root",
    constructorParams: {
      initial_owner: account.address,
      initial_vault: zeroAddress,
    },
    initParams: { _nonce: getRandomNonce() },
    publicKey: signer!.publicKey,
    value: toNano(2),
  });
  migration.store(dexRoot, "Root");
  displayTx(dexTx.transaction);
  console.log(`Root address: ${dexRoot.address}`);

  console.log(`Root: installing Platform code...`);

  let tx = await dexRoot.methods.installPlatformOnce({ code: Platform.code }).send({
    from: account.address,
    amount: toNano(2),
  });
  displayTx(tx);

  console.log(`Root: installing Account code...`);

  tx = await dexRoot.methods.installOrUpdateAccountCode({ code: Account.code }).send({
    from: account.address,
    amount: toNano(2),
  });
  displayTx(tx);

  console.log(`Root: installing DexPair CONSTANT_PRODUCT code...`);

  tx = await dexRoot.methods.installOrUpdatePairCode({ code: Pair.code, pool_type: 1 }).send({
    from: account.address,
    amount: toNano(2),
  });
  displayTx(tx);

  console.log(`Root: installing DexStablePool code...`);

  tx = await dexRoot.methods.installOrUpdatePoolCode({ code: StablePool.code, pool_type: 3 }).send({
    from: account.address,
    amount: toNano(2),
  });
  displayTx(tx);

  console.log(`Root: installing DexPair STABLESWAP code...`);

  tx = await dexRoot.methods.installOrUpdatePairCode({ code: StablePair.code, pool_type: 2 }).send({
    from: account.address,
    amount: toNano(2),
  });
  displayTx(tx);

  console.log(`Root: installing VaultLpTokenPending code...`);

  tx = await dexRoot.methods
    .installOrUpdateLpTokenPendingCode({
      _newCode: VaultLpTokenPending.code,
      _remainingGasTo: account.address,
    })
    .send({
      from: account.address,
      amount: toNano(2),
    });
  displayTx(tx);

  console.log("Root: installing token vault code...");

  tx = await dexRoot.methods
    .installOrUpdateTokenVaultCode({
      _newCode: TokenVault.code,
      _remainingGasTo: account.address,
    })
    .send({
      from: account.address,
      amount: toNano(2),
    });
  displayTx(tx);

  tx = await dexRoot.methods
    .setTokenFactory({
      _newTokenFactory: tokenFactory.address,
      _remainingGasTo: account.address,
    })
    .send({
      from: account.address,
      amount: toNano(2),
    });
  displayTx(tx);

  console.log(`Deploying Vault...`);
  const { contract: dexVault } = await locklift.factory.deployContract({
    contract: "Vault",
    constructorParams: {
      owner_: account.address,
      root_: dexRoot.address,
    },
    initParams: {
      _nonce: getRandomNonce(),
    },
    publicKey: signer!.publicKey,
    value: toNano(2),
  });
  console.log(`Vault address: ${dexVault.address}`);
  migration.store(dexVault, "Vault");

  console.log(`Vault: installing Platform code...`);

  tx = await dexVault.methods.installPlatformOnce({ code: Platform.code }).send({
    from: account.address,
    amount: toNano(2),
  });
  displayTx(tx);

  console.log(`Root: installing vault address...`);

  tx = await dexRoot.methods.setVaultOnce({ new_vault: dexVault.address }).send({
    from: account.address,
    amount: toNano(2),
  });
  displayTx(tx);

  console.log(`Root: set Dex is active...`);

  tx = await dexRoot.methods.setActive({ new_active: true }).send({
    from: account.address,
    amount: toNano(2),
  });
  displayTx(tx);

  if (options.owner) {
    console.log(`Transferring DEX ownership from ${account.address} to ${options.owner}`);

    console.log(`Set manager for Root, manager = ${account.address}`);
    let tx = await dexRoot.methods.setManager({ _newManager: account.address }).send({
      from: account.address,
      amount: toNano(2),
    });
    displayTx(tx);

    console.log(`Transfer for Root: ${dexRoot.address}`);

    tx = await dexRoot.methods
      .transferOwner({
        new_owner: newOwner,
      })
      .send({
        from: account.address,
        amount: toNano(1),
      });
    displayTx(tx);

    console.log(`Transfer for Vault: ${dexRoot.address}`);

    tx = await dexVault.methods
      .transferOwner({
        new_owner: newOwner,
      })
      .send({
        from: account.address,
        amount: toNano(1),
      });
    displayTx(tx);

    console.log(`Transfer for TokenFactory: ${dexRoot.address}`);

    tx = await tokenFactory.methods
      .transferOwner({
        answerId: 0,
        newOwner: newOwner,
      })
      .send({
        from: account.address,
        amount: toNano(1),
      });
    displayTx(tx);
  }

  // ===============DEPLOY WVENOM================================
  console.log(`Owner: ${account2.address}`);

  console.log(`Deploying Tunnel`);

  const { contract: tunnel } = await locklift.factory.deployContract({
    contract: "TestWeverTunnel",
    constructorParams: {
      sources: [],
      destinations: [],
      owner_: account2.address,
    },
    initParams: {
      _randomNonce: getRandomNonce(),
    },
    publicKey: signer!.publicKey,
    value: toNano(5),
  });

  console.log(`Tunnel address: ${tunnel.address}`);
  migration.store(tunnel, `${tokenData.symbol}Tunnel`);

  console.log(`Deploying WVENOM`);

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

  console.log(`WVENOM root: ${root.address}`);
  migration.store(root, `${tokenData.symbol}Root`);

  console.log(`Deploying Vault`);

  const { contract: vault } = await locklift.factory.deployContract({
    contract: "TestWeverVault",
    constructorParams: {
      owner_: account2.address,
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
      from: account2.address,
      amount: toNano(1),
    });
  displayTx(tx);

  console.log(`Draining vault`);

  tx = await vault.methods
    .drain({
      receiver: account2.address,
    })
    .send({
      from: account2.address,
      amount: toNano(1),
    });

  displayTx(tx);

  /* 
  =======================Deploy the Tip3ToVenom contract===============================
  */
  const { contract: Tip3ToVenom } = await locklift.factory.deployContract({
    contract: "Tip3ToVenom",
    publicKey: signer!.publicKey,
    initParams: {
      randomNonce_: getRandomNonce(),
      weverRoot: root.address,
      weverVault: vault.address,
    },
    constructorParams: {},
    value: toNano(2),
  });

  migration.store(Tip3ToVenom, "Tip3ToVenom");
  console.log(`${"Tip3ToVenom"}: ${Tip3ToVenom.address}`);

  const { contract: venomTip3 } = await locklift.factory.deployContract({
    contract: "VenomToTip3",
    constructorParams: {},
    initParams: {
      randomNonce_: getRandomNonce(),
      weverRoot: root.address,
      weverVault: vault.address,
    },
    publicKey: signer?.publicKey ?? "",
    value: toNano(2),
  });

  migration.store(venomTip3, "VenomToTip3");
  console.log(`'Venom to Tip3': ${venomTip3.address}`);

  /* 
    Deploy the VenomWvenomToTip3 contract.
  */
  const { contract: VenomWvenomToTip3 } = await locklift.factory.deployContract({
    contract: "VenomWvenomToTip3",
    publicKey: signer?.publicKey ?? "",
    initParams: {
      randomNonce_: getRandomNonce(),
      weverRoot: root.address,
      weverVault: vault.address,
      everToTip3: venomTip3.address,
    },
    constructorParams: {},
    value: toNano(2),
  });

  migration.store(VenomWvenomToTip3, "VenomWvenomToTip3");
  console.log(`${"VenomWvenomToTip3"}: ${VenomWvenomToTip3.address}`);

  console.log(`Giver balance: ${toNano(await locklift.provider.getBalance(giverAddress))}`);

  console.log("=".repeat(64));
  for (const alias in migration.migration_log) {
    console.log(`${alias}: ${migration.migration_log[alias].address}`);
  }
  console.log("=".repeat(64));
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
