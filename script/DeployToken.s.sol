// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
import {Script, console} from "lib/forge-std/src/Script.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";
import "@uniswap/periphery/contracts/UniswapV2Router02.sol";
import "@uniswap/periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract DeployToken is Script {
    function run() public {
        // 1. 读取私钥
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        // 2. 开始广播交易
        vm.startBroadcast(deployerPrivateKey);

        // 3. 部署合约
        MyToken tokenA = new MyToken("ZijieTokenA", "ZTKA");

        MyToken tokenB = new MyToken("ZijieTokenB", "ZTKB");

        tokenA.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 1000000e18);
        tokenB.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 1000000e18);

        address feeToSetter = msg.sender;

        address dummyWETH = address(0xBEEF);
        IUniswapV2Factory factory = new UniswapV2Factory(feeToSetter);
        address pairAddress = factory.createPair(address(tokenA), address(tokenB));
        console.log("Created Pair:", pairAddress);

        IUniswapV2Router02 router = new UniswapV2Router02(address(factory), dummyWETH);


        console.log("WETH: ", dummyWETH);
        console.log("Factory: ", address(factory));
        console.log("Router: ", address(router));

        // 4. 停止广播
        vm.stopBroadcast();

        // 输出日志：打印合约地址
        console.log("ZijieTokenA deployed at:", address(tokenA));
        console.log("ZijieTokenB deployed at:", address(tokenB));
    }
}
