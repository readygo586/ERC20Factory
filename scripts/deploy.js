const { ethers, network } = require("hardhat");

async function main() {
    await deployERC20Factory();
}

async function deployERC20Factory() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());
    const Factory = await ethers.getContractFactory("ERC20Factory");
    const factory = await Factory.deploy();
    await factory.waitForDeployment();
    console.log("Factory deployed to:", await factory.getAddress());

}

main().catch(console.error);