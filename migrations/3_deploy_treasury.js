/* global artifacts */
const Treasury = artifacts.require('Treasury')

module.exports = function (deployer, netowrk, accounts) {
    return deployer.then(async () => {
        await deployer.deploy(Treasury)
        let treasury = await Treasury.deployed()
        await treasury.initialize(accounts[0])
    })
}
