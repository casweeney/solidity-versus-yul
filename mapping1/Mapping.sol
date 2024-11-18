// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract SolidityMapping {
    // ID => Amount
    mapping(uint256 => uint256) myMapping;
    uint256 public count;

    function setMapping(uint256 _amount) external {
        uint256 _id = count + 1;

        myMapping[_id] = _amount;

        count++;
    }

    function getMappingValuw(uint256 _id) external view returns (uint256) {
        return myMapping[_id];
    }
}

contract YulMapping {
    mapping(uint256 => uint256) public myMapping; // Mapping to store key-value pairs
    uint256 public count; // Counter for unique IDs

    function setMapping(uint256 _amount) external {
        uint256 _id = count + 1; // Increment count to generate a new ID

        assembly {
            // Compute the storage slot for myMapping[_id]
            mstore(0x00, _id)                  // Store the key (_id) in memory at 0x00
            mstore(0x20, myMapping.slot)       // Store the mapping's slot at 0x20

            // Compute storage position: keccak256(_id . myMapping.slot)
            // 0x40 => size of memory region to be hashed
            // 0x40 is 64 in decimal: It indicates that:
            // keccak256 function should hash 64 bytes of data, starting from memory location 0x00
            let storage_pos := keccak256(0x00, 0x40)

            // Store the value (_amount) in the computed storage position
            sstore(storage_pos, _amount)

            // Update count (store the new value in its dedicated storage slot)
            sstore(count.slot, _id)
        }
    }

    function getMappingValue(uint256 _id) external view returns (uint256) {
        assembly {
            // Compute the storage slot for myMapping[_id]
            mstore(0x00, _id)              // Store the key (_id) at memory location 0x00
            mstore(0x20, myMapping.slot)   // Store the mapping's slot at memory location 0x20

            ///// Compute the storage position: keccak256(_id . myMapping.slot)////
            let storage_pos := keccak256(0x00, 0x40)

            // Load the value from the computed storage position
            let value := sload(storage_pos)

            // Store the result in memory for ABI-compliant return
            mstore(0x00, value)

            // Return the result (32 bytes starting from 0x00)
            return(0x00, 0x20)
        }
    }
}