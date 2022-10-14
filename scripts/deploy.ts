import { ethers } from "hardhat";

async function main() {
  const Lib = await ethers.getContractFactory("AssetModelV2");
  const lib = await Lib.deploy();
  await lib.deployed();

  const AssetManager = await ethers.getContractFactory("AssetManagerV2", {
    libraries: {
      AssetModelV2: lib.address,
    },
  });
  const assetManager = await AssetManager.deploy();

  await assetManager.deployed();

  console.log(`AssetManager contract is deployed to ${assetManager.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
