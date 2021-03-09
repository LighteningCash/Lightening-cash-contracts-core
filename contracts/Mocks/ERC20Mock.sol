pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract ERC20Mock is ERC20Detailed, ERC20Mintable {
  constructor() ERC20Detailed("Mock", "MOCK", 18) public {
    mint(msg.sender, 1000000e18);
  }
}
