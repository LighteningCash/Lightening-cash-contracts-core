/* global artifacts */
const Treasury = artifacts.require('Treasury')

module.exports = function (deployer) {
    deployer.deploy(Treasury)
}
