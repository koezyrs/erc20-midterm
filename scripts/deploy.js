const hre = require("hardhat");

async function main() {
  const initialSupply = hre.ethers.parseUnits("1000000", 18); // 1000 token với 18 số thập phân
  const MyToken = await hre.ethers.getContractFactory("MyToken");

  const myToken = await MyToken.deploy(
    initialSupply,
    "0xdD2FD4581271e230360230F9337D5c0430Bf44C0"
  );

  await myToken.waitForDeployment();
  await myToken.transfer(
    "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199",
    ethers.parseUnits("1000", 18)
  );
  console.log("MyToken deployed to:", myToken.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
