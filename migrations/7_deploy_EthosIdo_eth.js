const EthosIdo = artifacts.require("EthosIdo");
const TestToken = artifacts.require("TestToken");

//第一期
module.exports = async function(deployer, network, accounts) {
    
    const envi = "bsc"; // sep, bsc, bsctest

    let input = "0x55d398326f99059fF775485246999027B3197955";
    let output = "0x6CCC8db8E3Fd5FFDd2E7B92Bd92e8e27baF704a8";
    let receiver = "0x528028c464E2a960FBd9eEBaCae3530f6c28E862";
    if (envi == "sep") {
        input = "0xa17b9bbfa57bf198ca0278e0fc85a459780a4cc9";
        output = "0xc705880069424c20c90c0547a44ce92d9bb8ff4b";
        receiver = "0xb9e66643E4f58061A1eF35BF2E20D41a94766039";
    } else if (envi == "bsc") {
        input = "0x55d398326f99059fF775485246999027B3197955";
        output = "0x6CCC8db8E3Fd5FFDd2E7B92Bd92e8e27baF704a8";
        receiver = "0x528028c464E2a960FBd9eEBaCae3530f6c28E862";
    } else if (envi == "bsctest") {
        input = "0x6CCC8db8E3Fd5FFDd2E7B92Bd92e8e27baF704a8";
        output = "0xC1A4717FB474F483fABF4494302B1D1Da223e76F";
        receiver = "0xb9e66643E4f58061A1eF35BF2E20D41a94766039";
    } else if (envi == "eth") {
        input = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
        output = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
        receiver = "0x528028c464E2a960FBd9eEBaCae3530f6c28E862";
    } 
    
    const targetAmount = web3.utils.toWei("2000000", "ether");
    const totalAmount = 0;
    const min = web3.utils.toWei("1", "ether");
    const max = web3.utils.toWei("2000000", "ether");
    const price = 45;
    const decimalPlace = 1000;
    let startTime =  1685008800;//Math.trunc(Date.now() / 1000);
    const endTime = 1686304800;//startTime + (60 * 60 * 24);
    if (envi == "sep") {
        startTime =  Math.trunc(Date.now() / 1000);
    } else if (envi == "bsctest") {
        startTime =  Math.trunc(Date.now() / 1000);
    } else if (envi == "bsc") {
        startTime = 1685008800;
    } else if (envi == "eth") {
        startTime = 1685008800;
    } 

    const info = [targetAmount, totalAmount, min, max, price, decimalPlace, startTime, endTime, input, output];
    await deployer.deploy(EthosIdo, info, receiver);
    const ido = await EthosIdo.deployed();
    let bitbull = "0x84c6c4d66a56f2F25b6ae2f284e167134eEdEe4F";
    if (envi == "sep") {
        bitbull = "0x84c6c4d66a56f2F25b6ae2f284e167134eEdEe4F";
    } else if (envi == "bsc") {
        bitbull = "0x1d7cFb616eEb8A65952172c12573c702c4bDA4D9";
    } else if (envi == "bsctest") {
        bitbull = "0x1d7cFb616eEb8A65952172c12573c702c4bDA4D9";
    } else if (envi == "eth") {
        bitbull = "0xE835107A576DafB59597993dD774bb1879831F79";
    } 
    await ido.editBitbull(bitbull);
    
    let arr = new Array();
    arr.push([1686499200, 1000])
    for (let i = 0; i < 18; i++) {
        arr.push([1686499200 + ((i + 1) * 60 * 60 * 24 * 30), 500]);
    }
    await ido.setThawInfo(arr);
    // await ido.transferOwnership(receiver);
}