/* global artifacts */
require('dotenv').config({ path: '../.env' })
const ETHLightening = artifacts.require('ETHLightening')
const Proxy = artifacts.require('Proxy')
const Verifier = artifacts.require('Verifier')
const Treasury = artifacts.require('Treasury')
const hasherContract = artifacts.require('Hasher')

module.exports = function (deployer, network, accounts) {
  return deployer.then(async () => {
    // const { MERKLE_TREE_HEIGHT, ETH_AMOUNT } = process.env
    // let deployedAddress = await ETHLightening.at("0x3486713470a20D3cAEABd463C087330439B96684");
    // let deployedProxy = await Proxy.at("0xE917313D253662F43E4D9dC39DD138b01000ac3D");
    // const verifier = (await deployedAddress.verifier()).valueOf().toString();
    // const treasury = (await deployedAddress.treasury()).valueOf().toString();
    // const lightening = await deployer.deploy(ETHLightening, verifier, ETH_AMOUNT, MERKLE_TREE_HEIGHT, accounts[0], treasury)
    // await deployedProxy.updateInstance(lightening.address, true)
    // console.log('ETHLightening\'s address ', treasury)

    const { MERKLE_TREE_HEIGHT, ETH_AMOUNT } = process.env
    const verifier = await Verifier.deployed();
    const treasury = await Treasury.deployed();
    const lightening = await deployer.deploy(ETHLightening, verifier.address, ETH_AMOUNT, MERKLE_TREE_HEIGHT, accounts[0], treasury.address)
    console.log('ETHLightening\'s address ', lightening.address)
  })
}
