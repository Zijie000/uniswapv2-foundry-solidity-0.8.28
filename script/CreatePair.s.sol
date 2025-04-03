pragma solidity ^0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";
import "@uniswap/periphery/contracts/UniswapV2Router02.sol";
import "@uniswap/periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "../src/MyToken.sol";

contract CreatePairAndSwap is Script {
    address constant FACTORY = 0x483528cD528BF5aF132744F062c21B92953A2591;

    address constant TOKEN_A = 0x3cF2e9DB047865233Ca0891866356217029aE523;
    address constant TOKEN_B = 0x25Ce5985dE144328dBB1466035be0021D7372D57;
                               


    function run() external {
        vm.startBroadcast();

        // 创建 Pair（如果未创建）
        address pair = IUniswapV2Factory(FACTORY).getPair(TOKEN_A, TOKEN_B);
        if (pair == address(0)) {
            pair = IUniswapV2Factory(FACTORY).createPair(TOKEN_A, TOKEN_B);
            console.log("Pair created at:", pair);
        }

    }
}