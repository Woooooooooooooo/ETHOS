const LCoin = artifacts.require("LCoin");


module.exports = async function(deployer, network, accounts) {

    const receiver = "0xb9e66643E4f58061A1eF35BF2E20D41a94766039";
    await deployer.deploy(LCoin);
    const lCoin = await LCoin.deployed();
    await lCoin.transferOwnership(receiver);

}