// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract ERC20 {

    string public tokenName = "ERC20";
    string public tokenSymbol = "erc20x";
    uint8 public tokenDecimals = 8;
    uint public totalTokenSupply;
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public tokenAllownace;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() public view returns (string memory){
        return tokenName;
    }
    function symbol() public view returns (string memory){
        return tokenSymbol;
    }
    function decimals() public view returns (uint8){
        return tokenDecimals;
    }
    function totalSupply() public view returns (uint256){
        return totalTokenSupply;
    }
    function balanceOf(address _owner) public view returns (uint256 balance){
        balance = balances[_owner];
    }
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balances[msg.sender] >= _value, "Not sufficient Token to Transfer");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(balances[_from] >= _value , "Not Enough Tokens");
        require(tokenAllownace[_from][msg.sender] >= _value , "Not Enough Allowance");
        tokenAllownace[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        success = true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        require(balances[msg.sender] >= _value, "Not sufficient Token");
        tokenAllownace[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        success = true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        remaining = tokenAllownace[_owner][_spender];
    }
}
