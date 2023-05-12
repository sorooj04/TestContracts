// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Wallet {

    address payable private owner;

    constructor()  {
        owner = payable(msg.sender);
    }

    function viewOwner() external view returns(address) {
        return owner;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    fallback() external payable {
    }
    receive() external payable {
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
     function transferBalance() external onlyOwner {

        (bool sent,) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

}
