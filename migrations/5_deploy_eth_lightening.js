/* global artifacts */
require('dotenv').config({ path: '../.env' })
const ETHLightening = artifacts.require('ETHLightening')
const Proxy = artifacts.require('Proxy')
const Verifier = artifacts.require('Verifier')
const Treasury = artifacts.require('Treasury')
const hasherContract = artifacts.require('Hasher')
const config = require('./config')

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

    // const { MERKLE_TREE_HEIGHT, ETH_AMOUNT } = process.env
    // console.log('ETH_AMOUNT:', ETH_AMOUNT)
    // const proxy = await Proxy.at("0xd72d7D3D96510d54815414dB39694B59a1748a19");
    // const verifier = await Verifier.at("0xbC8a6030152baF11f62c11Ed28b3d5A13DC5DeD9");
    // const hasherInstance = await hasherContract.at("0x8638EbB0EDbF49239fbdb73C20B2F5abf5F9f9e2")
    // const treasury = await Treasury.deployed("0x51dfeBE8790AEDE8DFB8bab781E45378cB884b56");
    // await ETHLightening.link(hasherContract, hasherInstance.address)
    // const lightening = await deployer.deploy(ETHLightening, verifier.address, ETH_AMOUNT, MERKLE_TREE_HEIGHT, accounts[0], treasury.address)
    // await proxy.updateInstance(lightening.address, true)
    // console.log('ETHLightening\'s address ', lightening.address)

    const network_id = deployer.network_id
    const { MERKLE_TREE_HEIGHT, ETH_AMOUNT } = process.env
    console.log('ETH_AMOUNT:', ETH_AMOUNT)
    const proxy = await Proxy.at(config.proxy[network_id])
    const hasherInstance = await hasherContract.at(config.hasher[network_id])
    const deployedAddress = await ETHLightening.at(config.anyMixer[network_id])

    const verifier = (await deployedAddress.verifier()).valueOf().toString();
    const treasury = (await deployedAddress.treasury()).valueOf().toString();

    await ETHLightening.link(hasherContract, hasherInstance.address)
    const lightening = await deployer.deploy(ETHLightening, verifier.address, ETH_AMOUNT, MERKLE_TREE_HEIGHT, accounts[0], treasury.address)
    await proxy.updateInstance(lightening.address, true)
    console.log('ETHLightening\'s address ', lightening.address)

    // const { MERKLE_TREE_HEIGHT, ETH_AMOUNT } = process.env
    // const verifier = await Verifier.deployed()
    // const treasury = await Treasury.deployed()
    // const hasherInstance = await hasherContract.deployed()
    // await ETHLightening.link(hasherContract, hasherInstance.address)
    // const lightening = await deployer.deploy(ETHLightening, verifier.address, ETH_AMOUNT, MERKLE_TREE_HEIGHT, accounts[0], treasury.address)
    // console.log('ETHLightening\'s address ', lightening.address)
  })
}
