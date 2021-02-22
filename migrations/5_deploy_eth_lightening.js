/* global artifacts */
require('dotenv').config({ path: '../.env' })
const ETHLightening = artifacts.require('ETHLightening')
const Verifier = artifacts.require('Verifier')
const Treasury = artifacts.require('Treasury')
const hasherContract = artifacts.require('Hasher')


module.exports = function (deployer, network, accounts) {
  return deployer.then(async () => {
    const { MERKLE_TREE_HEIGHT, ETH_AMOUNT } = process.env
    const verifier = await Verifier.deployed()
    const treasury = await Treasury.deployed();
    const hasherInstance = await hasherContract.deployed()
    await ETHLightening.link(hasherContract, hasherInstance.address)
    const lightening = await deployer.deploy(ETHLightening, verifier.address, ETH_AMOUNT, MERKLE_TREE_HEIGHT, accounts[0], treasury.address)
    console.log('ETHLightening\'s address ', lightening.address)
  })
}
