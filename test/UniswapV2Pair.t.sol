pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2Pair} from "../src/uniswap/core/contracts/UniswapV2Pair.sol";
import {UniswapV2Factory} from "../src/uniswap/core/contracts/UniswapV2Factory.sol";
import {UniswapV2ERC20} from "../src/uniswap/core/contracts/UniswapV2ERC20.sol";
//import "../src/uniswap/MockERC20.sol";
import {UniswapV2Library} from "../src/uniswap/periphery/contracts/libraries/UniswapV2Library.sol";

contract MockERC20 {
    string public name = "MockERC20";
    string public symbol = "MERC";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _initialSupply) {
        _mint(msg.sender, _initialSupply);
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        require(balanceOf[_from] >= _amount, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _amount, "Insufficient allowance");
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function _mint(address _to, uint256 _amount) internal {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }
}

contract UniswapV2PairTest is Test {
    // 4. 定义状态变量
    UniswapV2Pair public pair;
    address public token0;
    address public token1;

    // 常量仅做示例
    uint256 constant INITIAL_SUPPLY = 100_000e18;

    // 5. setUp()：在每个测试函数之前都会被调用；可以在此完成合约部署、初始赋值等
    function setUp() public {
        // 部署两个 Mock ERC20 代币
        MockERC20 mockToken0 = new MockERC20(INITIAL_SUPPLY);
        MockERC20 mockToken1 = new MockERC20(INITIAL_SUPPLY);

        token0 = address(mockToken0);
        token1 = address(mockToken1);

        // 部署并生成 Pair 合约实例（直接用新合约的方式，或由 Factory 创建）
        // 注意：实际 UniswapV2Pair 需要 factory 地址，这里仅作为示例
        pair = new UniswapV2Pair();

        // 在 Uniswap V2 中，必须由 Factory 调用 pair.initialize(token0, token1)。
        // 这里简化写死:
        pair.initialize(token0, token1);
    }

    // 6. 测试 initialize()
    function testInitialize() public {
        // 断言 token0 / token1 已被正确设置
        assertEq(pair.token0(), token0, "token0 mismatch");
        assertEq(pair.token1(), token1, "token1 mismatch");
    }

    // 7. 测试 getReserves() （只读方法）
    function testGetReserves() public {
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        // 初始状态下储备应该为 0
        assertEq(reserve0, 0, "reserve0 should be 0");
        assertEq(reserve1, 0, "reserve1 should be 0");
    }


    // 11. 测试 skim()
    // skim 可以把余额中多余的代币转给某个地址
    function testSkim() public {
        // 先把多余代币转进合约
        MockERC20(token0).transfer(address(pair), 500e18);

        // 当前 reserve0 是 0，所以多余代币 500e18
        // skim => 将多余部分转给指定地址
        pair.skim(address(this));

        // pair 合约内不应该剩余多余 token
        // 这里直接检查 pair 合约内的 token0 的余额
        uint256 pairBalance = MockERC20(token0).balanceOf(address(pair));
        // 由于 reserves=0，此时 pairBalance 应该为 0
        assertEq(pairBalance, 0, "pair should have skimmed out the extra tokens");
    }

    // 12. 测试 sync()
    // sync 可以强行将储备更新为合约余额
    function testSync() public {
        // 先转入一些代币，但并不调用 mint
        MockERC20(token0).transfer(address(pair), 1_234e18);

        // 此时 getReserves() 仍为 0，因为没更新
        (uint112 reserve0Before,,) = pair.getReserves();
        assertEq(reserve0Before, 0, "reserve0 should be 0 before sync");

        // 调用 sync()
        pair.sync();

        (uint112 reserve0After,,) = pair.getReserves();
        // reserves 应该更新到合约内实际余额
        assertEq(reserve0After, 1234e18, "reserve0 mismatch after sync");
    }
}
