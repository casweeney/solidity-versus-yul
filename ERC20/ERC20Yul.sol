// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract YulERC20Token {
    ///// Using constant definitions to store token name and symbol in a gas efficient way //////////
    ///// The constants below are used in name() and symbol() functions to return the token's name and symbol as strings ///////

    // ----------- Token Name -------------------
    // Length of token name => "Solidity ERC20 Token" => 13
    bytes32 constant tokenNameLength = 0x0000000000000000000000000000000000000000000000000000000000000013;
    // Bytes representation of token name => "Solidity ERC20 Token" => converted using rapid tables
    bytes32 constant tokenNameData = 0x536f6c696469747920455243323020546f6b656e000000000000000000000000;

    // ----------- Token Symbol -------------------
    // Length of token symbol => "SET" => 3
    bytes32 constant tokenSymbolLength = 0x0000000000000000000000000000000000000000000000000000000000000003;
    // Bytes representation of token symbol => "SET" => converted using rapid tables
    bytes32 constant tokenSymbolData = 0x5345540000000000000000000000000000000000000000000000000000000000;

    /////// Error Selectors - There are used in the contract's revert message //////////
    // bytes4(keccak256("InsufficientFunds()")) 0x356680b7
    bytes32 constant InsufficientFundsSelector = 0x356680b700000000000000000000000000000000000000000000000000000000;

    // bytes4(keccak256("InsufficientAllowance(address, address)")) 0xf180d8f9
    bytes32 constant InsufficientAllowanceSelector = 0xf180d8f900000000000000000000000000000000000000000000000000000000;

    error InsufficientFunds();
    error InsufficientAllowance(address owner, address spender);

    // 1000000 * 10 ** 18 value in HEX => minted to deployer
    uint256 constant totalSupplyInHex = 0xd3c21bcecceda1000000;

    ///////////////// Event Signatures ->  ////////////////////////
    // keccak256(abi.encodePacked("Transfer(address,address,uint256)"))
    bytes32 constant transferEventHash = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    // keccak256(abi.encodePacked("Approval(address,address,uint256)"))
    bytes32 constant approvalEventHash = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    
    // Send all the token to whoever deploys the contract
    constructor() {
        assembly {
            mstore(0x00, caller()) // Store deployer's address at memory location 0x00 (0)
            mstore(0x20, 0x00) // Store mapping prefix (0x00) at memory location 0x20
            let slot := keccak256(0x00, 0x40) // Compute storage slot for deployer's balance
            sstore(slot, totalSupplyInHex) // Assign total supply to deployer's balance

            sstore(0x20, totalSupplyInHex) // Store total supply in storage slot 0x20

            mstore(0x00, totalSupplyInHex) // Prepare total supply value for logging
            log3(0x00, 0x20, transferEventHash, 0x00, caller()) // Emit Transfer event
        }
    }

    function name() public pure returns (string memory) {
        assembly {
            let mem_ptr := mload(0x40) // Get the free memory pointer
            mstore(mem_ptr, 0x20) // Store the offset to the string data
            mstore(add(mem_ptr, 0x20), tokenNameLength) // Store the string length
            mstore(add(mem_ptr, 0x40), tokenNameData) // Store the string data
            return(mem_ptr, 0x60) // Return the memory pointer and total size
        }
    }

    function symbol() public pure returns (string memory) {

    }

    function decimal() public pure returns (uint8) {

    }

    function totalSupply() public view returns (uint256) {

    }
    
    function balanceOf(address owner) public view returns(uint) {
        
    }
    
    function transfer(address to, uint value) public returns(bool) {
        
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        
    }
    
    function approve(address spender, uint value) public returns(bool) {
        
    }
}