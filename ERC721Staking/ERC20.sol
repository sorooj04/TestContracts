// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "hardhat/console.sol";

interface IERC20{
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function _mint(address _reciever, uint _amount) external;
    function balanceOf(address user)external returns(uint);
}

contract ERC20 is IERC20 {

    address public owner;
    string public constant name = "ERC20";
    string public constant symbol = "erc20x";
    uint8 public constant decimals = 8;
    uint public totalSupply;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public tokenAllownace;

    constructor(uint _totalTokenSupply ) payable {
        totalSupply = _totalTokenSupply;
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value, "Not sufficient Token to Transfer");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(balanceOf[_from] >= _value , "Not Enough Tokens");
        require(tokenAllownace[_from][msg.sender] >= _value , "Not Enough Allowance");
        tokenAllownace[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        success = true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value, "Not sufficient Token");
        tokenAllownace[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        success = true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        remaining = tokenAllownace[_owner][_spender];
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }
    function _mint(address _reciever, uint _amount) public onlyOwner{
        balanceOf[_reciever] += _amount;
    }
    function buyToken() public payable {
        require(msg.value >= 1000, "insifficient Transfer");
        require(totalSupply >= msg.value/1000, "Less tokens Remaining" );
        balanceOf[msg.sender] += msg.value/1000;
        totalSupply -= msg.value/1000;
    }

}
