const { assert } = require("chai");
const { default: Web3 } = require("web3");
const BN = require('bignumber.js');

const Treasury = artifacts.require('Treasury');
const ERC20Mock = artifacts.require('ERC20Mock');
const IPancakeRouter = artifacts.require('IPancakeRouter');
const MockMasterChef = artifacts.require('MockMasterChef');

let deployer
let accounts
let nullAcc = "0x0000000000000000000000000000000000000000"

contract('MasterChef', (allAccounts) => {
	deployer = allAccounts[0];
	accounts = allAccounts.slice(1);

	it('1 LP', async () => {
		this.lic = await ERC20Mock.new({from: deployer});
		this.token0 = await ERC20Mock.new({from: deployer});
		this.router = await IPancakeRouter.at("0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F");
		this.masterchef = await MockMasterChef.new();
		this.treasury = await Treasury.new();
		await this.treasury.initialize(deployer, {from: deployer})
		await this.treasury.setTokens(this.router.address, this.lic.address, this.masterchef.address, {from: deployer})

		//add liquidity for lic-bnb
		await this.lic.approve(this.router.address, new BN('1000000e18').toFixed(0), {from: deployer});
		await this.token0.approve(this.router.address, new BN('1000000e18').toFixed(0), {from: deployer});

		await this.router.addLiquidityETH(this.lic.address, new BN('100000e18').toFixed(0),
			0,
			0,
			deployer,
			555555555555555, {from: deployer, value: new BN('5e18').toFixed(0) });
		
		await this.router.addLiquidityETH(this.token0.address, new BN('100000e18').toFixed(0),
			0,
			0,
			deployer,
			555555555555555, {from: deployer, value: new BN('5e18').toFixed(0)});
		
		await this.treasury.setSwapPath("0x0000000000000000000000000000000000000001", [(await this.router.WETH()).valueOf().toString(), this.lic.address], {from: deployer});
		await this.treasury.setSwapPath(this.token0.address, [this.token0.address, (await this.router.WETH()).valueOf().toString(), this.lic.address], {from: deployer});		

		//send some bnb to treasury
		await web3.eth.sendTransaction({from: deployer, to: this.treasury.address, value: new BN('1e18').toFixed(0)});
		await this.token0.transfer(this.treasury.address, new BN('100e18').toFixed(0), {from: deployer});

		let balBefore = (await this.lic.balanceOf(this.masterchef.address)).valueOf().toString();
		await this.treasury.buybackLIC("0x0000000000000000000000000000000000000001", {from: deployer});
		let balAfter = (await this.lic.balanceOf(this.masterchef.address)).valueOf().toString();
		assert.notEqual(balAfter, balBefore);

		balBefore = balAfter;
		await this.treasury.buybackLIC(this.token0.address, {from: deployer});
		balAfter = (await this.lic.balanceOf(this.masterchef.address)).valueOf().toString();
		assert.notEqual(balAfter, balBefore);

		//rescue token
		await this.token0.transfer(this.treasury.address, new BN('100e18').toFixed(0), {from: deployer});
		assert.notEqual('0', (await this.token0.balanceOf(this.treasury.address)).valueOf().toString());
		await this.treasury.rescueFunds(this.token0.address, {from: deployer});
		assert.equal('0', (await this.token0.balanceOf(this.treasury.address)).valueOf().toString());
	});
})