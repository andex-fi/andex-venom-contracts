/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable @typescript-eslint/ban-ts-comment */
/* eslint-disable @typescript-eslint/no-var-requires */
import { Address } from "locklift";
async function main() {
  const { Command } = require("commander");
  const logger = require("mocha-logger");
  const program = new Command();
  // const prompts = require("prompts");
  const { getRandomNonce, toNano } = require("locklift");

  // const isValidTonAddress = (address: any) => /^(?:-1|0):[0-9a-fA-F]{64}$/.test(address);

  // const promptsData = [];

  program
    .allowUnknownOption()
    .option("-evroot", "--wvenomroot <wvenomRoot>", "WVENOM Root")
    .option("-ewvault", "--wvenomvault <wvenomVault>", "WVENOM Vault");

  program.parse(process.argv);

  // const options = program.opts();

  /*if (!isValidTonAddress(options.weverroot)) {
    promptsData.push({
      type: "text",
      name: "wvenomRoot",
      message: "WVENOM Root",
      validate: (value: any) => (isValidTonAddress(value) ? true : "Invalid Venom address"),
    });
  }

  if (!isValidTonAddress(options.wvenomvault)) {
    promptsData.push({
      type: "text",
      name: "wvenomVault",
      message: "WVENOM Vault",
      validate: (value: any) => (isValidTonAddress(value) ? true : "Invalid Venom address"),
    });
  }*/

  // const response = await prompts(promptsData);
  // const weverRoot_ = options.weverroot || response.weverRoot;
  // const weverVault_ = options.wevervault || response.weverVault;

  const signer = await locklift.keystore.getSigner("0");

  const { contract: venomTip3 } = await locklift.factory.deployContract({
    contract: "VenomToTip3",
    // @ts-ignore
    constructorParams: {},
    // @ts-ignore
    initParams: {
      randomNonce_: getRandomNonce(),
      weverRoot: new Address("0:2e98a5663d0701d7eb8830b6a7cb7e3d96fd71899af6afd42ecd5f882bab0333"),
      weverVault: new Address("0:6b9b97e31cc1ce5ec78a785eaa86fc032d29fc1ce42db0ed0a693137b0139296"),
    },
    publicKey: signer!.publicKey,
    value: toNano(2),
  });

  logger.log(`'Venom to Tip3': ${venomTip3.address}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
