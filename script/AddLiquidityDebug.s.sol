pragma solidity ^0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/periphery/contracts/interfaces/IUniswapV2Router02.sol";
//import "@uniswap/periphery/contracts/UniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AddLiquidityDebug is Script {
    function run() external {

        vm.startBroadcast();
        // 1. 配置地址
        address tokenA = 0x5FbDB2315678afecb367f032d93F642f64180aa3; // 👉 填上你部署的 TokenA 地址
        address tokenB = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512; // 👉 填上你部署的 TokenB 地址
        address router = 0x0165878A594ca255338adfa4d48449f69242Eb8F; // 👉 你部署的 Router 地址
        address factory = IUniswapV2Router02(router).factory();
        address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // 从私钥推导地址

        console.log("1");

        uint amountADesired = 1e18;
        uint amountBDesired = 1e18;
        uint deadline = block.timestamp + 300;

        console.log("2");
        

        // 2. 打印初始状态
        console.log("User:", user);
        console.log("Router:", router);
        console.log("Factory:", factory);
        console.log("TokenA balance:", IERC20(tokenA).balanceOf(user));
        console.log("TokenB balance:", IERC20(tokenB).balanceOf(user));
        console.log("Allowance A:", IERC20(tokenA).allowance(user, router));
        console.log("Allowance B:", IERC20(tokenB).allowance(user, router));

        console.log("3");

        // 3. 手动 approve（如果还没做）
        IERC20(tokenA).approve(router, amountADesired);
        IERC20(tokenB).approve(router, amountADesired);

        console.log("TokenA balance:", IERC20(tokenA).balanceOf(user));
        console.log("TokenB balance:", IERC20(tokenB).balanceOf(user));


        console.log("4");

        console.log("Allowance A after:", IERC20(tokenA).allowance(user, router));
        console.log("Allowance B after:", IERC20(tokenB).allowance(user, router));

        console.log("5");

        // 4. 调用 _addLiquidity（间接通过 router）
        console.log("Calling addLiquidity...");
        try IUniswapV2Router02(router).addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            0, // amountAMin
            0, // amountBMin
            user,
            deadline
        ) returns (uint amountA, uint amountB, uint liquidity) {
            console.log("Success");
            console.log("Amount A used:", amountA);
            console.log("Amount B used:", amountB);
            console.log("Liquidity received:", liquidity);
        } catch Error(string memory reason) {
            console.log("Revert with reason:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("Low-level revert data:");
            console.logBytes(lowLevelData);
        }

        console.log("6");

        // 5. 打印 pair 状态
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        console.log("Pair address:", pair);
        console.log("LP token balance:", IERC20(pair).balanceOf(user));

        console.log("7");

        vm.stopBroadcast();

        console.log("8");
    }
}
