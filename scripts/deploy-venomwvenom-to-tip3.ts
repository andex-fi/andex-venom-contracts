import { getRandomNonce, toNano } from "locklift";
import { Migration } from "./utils";

async function main() {
  const signer = await locklift.keystore.getSigner("0");

  const migration = new Migration();

  /* 
    Returns compilation artifacts based on the .sol file name
      or name from value config.externalContracts[pathToLib].
  */

  /* 
    Deploy the VenomWvenomToTip3 contract.
  */
  const { contract: VenomWvenomToTip3 } = await locklift.factory.deployContract({
    contract: "VenomWvenomToTip3",
    publicKey: signer?.publicKey ?? "",
    initParams: {
      randomNonce_: getRandomNonce(),
      weverRoot: migration.getAddress("WVENOMRoot"),
      weverVault: migration.getAddress("WVENOMVault"),
      everToTip3: migration.getAddress("VenomToTip3"),
    },
    constructorParams: {},
    value: toNano(2),
  });

  migration.store(VenomWvenomToTip3, "VenomWvenomToTip3");
  console.log(`${"VenomWvenomToTip3"}: ${VenomWvenomToTip3.address}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
