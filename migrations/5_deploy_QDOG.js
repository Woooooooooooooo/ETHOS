const QDOG = artifacts.require("QDOG");


module.exports = async function(deployer, network, accounts) {
    const to = "0xDb6FD5953e8aA9F7719C09C60355CdE577C55BDc";
    await deployer.deploy(QDOG, to, "QDOG", "QDOG", 100000000000);
   
    

}