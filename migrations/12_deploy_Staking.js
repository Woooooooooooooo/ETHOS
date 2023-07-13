const Staking = artifacts.require("Staking");
const EthosNFT2 = artifacts.require("ETHOSMiner");
const EthosNFTDisplace = artifacts.require("EthosNFTDisplace");


//第一期
module.exports = async function(deployer, network, accounts) {


    // const baseURI = "https://3thos.club/20230608095102.gif?tokenId=";
    // await deployer.deploy(EthosNFT, "EthosNFT", "EthosNFT", baseURI);
    // const nft = await EthosNFT.deployed();
    // await nft.grantRole(await nft.MINTER_ROLE(), '0x3026108a822871FB6D08dC45C5e2854b51b79B25');
    // await nft.grantRole(await nft.MINTER_ROLE(), '0xF84900e6Da0676a8CB3725D66c67E6f2d433FE76');


    // const input = '0xCc420909205157bDcCEc32cd72c7cC2bf10Cfa5e';
    // const output = '0x2d2b15a953eeAab28Ede9B7f9eaaA2dc427897aF';
    // await deployer.deploy(EthosNFTDisplace, input, output);
    // const displace = await EthosNFTDisplace.deployed(); 
    
    // await nft.grantRole(await nft.MINTER_ROLE(), displace.address);

    // // const name_ = "ETHOS Miner";
    // // const symbol_ = "ETHOS Miner";
    // // const baseURI_ = "https://images.3thos.club/";
    // // await deployer.deploy(EthosNFT2, name_, symbol_, baseURI_);
    // // const nft = await EthosNFT2.deployed(); 
    // // await nft.grantRole(await nft.MINTER_ROLE(), '0x3026108a822871FB6D08dC45C5e2854b51b79B25');
    // // await nft.grantRole(await nft.MINTER_ROLE(), '0xF84900e6Da0676a8CB3725D66c67E6f2d433FE76');


    const erc20 = "0x76acab7dc5c6834234305c552ffbfcfcffa72f0b"; //wooooo
    const erc721 = "0x2d2b15a953eeAab28Ede9B7f9eaaA2dc427897aF";//nft.address;
    await deployer.deploy(Staking, erc20, erc721);
    const stake = await Staking.deployed();

    let arr = new Array();
    arr.push([1, web3.utils.toWei("11.11", "ether")]);
    arr.push([2, web3.utils.toWei("11.11", "ether")]);
    arr.push([3, web3.utils.toWei("11.11", "ether")]);
    arr.push([4, web3.utils.toWei("11.11", "ether")]);
    arr.push([5, web3.utils.toWei("11.11", "ether")]);
    arr.push([6, web3.utils.toWei("13.33", "ether")]);
    arr.push([7, web3.utils.toWei("13.33", "ether")]);
    arr.push([8, web3.utils.toWei("13.33", "ether")]);
    arr.push([9, web3.utils.toWei("13.33", "ether")]);
    arr.push([10, web3.utils.toWei("13.33", "ether")]);
    await stake.setProductionDay(arr);


}