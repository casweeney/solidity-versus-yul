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
        assembly {
            let mem_ptr := mload(0x40) // Get the free memory pointer
            mstore(mem_ptr, 0x20) // Store the offset to the string data
            mstore(add(mem_ptr, 0x20), tokenSymbolLength) // Store the string length
            mstore(add(mem_ptr, 0x40), tokenSymbolData) // Store the string data
            return(mem_ptr, 0x60) // Return the memory pointer and total size
        }
    }

    function decimal() public pure returns (uint8) {
        assembly {
            mstore(0x00, 0x12) // Alternatively use: mstore(0x00, 18) => // Store the value 18 in memory
            return(0x00, 0x20) // Return 32 bytes (ABI-compliant for uint256
        }
    }

    function totalSupply() public view returns (uint256) {
        assembly {
            let total_supply := sload(0x02) // Load the value of total supply from storage slot 0x02
            mstore(0x00, total_supply) // Store the value in memory at address 0x00
            return(0x00, 0x20) // Return 32 bytes from memory starting at 0x00
        }
    }
    
    function balanceOf(address) public view returns (uint256) {
        assembly {
            // Step 1: Load the input address from calldata => at 0x00
            mstore(0x00, calldataload(4))

            // Step 2: Prepare for keccak256 hashing by storing mapping prefix (0x00)
            // Store the pointer of the calldataload(4) to 0x20
            mstore(0x20, 0x00)

            // Step 3: Compute the storage key for the address in the balances mapping
            // keccak256(0x00, 0x40) => hash 0x00 to 0x40 and generate a key
            let slot := keccak256(0x00, 0x40)

            // Step 4: Load the balance from the computed storage slot
            // sload(keccak256(0x00, 0x40)) load what's in the key
            let _balance := sload(slot)

            // Step 5: Write the balance to memory for return
            mstore(0x00, _balance)

            // Step 6: Return 32 bytes (the balance) from memory at 0x00
            return(0x00, 0x20)
        }
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        assembly {
            // Step 1: Compute the innerKeyHash for the owner and mapping prefix
            mstore(0x00, owner) // Store owner address in memory at 0x00
            mstore(0x20, 0x01) // Store mapping prefix (0x01) in memory at 0x20
            let innerKeyHash := keccak256(0x00, 0x20) // Compute innerKeyHash for allowances[owner]

            // Step 2: Compute the final hash for spender
            mstore(0x00, spender) // Store spender address in memory at 0x00
            mstore(0x20, innerKeyHash) // Store innerKeyHash in memory at 0x20
            let allowanceSlot := keccak256(0x00, 0x40) // Compute storage slot for allowances[owner][spender]

            // Step 3: Load the allowance value from the computed slot
            let allowanceValue := sload(allowanceSlot) // Load the allowance value

            // Step 4: Return the allowance value
            mstore(0x00, allowanceValue) // Store allowance value in memory at 0x00
            return(0x00, 0x20) // Return allowanceValue stored in memory at 0x00 => return size id 32 bytes
        }
    }
    
    function transfer(address receiver, uint256 value) public returns (bool) {
        assembly {
            // Memory pointer for temporary storage
            let mem_ptr := mload(0x40)

            // Load caller's balance, and assert sufficient funds
            mstore(mem_ptr, caller()) // Store caller's address in memory
            mstore(add(mem_ptr, 0x20), 0x00) // Store mapping prefix (0x00) at memory+32
            let callerBalanceSlot := keccak256(mem_ptr, 0x40) // Compute storage slot for caller's balance
            let callerBalance := sload(callerBalanceSlot) // Load caller's balance from storage

            // Check if caller has sufficient balance
            if lt(callerBalance, value) {
                mstore(0x00, InsufficientFundsSelector) // store -> Error: Insufficient funds in memory
                revert(0x00, 0x04) // Revert error
            }

            // Check if caller is receiver
            // Prevent self-transfer
            if eq(caller(), receiver) { revert(0x00, 0x00) }

            // Decrease caller's balance
            let newCallerBalance := sub(callerBalance, value)
            sstore(callerBalanceSlot, newCallerBalance)

            // Load receiver's balance
            mstore(mem_ptr, receiver) // Store receiver's address in memory
            mstore(add(mem_ptr, 0x20), 0x00) // Store mapping prefix (0x00) at memory+32

            let receiverBalanceSlot := keccak256(mem_ptr, 0x40) // Compute storage slot for receiver's balance
            let receiverBalance := sload(receiverBalanceSlot) // Load receiver's balance from storage

            // Increase receiver's balance
            let newReciverBalance := add(receiverBalance, value)

            // Store updated receiver's balance
            sstore(receiverBalanceSlot, newReciverBalance)

            // Log transfer event
            mstore(0x00, value) // Store transferred value in memory
            log3(0x00, 0x20, transferEventHash, caller(), receiver) // Emit Transfer event

            // Return success
            mstore(0x00, 0x01) // Store `true` (success) in memory
            return(0x00, 0x20) // Return 32 bytes from memory
        }
    }
    
    function transferFrom(address sender, address receiver, uint256 value) public returns (bool) {
        assembly {
            // Memory pointer for temporary storage
            let mem_ptr := mload(0x40)

            // Step 1: Compute the allowance slot for caller
            mstore(0x00, sender) // Store sender address at 0x00
            mstore(0x20, 0x01) // Store mapping prefix (0x01) at 0x20
            let innerKeyHash := keccak256(0x00, 0x20) // Compute intermediate hash for allowances[sender]

            mstore(0x00, caller()) // Store caller's address at 0x00
            mstore(0x20, innerKeyHash) // Store innerKeyHash at 0x20
            let allowanceSlot := keccak256(0x00, 0x40) // Compute storage slot for allowances[sender][caller]

            // Step 2: Check allowance
            let callerAllowance := sload(allowanceSlot) // Load the allowance

            if lt(callerAllowance, value) { // Check if allowance < value
                mstore(mem_ptr, InsufficientAllowanceSelector) // Store Error hash (Insufficient allowance) in memory at mem_ptr
                mstore(add(mem_ptr, 0x04), sender)
                mstore(add(mem_ptr, 0x24), caller())
                revert(mem_ptr, 0x44)
            }

            // Update allowance if less than total supply
            if lt(callerAllowance, totalSupplyInHex) {
                sstore(allowanceSlot, sub(callerAllowance, value))
            }

            // Step 3: Check sender balance
            mstore(mem_ptr, sender) // Store sender's address in memory
            mstore(add(mem_ptr, 0x20), 0x00) // Store mapping prefix for balances
            let senderBalanceSlot := keccak256(mem_ptr, 0x40) // Compute storage slot for sender's balance
            let senderBalance := sload(senderBalanceSlot) // Load sender's balance

            if lt(senderBalance, value) { // Check if balance < value
                mstore(0x00, InsufficientFundsSelector) // Store Error: Insufficient funds, in memory
                revert(0x00, 0x04) // revert with error stored in memory at 0x00
            }

            // Decrease sender's balance
            sstore(senderBalanceSlot, sub(senderBalance, value))

            // Step 4: Increase receiver balance
            mstore(mem_ptr, receiver) // Store receiver's address in memory
            mstore(add(mem_ptr, 0x20), 0x00) // Store mapping prefix for balances in memory
            let receiverBalanceSlot := keccak256(mem_ptr, 0x40) // Compute storage slot for receiver's balance
            let receiverBalance := sload(receiverBalanceSlot) // Load receiver's balance

            sstore(receiverBalanceSlot, add(receiverBalance, value)) // Increase receiver's balance

            // Step 5: Emit Transfer event
            mstore(0x00, value) // Store value (amount) in memory
            log3(0x00, 0x20, transferEventHash, sender, receiver) // Emit Transfer event

            // Step 6: Return true
            mstore(0x00, 0x01) // Store `true` (1) in memory
            return(0x00, 0x20) // Return 32 bytes from memory at 0x00
        }
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        assembly {
            // Step 1: Compute the innerKeyHash for the caller (owner) and mapping prefix
            mstore(0x00, caller()) // Store caller's address (owner) at 0x00 in memory
            mstore(0x20, 0x01) // Store mapping prefix (0x01) at 0x20 in memory
            let innerKeyHash := keccak256(0x00, 0x20) // Compute innerKeyHash for allowances[owner]

            // Step 2: Compute the final hash for spender
            mstore(0x00, spender) // Store spender address at 0x00
            mstore(0x20, innerKeyHash) // Store innerKeyHash at 0x20
            let allowanceSlot := keccak256(0x00, 0x40) // Compute storage slot for allowances[owner][spender]

            // Step 3: Store the allowance value
            sstore(allowanceSlot, value) // Set allowances[owner][spender] = value

            // Step 4: Emit Approval event
            mstore(0x00, value) // Store value (allowance) in memory at 0x00
            log3(0x00, 0x20, approvalEventHash, caller(), spender) // Emit Approval event

            // Step 5: Return true
            mstore(0x00, 0x01) // Store `true` (1) in memory at 0x00
            return(0x00, 0x20) // Return 32 bytes from memory at 0x00
        }
    }
}