/* global artifacts */
require('dotenv').config({ path: '../.env' })
const Proxy = artifacts.require('Proxy')
const Trees = artifacts.require('LighteningTrees')
const ETHLightening = artifacts.require('ETHLightening')

module.exports = function (deployer, network, accounts) {
  return deployer.then(async () => {
    const proxy = await Proxy.deployed()
    const lightening = await ETHLightening.deployed();
    const trees = await deployer.deploy(Trees, proxy.address)
    await proxy.initialize(trees.address, accounts[0], [])
    await proxy.updateInstance(lightening.address, true)
    console.log('trees\'s address ', trees.address)
  })
}
