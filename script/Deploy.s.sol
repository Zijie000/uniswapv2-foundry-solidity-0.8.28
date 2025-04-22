// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";
import "@uniswap/periphery/contracts/UniswapV2Router02.sol";
import "@uniswap/periphery/contracts/interfaces/IUniswapV2Router02.sol";

// ... import other contracts

contract DeployUniswapV2 is Script {
  function run() external {
    vm.startBroadcast();

        address feeToSetter = msg.sender;

        address dummyWETH = address(0xBEEF);
        IUniswapV2Factory factory = new UniswapV2Factory(feeToSetter);
        address pairAddress = factory.createPair(0x5FbDB2315678afecb367f032d93F642f64180aa3, 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
        console.log("Created Pair:", pairAddress);

        IUniswapV2Router02 router = new UniswapV2Router02(address(factory), dummyWETH);

        console.log("WETH: ", dummyWETH);
        console.log("Factory: ", address(factory));
        console.log("Router: ", address(router));

        vm.stopBroadcast();
  }
}
