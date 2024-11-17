// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract WithdrawSolidity {
    constructor() payable {}
    
    address public constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    function withdrawWithCall() external {
        (bool sent, ) = payable(owner).call{value: address(this).balance}("");
        require(sent);
    }

    function withdrawWithTransfer() external {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawToCaller() external {
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent);
    }
}

contract WithdrawYul {
    constructor() payable {}
    
    address public constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    function withdrawWithCall() external {
        assembly {
            // call is a low-level EVM opcode used to send Ether or execute a function call.
            // gas() is the amount of gas to send with the call. Using gas() passes all the remaining gas.
            // selfbalance() retrieves the contract's total ether balance.
            let sent := call(gas(), owner, selfbalance(), 0, 0, 0, 0)
            if iszero(sent) { revert(0, 0) }
        }
    }

    function withdrawWithTransfer() external {
        assembly {
            // Transfer still uses call opcode, the only difference is that in transfer the gas is hardcoded => 2300
            let sent := call(2300, owner, selfbalance(), 0, 0, 0, 0)
            if iszero(sent) { revert(0, 0) }
        }
    }

    function withdrawToCaller() external {
        assembly {
            let sent := call(gas(), caller(), selfbalance(), 0, 0, 0, 0)
            if iszero(sent) { revert(0, 0) }
        }
    }
}