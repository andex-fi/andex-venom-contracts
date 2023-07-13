import prompts from 'prompts'
import { getRandomNonce, toNano } from 'locklift';
import { Migration, displayTx } from './utils';

const isValidVenomAddress = (address: string) => /^(?:-1|0):[0-9a-fA-F]{64}$/.test(address);

async function main() {
    const migration = new Migration();

    const response = await prompts([
      {
        type: 'text',
        name: 'owner',
        message: 'FaucetFactory owner (can upgrade faucet data codes)',
        validate: value => isValidVenomAddress(value) ? true : 'Invalid address'
      }
    ]);

    console.log(`Deploying Faucet with owner: ${response.owner}`);
    console.log('Deploying versions: FaucetFactory - v1, Faucet - v1');

    const Faucet = await locklift.factory.getContractArtifacts('Faucet');

    const Platform = await locklift.factory.getContractArtifacts('FaucetPlatform');

    const signer = await locklift.keystore.getSigner("0");

    console.log(`Deploying FaucetFactory...`);
    const { contract: faucetFactory, tx: faucetFactoryTx} = await locklift.factory.deployContract({
      contract: "FaucetFactory",
      constructorParams: { _owner: response.owner },
      initParams: {
        FaucetCode: Faucet.code,
        nonce: getRandomNonce()
      },
      publicKey: signer?.publicKey ?? "",
      value: toNano(2)
    })

    migration.store(faucetFactory, "FaucetFactory");
    displayTx(faucetFactoryTx.transaction);

    console.log(`FaucetFactory address: ${faucetFactory.address}`);

}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  })