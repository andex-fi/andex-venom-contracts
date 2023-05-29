/* eslint-disable @typescript-eslint/ban-ts-comment */
import { getRandomNonce, toNano } from "locklift";
import { Migration } from "./utils";

async function main() {
  const signer = await locklift.keystore.getSigner("0");

  const migration = new Migration();

  const { contract: venomTip3 } = await locklift.factory.deployContract({
    contract: "VenomToTip3",
    // @ts-ignore
    constructorParams: {},
    // @ts-ignore
    initParams: {
      randomNonce_: getRandomNonce(),
      weverRoot: migration.getAddress("WVENOMRoot"),
      weverVault: migration.getAddress("WVENOMVault"),
    },
    publicKey: signer?.publicKey ?? "",
    value: toNano(2),
  });

  migration.store(venomTip3, "VenomToTip3");
  console.log(`'Venom to Tip3': ${venomTip3.address}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
