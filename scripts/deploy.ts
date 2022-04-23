// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
"use strict";

import hre from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const NAME = "Real World Collectibles";
  const SYMBOL = "REAL";

  // We get the contract to deploy
  const RealWorldCollectiblesUpgradeable = await hre.ethers.getContractFactory(
    "RealWorldCollectiblesUpgradeable"
  );
  const nft = await hre.upgrades.deployProxy(
    RealWorldCollectiblesUpgradeable,
    [NAME, SYMBOL],
    { kind: "uups" }
  );

  await nft.deployed();

  console.log("RealWorldCollectiblesUpgradeable deployed to:", nft.address);

  const RealWorldCollectibles = await hre.ethers.getContractFactory(
    "RealWorldCollectibles"
  );
  const collectibles = await RealWorldCollectibles.deploy(NAME, SYMBOL);

  await collectibles.deployed();

  console.log("RealWorldCollectibles deployed to:", collectibles.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
