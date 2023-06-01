const EthosIdo = artifacts.require("EthosIdoBSC");
const TestToken = artifacts.require("TestToken");

//第二期
module.exports = async function(deployer, network, accounts) {

    // const ido1 = await EthosIdo.at("0x30F05E8A75CF20dd7d29A28F6A0412B85d667205");
    // console.log(await ido1.investment(accounts[0]));

    
    const envi = "bsc"; // sep, bsc, bsctest, eth

    let input = "0x55d398326f99059fF775485246999027B3197955";
    let output = "0x6CCC8db8E3Fd5FFDd2E7B92Bd92e8e27baF704a8";
    if (envi == "sep") {
        input = "0xa17b9bbfa57bf198ca0278e0fc85a459780a4cc9";
        output = "0xc705880069424c20c90c0547a44ce92d9bb8ff4b";
    } else if (envi == "bsc") {
        input = "0x55d398326f99059fF775485246999027B3197955";
        output = "0x6CCC8db8E3Fd5FFDd2E7B92Bd92e8e27baF704a8";
    } else if (envi == "bsctest") {
        input = "0x6CCC8db8E3Fd5FFDd2E7B92Bd92e8e27baF704a8";
        output = "0xC1A4717FB474F483fABF4494302B1D1Da223e76F";
    } else if (envi == "eth") {
        input = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
        output = "0xB8c77482e45F1F44dE1745F52C74426C631bDD52";
    } 
    
    let targetAmount = web3.utils.toWei("20000000000", "ether");
    let totalAmount = web3.utils.toWei("20000000000", "ether");
    let min = web3.utils.toWei("500", "ether");
    let max = web3.utils.toWei("2000000", "ether");
    if (envi == "eth") {
        targetAmount = web3.utils.toWei("20000000000", "mwei");
        totalAmount = web3.utils.toWei("20000000000", "mwei");
        min = web3.utils.toWei("0.1", "mwei");
        max = web3.utils.toWei("2000000", "mwei");
    }

    const price = 450;
    const decimalPlace = 10000;
    let startTime = 1685008800;// Math.trunc(Date.now() / 1000);;//Math.trunc(Date.now() / 1000);
    const endTime = 1686304800;//startTime + (60 * 60 * 24);

    const info = [targetAmount, totalAmount, min, max, price, decimalPlace, startTime, endTime, input, output];
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

    await deployer.deploy(EthosIdo, info, bitbull);
    const ido = await EthosIdo.deployed();
    // await ido.editBitbull(bitbull);
    
    let arr = new Array();
    arr.push([1685008800, 1000]);
    arr.push([1686650400, 500]);
    arr.push([1689242400, 500]);
    arr.push([1691920800, 500]);
    arr.push([1686499200, 500]);
    arr.push([1697191200, 500]);
    arr.push([1699869600, 500]);
    arr.push([1702461600, 500]);
    arr.push([1705140000, 500]);
    arr.push([1707818400, 500]);
    arr.push([1710324000, 500]);
    arr.push([1713002400, 500]);
    arr.push([1715594400, 500]);
    arr.push([1718272800, 500]);
    arr.push([1720864800, 500]);
    arr.push([1723543200, 500]);
    arr.push([1726221600, 500]);
    arr.push([1728813600, 500]);
    arr.push([1731492000, 500]);
    await ido.setThawInfo(arr);
    await ido.transferOwnership('0x3026108a822871FB6D08dC45C5e2854b51b79B25');

}