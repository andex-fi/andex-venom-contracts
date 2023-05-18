import { getRandomNonce, zeroAddress } from "locklift";


async function main() {
  // const SwapRoot = await locklift.factory.getContractArtifacts("SwapRoot");
  // const keyPair = await locklift.keys.getKeyPairs();

  const signer = (await locklift.keystore.getSigner("0"))!
  
  const { contract: swapRoot } = await locklift.factory.deployContract({
    contract: "SwapRoot",
    publicKey: signer.publicKey,
    initParams: {
      deployer_: zeroAddress, // this field should be zero address if deploying with public key (see source code)
      randomNonce_: getRandomNonce(),
      // rootOwner_: rootOwner,
      // walletCode_: TokenWallet.code,
    }
    initParams: {
      _nonce: getRandomNonce(),
    },
    keyPair,
  });

}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
