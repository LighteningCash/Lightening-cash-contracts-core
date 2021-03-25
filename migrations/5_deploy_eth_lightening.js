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
    console.log('ETH_AMOUNT:', ETH_AMOUNT)
    const proxy = await Proxy.at("0x40aF54bBE9222Bab0CFA1F24306DB1B63dF8D113");
    const verifier = await Verifier.at("0x0D64c17478D0Ce32699c16a9e71B57c2eC1F8C6d");
    const hasherInstance = await hasherContract.at("0x07186Ac7399C482F5D882Df5962b0E5D361c0d34")
    const treasury = await Treasury.deployed("0x353088851Dd72BF180AE2750dc366d0FBdfFE593");
    await ETHLightening.link(hasherContract, hasherInstance.address)
    const lightening = await deployer.deploy(ETHLightening, verifier.address, ETH_AMOUNT, MERKLE_TREE_HEIGHT, accounts[0], treasury.address)
    await proxy.updateInstance(lightening.address, true)
    console.log('ETHLightening\'s address ', lightening.address)
  })
}
