const LPStaking = artifacts.require("LPStaking");



module.exports = async function(deployer, network, accounts) {
     //goerli
    let token = '0x6ccc8db8e3fd5ffdd2e7b92bd92e8e27baf704a8';
    let pair = '0x52bF4f6741aedE57ADD10470B49992AA1Bbb5fEB';
    
    await deployer.deploy(LPStaking, pair, token);
    const stake = await LPStaking.deployed();
    await stake.transferOwnership('0x3026108a822871FB6D08dC45C5e2854b51b79B25');

}