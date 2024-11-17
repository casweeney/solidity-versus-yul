// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract SolidityERC20Token {
    uint public totalSupply = 1000000 * 10 ** 18;
    string public name = "Solidity ERC20 Token";
    string public symbol = "SET";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;
    
    // Send all the token to whoever deploys the contract
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256 remaining) {
        return allowances[owner][spender];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowances[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}