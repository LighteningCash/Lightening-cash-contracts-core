/* global artifacts */
require('dotenv').config({ path: '../.env' })
const ERC20Lightening = artifacts.require('ERC20Lightening')
const Verifier = artifacts.require('Verifier')
const hasherContract = artifacts.require('Hasher')
const ERC20Mock = artifacts.require('ERC20Mock')
const Treasury = artifacts.require('Treasury')

module.exports = function (deployer, network, accounts) {
  return deployer.then(async () => {
    const { MERKLE_TREE_HEIGHT, ERC20_TOKEN, TOKEN_AMOUNT } = process.env
    const verifier = await Verifier.deployed()
    const treasury = await Treasury.deployed()
    const hasherInstance = await hasherContract.deployed()
    await ERC20Lightening.link(hasherContract, hasherInstance.address)
    let token = ERC20_TOKEN
    if (token === '') {
      const tokenInstance = await deployer.deploy(ERC20Mock)
      token = tokenInstance.address
    }
    const lightening = await deployer.deploy(
      ERC20Lightening,
      verifier.address,
      TOKEN_AMOUNT,
      MERKLE_TREE_HEIGHT,
      accounts[0],
      token,
      treasury.address
    )
    console.log('ERC20Lightening\'s address ', lightening.address)
  })
}
