const EthosIdo = artifacts.require("EthosIdo");
const TestToken = artifacts.require("TestToken");

contract('EthosIdo', async (accounts)=> {
    let token;
    let ido;

    before('some description', async () => {
        ido = await EthosIdo.deployed();
        token = await TestToken.deployed();
        await token.transfer(accounts[1] ,web3.utils.toWei("100", "ether"));
        await token.approve(ido.address ,web3.utils.toWei("100", "ether"), {from: accounts[1]});
        await token.transfer(accounts[2] ,web3.utils.toWei("100", "ether"));
        await token.approve(ido.address ,web3.utils.toWei("100", "ether"), {from: accounts[2]});
        await token.transfer(accounts[3] ,web3.utils.toWei("100", "ether"));
        await token.approve(ido.address ,web3.utils.toWei("100", "ether"), {from: accounts[3]});
    });

    beforeEach('转账,为了出块', async () =>{
        await web3.eth.sendTransaction({from:accounts[0], to:accounts[8], value: web3.utils.toWei("1", "gwei")});
        console.info("出块时间：" + Math.trunc(Date.now() / 1000));
    })


    it ('投资', async () => {
        await ido.invest(web3.utils.toWei("10", "ether"), {from : accounts[1]});
        await ido.invest(web3.utils.toWei("20", "ether"), {from : accounts[2]});
    })

    it ('等待结束', async () => {
        await new Promise(resolve => {
            setTimeout(() => resolve(web3.eth.sendTransaction({from:accounts[2], to:accounts[8], value: web3.utils.toWei("1", "gwei")})), 10000);
        });
    })

    it ('预计收益', async () => {
        let total = await ido.expected(web3.utils.toWei("10", "ether"), {from : accounts[1]});
        // await ido.invest(web3.utils.toWei("20", "ether"), {from : accounts[2]});
    })

});