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
    Deploy the Tip3ToVenom contract.
  */
  const { contract: Tip3ToVenom } = await locklift.factory.deployContract({
    contract: "Tip3ToVenom",
    publicKey: signer?.publicKey ?? "",
    initParams: {
      randomNonce_: getRandomNonce(),
      weverRoot: migration.getAddress("WVENOMRoot"),
      weverVault: migration.getAddress("WVENOMVault"),
    },
    constructorParams: {},
    value: toNano(2),
  });

  migration.store(Tip3ToVenom, "Tip3ToVenom");
  console.log(`${"Tip3ToVenom"}: ${Tip3ToVenom.address}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
