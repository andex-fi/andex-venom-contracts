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
        message: 'MasterChef owner (can upgrade pool/user data codes)',
        validate: value => isValidVenomAddress(value) ? true : 'Invalid address'
      }
    ]);

    console.log(`Deploying Farm Pool with owner: ${response.owner}`);
    console.log('Deploying versions: MasterCHef - v1, Pool - v1, user data - v1');

    // const MasterChef = await locklift.factory.getContractArtifacts('MasterChef');
    const FarmPool = await locklift.factory.getContractArtifacts('FarmPool');
    const UserData = await locklift.factory.getContractArtifacts('UserData');

    const Platform = await locklift.factory.getContractArtifacts('FarmPlatform');

    const signer = await locklift.keystore.getSigner("0");

    console.log(`Deploying MasterChef...`);
    const { contract: masterChef, tx: masterChefTx} = await locklift.factory.deployContract({
      contract: "MasterChef",
      constructorParams: { _owner: response.owner },
      initParams: {
        FarmPoolCode: FarmPool.code,
        FarmPoolUserDataCode: UserData.code,
        PlatformCode: Platform.code,
        nonce: getRandomNonce()
      },
      publicKey: signer?.publicKey ?? "",
      value: toNano(2)
    })

    migration.store(masterChef, "MasterChef");
    displayTx(masterChefTx.transaction);

    console.log(`MasterChef address: ${masterChef.address}`);

}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  })