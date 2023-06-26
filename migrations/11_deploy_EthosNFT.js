const EthosNFTDisplace = artifacts.require("EthosNFTDisplace");
const EthosNFT2 = artifacts.require("ETHOSMiner");


//第一期
module.exports = async function(deployer, network, accounts) {



    // const name_1 = "test1";
    // const symbol_1 = "test1";
    // const baseURI_1 = "http://dejdade.com/";
    // await deployer.deploy(EthosNFT2, name_1, symbol_1, baseURI_1);
    // const nft1 = await EthosNFT2.deployed(); 
    // await nft1.grantRole(await nft1.MINTER_ROLE(), '0x3026108a822871FB6D08dC45C5e2854b51b79B25');


    const name_ = "ETHOS Miner";
    const symbol_ = "ETHOS Miner";
    const baseURI_ = "https://images.3thos.club/";
    await deployer.deploy(EthosNFT2, name_, symbol_, baseURI_);
    const nft = await EthosNFT2.deployed(); 

    
    const input = '0xCc420909205157bDcCEc32cd72c7cC2bf10Cfa5e';
    const output = nft.address;
    await deployer.deploy(EthosNFTDisplace, input, output);
    const displace = await EthosNFTDisplace.deployed(); 
    
    await nft.grantRole(await nft.MINTER_ROLE(), displace.address);




   



}