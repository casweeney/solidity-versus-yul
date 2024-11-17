// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract WithdrawSolidity {
    constructor() payable {}
    
    address public constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    function withdrawWithCall() external {
        (bool sent, ) = payable(owner).call{value: address(this).balance}("");
        require(sent);
    }
}

contract WithdrawYul {
    constructor() payable {}
    
    address public constant owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    function withdrawWithCall() external {
        assembly {
            let sent := call(gas(), owner, selfbalance(), 0, 0, 0, 0)
            if iszero(sent) { revert(0, 0) }
        }
    }
}