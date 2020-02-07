advanceTimeAndBlock = async (time) => {
    await advanceTime(time);
    await advanceBlock();

    return Promise.resolve(web3.eth.getBlock('latest'));
}

advanceTime = (time) => {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [time],
            id: new Date().getTime()
        }, (err, result) => {
            if (err) { return reject(err); }
            return resolve(result);
        });
    });
}

advanceBlock = () => {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: "2.0",
            method: "evm_mine",
            id: new Date().getTime()
        }, (err, result) => {
            if (err) { return reject(err); }
            return resolve(result)
        });
    }).then(() => web3.eth.getBlock('latest'));
}

oneDaySeconds = 3600 * 24;

calcDailyFractionRemaining = (amount, day) => {        
    return day >= 350 ? 0 : Math.floor(amount * (351 - day - 1) / (351 - day));
}

module.exports = {
    advanceTime,
    advanceBlock,
    advanceTimeAndBlock,
    calcDailyFractionRemaining,
    oneDaySeconds
}