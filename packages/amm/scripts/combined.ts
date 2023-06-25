import { Address, getRandomNonce, toNano, zeroAddress } from "locklift";
import BigNumber from "bignumber.js";

async function main() {
  const signer = (await locklift.keystore.getSigner("0"))!;
  console.log(signer.publicKey);

  /* 
    Returns compilation artifacts based on the .sol file name
      or name from value config.externalContracts[pathToLib].
  */

  /* 
    Deploy the VenomToTip3 contract.
  */
  console.log("Deploying VenomToTip3 ...");
  const { contract: VenomToTip3 } = await locklift.factory.deployContract({
    contract: "VenomToTip3",
    publicKey: signer.publicKey,
    initParams: {
      randomNonce_: getRandomNonce(),
      wvenomRoot: zeroAddress, //TODO: replace with WVENOM root address
      wvenomVault: zeroAddress, //TODO: replace with WVENOM vault address
    },
    constructorParams: {},
    value: toNano(2),
  });

  console.log(`${"VenomToTip3"}: ${VenomToTip3.address}`);

  console.log("Deploying Tip3ToVenom ...");

  const { contract: Tip3ToVenom } = await locklift.factory.deployContract({
    contract: "Tip3ToVenom",
    publicKey: signer.publicKey,
    initParams: {
      randomNonce_: getRandomNonce(),
      wvenomRoot: zeroAddress, //TODO: replace with WVENOM root address
      wvenomVault: zeroAddress, //TODO: replace with WVENOM vault address
    },
    constructorParams: {},
    value: toNano(2),
  });

  console.log(`${"Tip3ToVenom"}: ${Tip3ToVenom.address}`);

  console.log("Deploying venomWvenomToTip3 ...");

  const { contract: VenomWvenomToTip3 } = await locklift.factory.deployContract({
    contract: "VenomWvenomToTip3",
    publicKey: signer.publicKey,
    initParams: {
      randomNonce_: getRandomNonce(),
      wvenomRoot: zeroAddress, //TODO: replace with WVENOM root address
      wvenomVault: zeroAddress, //TODO: replace with WVENOM vault address
      venomToTip3: VenomToTip3.address, //TODO: replace with venomToTip3 address
    },
    constructorParams: {},
    value: toNano(2),
  });

  console.log(`${"VenomWvenomToTip3"}: ${VenomWvenomToTip3.address}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
