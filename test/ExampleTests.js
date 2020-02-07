const HEXMock = artifacts.require("HEXMock");
const Example = artifacts.require("Example");
const BN = require('bn.js');
const {advanceTimeAndBlock, oneDaySeconds} = require('../utils/helpers');
const {tryCatch, errTypes} = require('../utils/exceptions');
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const seconds = n => Math.floor(Date.now()/1000) + (n !== undefined ? n : 0);
const Web3 = require('web3');

contract('Example', (accounts) => {
    let hexMock;

    beforeEach(() => {
        const now = seconds() - 15;
        mostRecentNow = now;
        return HEXMock.new(now)
            .then(instance => hexMock = instance);
    });

    it('should do something as an example', async () => {
        let subject = await Example.new(hexMock.address);
        let origBalance = await hexMock.balanceOf(subject.address);
        await hexMock.testMint(subject.address, new BN(100), {from: accounts[0]});
        let balance = await hexMock.balanceOf(subject.address);
        assert.isTrue(balance.eq(new BN(100)));
        assert.isTrue(origBalance.eq(new BN(0)));

        await subject.doExampleThing({from: accounts[0], value:new BN(100)});
        let bal = await subject.readState({from: accounts[0]});
        assert.isTrue(bal.eq(new BN(100)));
    });
});