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
  const { contract: VenomToTip3 } = await locklift.factory.deployContract({
    contract: "VenomToTip3",
    publicKey: signer.publicKey,
    initParams: {
      randomNonce_: getRandomNonce(),
      weverRoot: zeroAddress, //TODO: replace with WVENOM root address
      weverVault: zeroAddress, //TODO: replace with WVENOM vault address
    },
    constructorParams: {},
    value: toNano(2),
  });

  console.log(`${"VenomToTip3"}: ${VenomToTip3.address}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
