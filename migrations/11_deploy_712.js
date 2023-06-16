const T712 = artifacts.require("T712");

//第一期
module.exports = async function(deployer, network, accounts) {

    await deployer.deploy(T712);
   
}

