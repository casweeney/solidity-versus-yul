// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract StringsInSolidity {
    string someString;

    function setString(string memory _someString) external {
        someString = _someString;
    }

    function getString() external view returns (string memory) {
        return someString;
    }
}

contract StringInYul {
    string public storedString;

    function setString(string memory _string) external {
        // string is first converted into its bytes before being used in assembly.
        // Storage for bytes goes two ways:
        // 1. Storage for bytes with length less than or equal to 31.
        // 2. Storage for bytes with length greater than or equal to 32.
        // To store the string, we have to first check the length of the string,
        // then use conditional statement to switch cases and store the string accordingly
        assembly {
            // Get the storage slot of the `storedString` variable
            let slot := storedString.slot

            // Get the length of the input string
            let length := mload(_string)

            // Check if the string length is <= 31 bytes
            if iszero(gt(length, 31)) {
                // Store the packed length and content in the slot
                let packed := add(mload(add(_string, 0x20)), mul(length, 2))
                sstore(slot, packed)
            }

            if gt(length, 31) {
                // For strings longer than 31 bytes:
                // Compute the storage location for string content
                mstore(0x00, slot)
                let contentSlot := keccak256(0x00, 0x20)

                // Store the string length at the first slot
                sstore(slot, length)

                // Store the string content in subsequent slots
                let offset := add(_string, 0x20) // Start of string content in memory
                for { let i := 0 } lt(i, length) { i := add(i, 32) } {
                    sstore(add(contentSlot, div(i, 32)), mload(add(offset, i)))
                }
            }
        }
    }

    function getString() external view returns (string memory str_) {
        assembly {
            // Get the storage slot of the `storedString` variable
            let slot := storedString.slot

            // Read the stored value
            let storedValue := sload(storedString.slot)

            // Check if the stored value is packed (length ≤ 31 bytes)
            if iszero(gt(and(storedValue, 0xFF), 31)) {
                // Allocate memory for the string
                let length := and(storedValue, 0xFF) // Extract length
                str_ := mload(0x40) // Free memory pointer
                mstore(str_, length) // Set length
                mstore(0x40, add(str_, 0x40)) // Update free memory pointer
                mstore(add(str_, 0x20), storedValue) // Copy content
            }

            if gt(and(storedValue, 0xFF), 31) {
                // If length > 31 bytes, load from content storage
                let length := storedValue
                str_ := mload(0x40) // Free memory pointer
                mstore(str_, length) // Set length
                let contentSlot := keccak256(slot, 0x20) // Compute content slot
                for { let i := 0 } lt(i, length) { i := add(i, 32) } {
                    mstore(add(str_, add(0x20, i)), sload(add(contentSlot, div(i, 32))))
                }
                mstore(0x40, add(str_, add(0x20, length))) // Update free memory pointer
            }
        }
    }
}