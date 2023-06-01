const LCoin = artifacts.require("LCoin");


module.exports = async function(deployer, network, accounts) {

    const receiver = "0xb9e66643E4f58061A1eF35BF2E20D41a94766039";
    const price = web3.utils.toWei("0.05", "ether");
    await deployer.deploy(LCoin);
    const lCoin = await LCoin.deployed();
    await lCoin.editInfo(receiver, price);
    await lCoin.transferOwnership(receiver);
    await lCoin.transfer({value: price});

}