pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
import {Script, console} from "lib/forge-std/src/Script.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";
import "@uniswap/periphery/contracts/UniswapV2Router02.sol";
import "@uniswap/periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract FullDeployAndAddLiquidity is Script {

    // 为了示例，指定 user 的私钥
    // forge 已经默认给 0xf39Fd6e5... 这个账户一个私钥，用来做测试
    uint256 internal constant USER_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address internal constant USER_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() external {
        // 1. 启动广播，让本脚本发出的交易用 USER_PRIVATE_KEY
        vm.startBroadcast(USER_PRIVATE_KEY);

        // 2. 部署两个自定义 Token
        MyToken tokenA = new MyToken("Zijie Token A", "ZTK-A");
        MyToken tokenB = new MyToken("Zijie Token B", "ZTK-B");

        console.log("tokenA:", address(tokenA));
        console.log("tokenB:", address(tokenB));

        // 3. 给脚本部署者 (也是owner) 铸造一些代币，然后再转给 user 或者直接 mint 给 user
        //   由于本脚本里， msg.sender == USER_ADDRESS，也可以直接 mint 给 user
        tokenA.mint(USER_ADDRESS, 1000e18);
        tokenB.mint(USER_ADDRESS, 1000e18);

        console.log("After mint, user tokenA balance:", tokenA.balanceOf(USER_ADDRESS));
        console.log("After mint, user tokenB balance:", tokenB.balanceOf(USER_ADDRESS));

        // 4. 部署 Factory，指定 feeToSetter = USER_ADDRESS
        UniswapV2Factory factory = new UniswapV2Factory(USER_ADDRESS);
        console.log("Factory deployed:", address(factory));

        // 5. 部署 Router
        //    这里为了简化，不使用真实 WETH，随便搞个地址 placeholder，因为咱们只测 ERC20 对 ERC20
        address dummyWETH = address(0xBEEF);
        UniswapV2Router02 router = new UniswapV2Router02(address(factory), dummyWETH);
        console.log("Router deployed:", address(router));

        // 6. 显示 createPair (也可以省略，让 Router 的 addLiquidity 自动创建)
        address pairAddress = factory.createPair(address(tokenA), address(tokenB));
        console.log("Pair created:", pairAddress);

        // 7. user 给 router 授权
        //    这里因为 vm.startBroadcast(USER_PRIVATE_KEY)，所以 msg.sender = user
       

        vm.stopBroadcast();
    }
}
