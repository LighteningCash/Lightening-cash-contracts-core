/* global artifacts */
require('dotenv').config({ path: '../.env' })
const ETHLighteningV2 = artifacts.require('ETHLighteningV2')
const ProxyV2 = artifacts.require('ProxyV2')
const Trees = artifacts.require('LighteningTrees')

module.exports = function (deployer, network, accounts) {
  return deployer.then(async () => {
    const proxyV2 = await deployer.deploy(ProxyV2)
    console.log('proxy\'s address ', proxyV2.address)

    const trees = await deployer.deploy(Trees, proxyV2.address);
    console.log('trees\'s address ', trees.address)

    const lightening = await ETHLighteningV2.deployed("0xc5C276Bc1E72426141d94Dc0B2F838c9eb403370");
    await proxyV2.initialize(trees.address, accounts[0], [])
    await proxyV2.updateInstance(lightening.address, true)
    console.log('trees\'s address ', trees.address)
  })
}
