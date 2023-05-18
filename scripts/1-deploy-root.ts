import { Address } from "locklift";

async function main() {
  const owner = new Address ("0:52a5e239cc2575ca0a4ee8aa947351cb439d7508728506c04e2ad24e0d025e15");
  const signer = (await locklift.keystore.getSigner("0"))!;
  const { contract: swapRoot, tx } = await locklift.factory.deployContract({
    contract: "SwapRoot",
    publicKey: signer.publicKey,
    initParams: {
      _nonce: locklift.utils.getRandomNonce(),
    },
    constructorParams: {
      initial_owner: owner,
    },
    value: locklift.utils.toNano(1),
  });

  console.log(`Sample deployed at: ${swapRoot.address.toString()}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
