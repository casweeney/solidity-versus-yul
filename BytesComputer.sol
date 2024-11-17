// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract BytesComputer {
    // bytes4(keccak256("InsufficientFunds()")) 0x356680b7
    // bytes4(keccak256("InsufficientAllowance(address, address)")) 0xf180d8f9

    function computeInsufficientFunds() external pure returns(bytes4) {
        return bytes4(keccak256("InsufficientFunds()"));
    }

    function computeInsufficientAllowance() external pure returns(bytes4) {
        return bytes4(keccak256("InsufficientAllowance(address,address)"));
    }

    function computeTransferHash() public pure returns (bytes32) {
        return keccak256(abi.encodePacked("Transfer(address,address,uint256)"));
    }

    function computeApprovalHash() public pure returns (bytes32) {
        return keccak256(abi.encodePacked("Approval(address,address,uint256)"));
    }
}