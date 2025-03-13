import {Test, console} from "forge-std/Test.sol";

contract ERC20Mock {
    string public name = "MockToken";
    string public symbol = "MCK";
    uint8 public decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // 为了在测试里随时给自己铸币
    function mint(address _to, uint256 _amount) external {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(balanceOf[msg.sender] >= _amount, "insufficient balance");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        return true;
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowance[msg.sender][_spender] = _amount;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        require(balanceOf[_from] >= _amount, "insufficient balance");
        require(allowance[_from][msg.sender] >= _amount, "allowance exceeded");
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;
        return true;
    }
}

// ========== The Router test itself ==========
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    // ... 省略接口中的其他函数，为简化只保留你测试要用到的
}

contract UniswapV2Router02Test is Test {
    IUniswapV2Router02 router;
    ERC20Mock tokenA;
    ERC20Mock tokenB;

    function setUp() public {
        // 这里假设你已经把 Router 部署好，或者有个地址，如果你需要也可直接 new ...
        // router = new UniswapV2Router02(...);

        // 简化：就算你把 Router 直接 hardcode 到某个地址，只要足以让下面的 test 跑起来即可
        // router = IUniswapV2Router02(0x...);

        // 部署两个 Token
        tokenA = new ERC20Mock();
        tokenB = new ERC20Mock();

        // 给自己铸造一些代币
        tokenA.mint(address(this), 1000 ether);
        tokenB.mint(address(this), 1000 ether);

        // Approve 给路由使用
        tokenA.approve(address(router), type(uint256).max);
        tokenB.approve(address(router), type(uint256).max);
    }

    function testAddLiquidity() public {
        // 这里只是举例子调用 router 的函数，比如:
        // router.addLiquidity(address(tokenA), address(tokenB), ...);
        // (需要真实的 Router 地址或你自己 new 出来)
        // 你可以对返回值做断言
    }
}