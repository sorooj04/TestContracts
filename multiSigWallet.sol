// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "hardhat/console.sol";

struct Transaction {
    address reciever;
    uint amount;
    bool completed;
    uint approvalsCount;
    mapping(address => bool) approvals;
}

contract MultiSigWallet {

    Transaction[] public transactions;
    address public owner;
    address[] public validators;
    mapping(address => bool) public isValidator;
    uint approvalsRequired;

    constructor(address[] memory _validators, uint _approvalsRequired){
        require(_validators.length > 0,"No owners exist");
        require(_approvalsRequired > 0 && _validators.length >= _approvalsRequired ,"No owners exist");

        owner = msg.sender;
        approvalsRequired = _approvalsRequired;

        for(uint i=0; i < _validators.length; i++){
            require(_validators[i] != address(0), "Wrong Address");
            require(isValidator[_validators[i]] == false, "validator exists twice");
            validators.push(_validators[i]);
            isValidator[_validators[i]] = true;
        }
    }
    receive() external payable {
    }
    fallback() external payable {
    }

    function makeTransaction(address _reciever, uint _amount) external {
            Transaction storage newRequest = transactions.push();
            newRequest.reciever = _reciever;
            newRequest.amount = _amount;
    }
    function returnTransactionByIndex(uint _index) external view returns(address,uint,bool,uint){
        require(_index < transactions.length, "Incorrect index");
        return(transactions[_index].reciever,
            transactions[_index].amount,
            transactions[_index].completed,
            transactions[_index].approvalsCount);
    }

    function validate(uint _index) external{
        require(isValidator[msg.sender], "you cannot validate");
        require(_index < transactions.length, "Incorrect index");
        require(transactions[_index].completed == false, "transaction completed");
        require(transactions[_index].approvals[msg.sender] == false, "already voted");

        transactions[_index].approvals[msg.sender] = true;
        transactions[_index].approvalsCount = transactions[_index].approvalsCount + 1;
    }

    function transactTransaction(uint _index) external {
        require(transactions[_index].approvalsCount >= approvalsRequired, "not enough approvals");
        require(_index < transactions.length, "Incorrect index");
        require(transactions[_index].completed == false, "transaction completed");

        (bool success, ) = transactions[_index].reciever.call{value: transactions[_index].amount}("");
        require(success, "transaction failed");
        transactions[_index].completed = true;
    }


}
