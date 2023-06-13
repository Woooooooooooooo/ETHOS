const EthosNFT = artifacts.require("EthosNFT");
const TestToken = artifacts.require("TestToken");
const EthosNFTStroe = artifacts.require("EthosNFTStroe");
const EthosNFTStroe1 = artifacts.require("EthosNFTStroe");

//第一期
module.exports = async function(deployer, network, accounts) {

    const envi = "bsc"; // sep, bsc, bsctest, eth

    let input = "0xa17b9BBFA57bf198cA0278e0FC85A459780a4CC9"; //wooooo
    if (envi == "bsc") {
        input = "0x6CCC8db8E3Fd5FFDd2E7B92Bd92e8e27baF704a8";
    }
    const baseURI = "https://3thos.club/20230608095102.gif?tokenId=";
    await deployer.deploy(EthosNFT, "EthosNFT", "EthosNFT", baseURI);
    const nft = await EthosNFT.deployed();

    let startTime =  1686218400;
    let endTime = 1686650400;
    let max = 2000;
    let limit = 5;
    let price = web3.utils.toWei("2000", "ether");
    let lockTime = 30 * 24 * 60 * 60;
    let isLock = true;
    let phase = [startTime, endTime, max, limit, price, lockTime, isLock];
    const nftAddress = nft.address;
    const receiver = accounts[0];
    await deployer.deploy(EthosNFTStroe, input, nftAddress, receiver, phase);
    const ethosNFTStroe = await EthosNFTStroe.deployed();
    await nft.grantRole(await nft.MINTER_ROLE(), ethosNFTStroe.address);

    if (envi == "bsc") {
        input = "0x55d398326f99059fF775485246999027B3197955";
    }
    startTime = 1686736800;
    endTime = 1688119200;
    max = 10000;
    limit = 10000;
    price = web3.utils.toWei("100", "ether");;
    lockTime = 0;
    isLock = false;
    phase = [startTime, endTime, max, limit, price, lockTime, isLock];
    await deployer.deploy(EthosNFTStroe1, input, nftAddress, receiver, phase);
    const ethosNFTStroe1 = await EthosNFTStroe1.deployed();
    await nft.grantRole(await nft.MINTER_ROLE(), ethosNFTStroe1.address);

    // const token = await TestToken.at(input);
    // await token.approve(nft.address, web3.utils.toWei("4000", "ether"));

    await ethosNFTStroe.transferOwnership("0x3026108a822871FB6D08dC45C5e2854b51b79B25");
    await ethosNFTStroe1.transferOwnership("0x3026108a822871FB6D08dC45C5e2854b51b79B25");
    
}

