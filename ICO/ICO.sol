// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "contracts/ERC20.sol";

contract ICO{
    ERC20 public tokenERC20;
    uint public startTime;
    uint public endTime;
    address payable public owner;
    uint public requiredFunds;
    uint public rate = 1000000000000000;
    bool public salestatus = true;


    constructor(uint _tokenAmount, uint _requiredFunds, uint _startTime, uint _endTime){
        require(_tokenAmount > 0, "Invalid Token Amount");
        require(_requiredFunds > 0, "Invalid Target Amount");
        ERC20 token = new ERC20(_tokenAmount);
        tokenERC20 = token;
        owner = payable(msg.sender);
        requiredFunds = _requiredFunds;
        startTime = block.timestamp + _startTime;
        endTime = block.timestamp + _startTime + _endTime;
    }

    function buyToken() public payable {
        require(salestatus && block.timestamp >= startTime && block.timestamp < endTime, "ICO inactive");
        require(msg.value >= rate, "not sufficient funds transfered");
        tokenERC20.transfer(msg.sender, (msg.value/rate));
    }
    function transferToken(address _to, uint _value) public {
        require(block.timestamp >= endTime, "ICO still active");
        require(_value >= 0, "invalid input");
        require(tokenERC20.balanceOf(msg.sender) >= _value, "Not Enough Tokens" );
        tokenERC20.transfer(_to, _value);
    }

    function withdrawOwner() public payable {
        require(address(this).balance >= requiredFunds, "Not Enough Funds to Draw" );
        (bool sent,) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function withdrawDoner() public payable {
        require(block.timestamp >= endTime, "ICO still active");
        require(address(this).balance < requiredFunds, "Cannot withdraw" );
        uint balance = tokenERC20.balanceOf(msg.sender);
        require(balance >= 0, "Not Enough Tokens" );
        tokenERC20.transferFrom(msg.sender, address(this), balance);
        (bool sent,) = msg.sender.call{value: balance * 1000000000000000}("");
        require(sent, "Failed to send Ether");
    }

    function stopSale() external {
        salestatus = false;
    }

    function getSupply() view public returns (uint){
        return tokenERC20.totalSupply();
    }
    function getToeknOwner() view public returns (address){
        return tokenERC20.owner();
    }
     function getBalanceOf(address _owner) public view returns (uint256 balance){
        balance = tokenERC20.balanceOf(_owner);

    }

}
