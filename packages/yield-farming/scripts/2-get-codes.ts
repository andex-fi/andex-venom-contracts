
async function main1() {
    const MasterChef = await locklift.factory.getContractArtifacts('MasterChef');

    const FarmPool = await locklift.factory.getContractArtifacts('FarmPool');

    const UserData = await locklift.factory.getContractArtifacts('UserData');

    console.log('MasterChef code:\n', MasterChef.code, '\n\n');
    console.log('FarmPool code:\n', FarmPool.code, '\n\n');
    console.log('UserData code:\n', UserData.code, '\n\n');
}

main1()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e);
        process.exit(1);
    });