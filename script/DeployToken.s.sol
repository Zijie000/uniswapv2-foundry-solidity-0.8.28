// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/MyToken.sol";

contract DeployToken is Script {
    function run() public {
        // 1. 读取私钥
        uint256 deployerPrivateKey = 0xa0117ef161e6dae08b2dd8b9b3d84bbeac4758ea4c7c7893a6bff5a58a2d741c;

        // 2. 开始广播交易
        vm.startBroadcast(deployerPrivateKey);

        // 3. 部署合约
        MyToken tokenA = new MyToken("ZijieTokenA", "ZTKA");

        MyToken tokenB = new MyToken("ZijieTokenB", "ZTKB");

        // 4. 停止广播
        vm.stopBroadcast();

        // 输出日志：打印合约地址
        console.log("ZijieTokenA deployed at:", address(tokenA));
        console.log("ZijieTokenB deployed at:", address(tokenB));
    }
}
