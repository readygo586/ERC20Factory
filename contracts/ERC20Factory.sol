// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CustomERC20.sol";


contract ERC20Factory is Ownable {
    uint256 public nonce;
    address[] public tokens;

    event TokenDeployed(address indexed tokenAddress, string name, string symbol);

    constructor() Ownable(msg.sender){}

    function deployToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address initialBeneficiary
    ) external onlyOwner returns (address tokenAddress) {
        bytes32 salt = keccak256(abi.encodePacked(block.chainid, msg.sender, nonce, name, symbol));
        bytes memory bytecode = abi.encodePacked(
            type(CustomERC20).creationCode,
            abi.encode(name, symbol)
        );

        assembly {
            tokenAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(tokenAddress)) {
                revert(0, 0)
            }
        }

        tokens.push(tokenAddress);
        nonce += 1;
        emit TokenDeployed(tokenAddress, name, symbol);

        CustomERC20(tokenAddress).mint(initialBeneficiary, initialSupply);
    }

    function mint(address token, address to, uint256 amount) external onlyOwner {
        require(isDeployedToken(token), "ERC20Factory: token not deployed by factory");
        CustomERC20(token).mint(to, amount);
    }

    function getTokens() external view returns (address[] memory) {
        return tokens;
    }

    function computeAddress(
        string memory name,
        string memory symbol,
        uint256 _nonce
    ) external view returns (address predicted) {
        bytes32 salt = keccak256(abi.encodePacked(block.chainid, msg.sender, _nonce, name, symbol));
        bytes memory bytecode = abi.encodePacked(
            type(CustomERC20).creationCode,
            abi.encode(name, symbol)
        );
        bytes32 hash = keccak256(bytecode);
        predicted = address(uint160(uint256(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                hash
            )))));
    }

    function isDeployedToken(address token) internal view returns (bool) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == token) {
                return true;
            }
        }
        return false;
    }
}