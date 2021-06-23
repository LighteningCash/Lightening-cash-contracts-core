/* global artifacts */
require('dotenv').config({ path: '../.env' })
const ERC20Lightening = artifacts.require('ERC20Lightening')
const ETHLightening = artifacts.require('ETHLightening')
const Proxy = artifacts.require('Proxy')
const Verifier = artifacts.require('Verifier')
const hasherContract = artifacts.require('Hasher')
const ERC20Mock = artifacts.require('ERC20Mock')
const Treasury = artifacts.require('Treasury')
const config = require('./config')

module.exports = function (deployer, network, accounts) {
  return deployer.then(async () => {
    const network_id = deployer.network_id
    const { MERKLE_TREE_HEIGHT, ERC20_TOKEN, TOKEN_AMOUNT } = process.env
    let deployedAddress = await ETHLightening.at(config.anyMixer[network_id])
    let deployedProxy = await Proxy.at(config.proxy[network_id]);
    let hasher = await hasherContract.at(config.hasher[network_id]);
    const verifier = (await deployedAddress.verifier()).valueOf().toString();
    const treasury = (await deployedAddress.treasury()).valueOf().toString();
    let token = ERC20_TOKEN
    if (token === '') {
      const tokenInstance = await deployer.deploy(ERC20Mock)
      token = tokenInstance.address
    }
    
    await ERC20Lightening.link(hasherContract, hasher.address);
    const lightening = await deployer.deploy(
      ERC20Lightening,
      verifier,
      TOKEN_AMOUNT,
      MERKLE_TREE_HEIGHT,
      accounts[0],
      token,
      treasury
    )
    await deployedProxy.updateInstance(lightening.address, true)

    console.log('ERC20Lightening\'s address ', lightening.address)
  })
}
