const EthosIdo = artifacts.require("EthosIdoBSC");
const TestToken = artifacts.require("TestToken");

//第一期
module.exports = async function(deployer, network, accounts) {

    const envi = "bsc2"; // bsc1

    let address = "0xa1D4f2A3547E0Fd42A58D68BC7dC2eB1cCe54E8d";
    let startTime = "1684749600";
    let min = web3.utils.toWei("500", "ether");
    if (envi == "bsc1") {
        address = "0xa1D4f2A3547E0Fd42A58D68BC7dC2eB1cCe54E8d";
        startTime = "1684749600";
    } else if (envi == "eth1") {
        min = web3.utils.toWei("500", "mwei");
        address = "0x4462477d93f800B536fd086F56574Fd8161d1819";
        startTime = "1684749600";
    } else if (envi == "bsc2") {
        address = "0x30f05e8a75cf20dd7d29a28f6a0412b85d667205";
        startTime = "1685008800";
    } else if (envi == "eth2") {
        min = web3.utils.toWei("500", "mwei");
        address = "0x7792d26eC871345957aaFD11203ABd907dA5dc52";
        startTime = "1685008800";
    } else if (envi == "bsc3") {
        address = "0xcDa18858ee35E332b718dCFD76C7eADc9a280857";
        startTime = "1684749600";
    } else if (envi == "bsc4") {
        address = "0xCD6072125AeBDc91d670e5890e8a66db703A4d27";
        startTime = "1685008800";
    } 
    
    // startTime = "1684576800";
    // min = web3.utils.toWei("0.1", "ether");
    const ido = await EthosIdo.at(address);
    // console.info(await ido.owner());
    // await ido.setStartTimeAndPrice(startTime, min);
    
    await ido.transferOwnership('0x3026108a822871FB6D08dC45C5e2854b51b79B25');
    // const i =  await ido.exportInvestLog(0,17);
    // console.log(i)
    
}

