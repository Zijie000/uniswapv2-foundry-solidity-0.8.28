// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// 引入 OpenZeppelin 的 ERC20 实现（需要先在本地导入依赖，见下方“导入OpenZeppelin库”）
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    // 构造函数，初始化代币名称和符号
    constructor(
        string memory name, string memory symbol
        )
        Ownable(address(1))
        ERC20(name, symbol) {
        // 铸造 1000 个代币给部署者
        
        
        _transferOwnership(msg.sender);
        _mint(msg.sender, 1000 * 10**decimals());
    }

    // 额外的铸造函数（只有合约owner可以调用）
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
