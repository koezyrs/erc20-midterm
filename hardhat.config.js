require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      chainId: 31337, // Mạng local
      mining: {
        auto: false, // Tắt automining
        interval: 5000, // Mine block mỗi 5 giây
      },
    },
  },
};
