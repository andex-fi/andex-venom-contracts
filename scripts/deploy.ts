/* eslint-disable @typescript-eslint/no-non-null-assertion */
// eslint-disable-next-line @typescript-eslint/no-var-requires
import { Migration, displayTx } from "./utils";
import { Command } from "commander";
import { toNano, WalletTypes, getRandomNonce, zeroAddress, Address } from "locklift";

async function main() {
  const program = new Command();
  const migration = new Migration();

  migration.reset();

  program.allowUnknownOption().option("-o, --owner <owner>", "owner");

  program.parse(process.argv);

  const options = program.opts();

  const newOwner = new Address(options.owner);

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
