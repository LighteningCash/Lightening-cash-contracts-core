/* global artifacts */
require('dotenv').config({ path: '../.env' })
const Proxy = artifacts.require('Proxy')
const Trees = artifacts.require('LighteningTrees')
const ETHLightening = artifacts.require('ETHLightening')

module.exports = function (deployer, network, accounts) {
  return deployer.then(async () => {
    // const proxy = await Proxy.at("0x40aF54bBE9222Bab0CFA1F24306DB1B63dF8D113")
    // //const lightening = await ETHLightening.deployed();
    // const trees = await Trees.at("0x870c4d5970d20a761c7af9f717072b6562cec24f")
    // await proxy.initialize(trees.address, accounts[0], [])
    // await proxy.updateInstance("0xd50CbA7A852c80E032582636d927502E96b82b48", true)
    // console.log('trees\'s address ', trees.address)

    const proxy = await Proxy.deployed()
    const lightening = await ETHLightening.deployed();
    const trees = await deployer.deploy(Trees, proxy.address)
    await proxy.initialize(trees.address, accounts[0], [])
    await proxy.updateInstance(lightening.address, true)
    console.log('trees\'s address ', trees.address)
  })
}
