/* global artifacts */
require('dotenv').config({ path: '../.env' })
const Proxy = artifacts.require('Proxy')

module.exports = function (deployer) {
  return deployer.then(async () => {
    const proxy = await deployer.deploy(Proxy)
    console.log('proxy\'s address ', proxy.address)
  })
}
