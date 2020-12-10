async function main() {
  const FlashSwap = await ethers.getContractFactory("FlashSwap");

  const flashSwap = await FlashSwap.deploy();

  console.log("contract deployed to:", flashSwap.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });