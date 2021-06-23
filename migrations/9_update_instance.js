/* global artifacts */
require('dotenv').config({ path: '../.env' })
const Proxy = artifacts.require('Proxy')
const config = require('./config')
const instanceAddress = '0xc8BED1c0c7CE241384502AC78650e85f06459102'
module.exports = function (deployer) {
  return deployer.then(async () => {
    const proxy = await Proxy.at(config.proxy[deployer.network_id])
    console.log('proxy\'s address ', proxy.address)
	await proxy.updateInstance(instanceAddress, true)
  })
}
