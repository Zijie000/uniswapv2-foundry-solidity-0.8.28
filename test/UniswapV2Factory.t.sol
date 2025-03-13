pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2Factory} from "../src/uniswap/core/contracts/UniswapV2Factory.sol";

contract UniswapV2FactoryTest is Test {
    UniswapV2Factory public factory;
    
    // 用于模拟部署者或 feeToSetter
    address public owner = address(0x1234);
    address public alice = address(0xABCD);

    // 下面这两个地址用作待测试的 ERC20 token
    // 在真实测试里可以配合 MockERC20 来完成更多逻辑
    address public tokenA = address(0x1);
    address public tokenB = address(0x2);

    function setUp() public {
        // 先把 owner 设定为 msg.sender，来部署工厂合约
        vm.prank(owner);
        factory = new UniswapV2Factory(owner);
    }

    /// @notice 测试构造函数是否正确初始化
    function testConstructor() public {
        // feeToSetter 应该是构造时传入的 owner
        assertEq(factory.feeToSetter(), owner, "feeToSetter mismatch");
    }

    /// @notice 测试 createPair 函数
    function testCreatePair() public {
        vm.startPrank(owner);

        // 创建交易对
        address pair = factory.createPair(tokenA, tokenB);

        // 确认交易对不为 address(0)
        assertTrue(pair != address(0), "pair address is zero");

        // 再次调用 getPair 验证
        address storedPair = factory.getPair(tokenA, tokenB);
        assertEq(pair, storedPair, "storedPair mismatch");

        vm.stopPrank();
    }

    /// @notice 测试 allPairs 和 allPairsLength
    function testAllPairsAndLength() public {
        vm.startPrank(owner);
        // 先创建一个 pair
        address pair1 = factory.createPair(tokenA, tokenB);

        // 再创建另一个 pair（换一组 token）
        address tokenC = address(0x3);
        address tokenD = address(0x4);
        address pair2 = factory.createPair(tokenC, tokenD);

        uint256 length = factory.allPairsLength();
        // 应该有两个 pair
        assertEq(length, 2, "allPairsLength mismatch");

        // 验证 allPairs(0) 和 allPairs(1)
        address storedPair0 = factory.allPairs(0);
        address storedPair1 = factory.allPairs(1);
        assertEq(pair1, storedPair0, "allPairs(0) mismatch");
        assertEq(pair2, storedPair1, "allPairs(1) mismatch");

        vm.stopPrank();
    }

    /// @notice 测试 setFeeTo 功能
    function testSetFeeTo() public {
        // 只有 feeToSetter 才能调用
        vm.prank(owner);
        factory.setFeeTo(alice);

        // 检查是否真的设置成功
        assertEq(factory.feeTo(), alice, "feeTo did not update");
    }

    /// @notice 测试只有当前 feeToSetter 才能修改 feeToSetter
    function testSetFeeToSetter() public {
        // 用非当前 feeToSetter 试图调用，应报错
        vm.expectRevert();
        vm.prank(alice);
        factory.setFeeToSetter(alice);

        // 用正确的 owner 调用
        vm.prank(owner);
        factory.setFeeToSetter(alice);

        // 检查是否真的更新成功
        assertEq(factory.feeToSetter(), alice, "feeToSetter did not update");
    }

    /// @notice 测试 getPair: 当交易对还不存在时是否返回 address(0)
    function testGetNonExistentPair() public {
        address nonExistent = factory.getPair(tokenA, tokenB);
        assertEq(nonExistent, address(0), "Should be zero if pair does not exist");
    }
}