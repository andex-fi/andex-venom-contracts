/* eslint-disable @typescript-eslint/ban-ts-comment */
import { toNano, WalletTypes, getRandomNonce, Address, zeroAddress } from "locklift";
import { Migration, displayTx } from "./utils";
import { Command } from "commander";

const program = new Command();

program
  .allowUnknownOption()
  .option("-rcn, --root_contract_name <root_contract_name>", "Root contract name")
  .option("-prcn, --pair_contract_name <pair_contract_name>", "Pair contract name")
  .option("-acn, --account_contract_name <account_contract_name>", "Account contract name")
  .option("-vcn, --vault_contract_name <vault_contract_name>", "Vault contract name")
  .option("-plcn, --pool_contract_name <pool_contract_name>", "Pool contract name");

program.parse(process.argv);

const options = program.opts();
options.root_contract_name = options.root_contract_name || "Root";
options.pair_contract_name = options.pair_contract_name || "Pair";
options.pool_contract_name = options.pool_contract_name || "StablePool";
options.account_contract_name = options.account_contract_name || "Account";
options.vault_contract_name = options.vault_contract_name || "Vault";

const newOwner = new Address(options.owner);

async function main() {
  const migration = new Migration();

  const tokenFactory = migration.getAddress("TokenFactory");

  const signer = await locklift.keystore.getSigner("0");
  const account = await locklift.factory.accounts.addExistingAccount({
    type: WalletTypes.EverWallet,
    address: migration.getAddress("Account1"),
  });

  if (locklift.tracing) {
    locklift.tracing.setAllowedCodesForAddress(account.address, { compute: [100] });
  }

  // const TokenFactory = await locklift.factory.getContractArtifacts("TokenFactory");
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
    publicKey: signer?.publicKey ?? "",
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
      _newTokenFactory: tokenFactory,
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
    publicKey: signer?.publicKey ?? "",
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

    const factoryContract = await locklift.factory.getDeployedContract("TokenFactory", tokenFactory);

    tx = await factoryContract.methods
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

  migration.store(dexRoot, "DexRoot");
  migration.store(dexVault, "DexVault");
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
