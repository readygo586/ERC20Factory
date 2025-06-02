// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyERC20 is ERC20, Ownable, ERC20Permit {
    uint256 private BASE = 10**18;
    uint256 public price;

    event TokensBurned(address indexed user, uint256 amount, uint256 ethReturned);
    event TokensMinted(address indexed to, uint256 amount, uint256 ethDeposited);
    event EmergencyWithdrawal(address indexed owner, uint256 ethWithdrawn);

    constructor(string memory name, string memory symbol,uint256 initialSupply, address initialBeneficiary, uint256 ethAmount)
    ERC20(name, symbol)
    Ownable(msg.sender)
    ERC20Permit(name)
    payable
    {
        require(msg.value == ethAmount, "Incorrect ETH sent for buyback pool");
        price =  ethAmount * BASE / initialSupply;
        _mint(initialBeneficiary, initialSupply);
    }

    function mint(address to, uint256 newSupply, uint256 ethAmount) payable public onlyOwner {
        require(msg.value == ethAmount, "Incorrect ETH sent for buyback pool");
        require(ethAmount * BASE == price * newSupply, "Incorrect price for new supply");

        _mint(to, newSupply);
        emit TokensMinted(to, newSupply, ethAmount);
    }

    function burn(uint amount) public  {
        uint256 refundEthAmount = amount * price / BASE;
        require(address(this).balance >= refundEthAmount,"Insufficient ETH in buyback pool");

        _burn(msg.sender, amount);
        payable(msg.sender).transfer(refundEthAmount);
        emit TokensBurned(msg.sender, amount, refundEthAmount);
    }

    function EmergencyWithdraw() public onlyOwner {
        uint256 amount = address(this).balance - (price * totalSupply() / BASE);
        require(amount > 0, "Amount must > 0");
        payable(msg.sender).transfer(amount);
        emit EmergencyWithdrawal(msg.sender, amount);
    }

    receive() external payable {}
}
