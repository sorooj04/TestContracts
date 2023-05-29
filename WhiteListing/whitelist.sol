// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "contracts/ERC721.sol";

contract ERC721WhiteList is ERC721{
    bool public _isPublic;
    mapping (address => bool) whiteListed;
    address public owner;

    constructor(){
        owner = msg.sender;
        whiteListed[msg.sender] = true;
        _isPublic = true;
    }
    function toggleIsPublic()public{
        require(msg.sender == owner, "NOT OWNER");
        _isPublic = !(_isPublic);
    }

    function _mint(address to, uint id) external payable {
        if(!_isPublic){
            require(whiteListed[msg.sender] ,"Youre not whitelisted");
        }
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");
        require(msg.value >= 1000, "NOt emough fee");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function whitelistAddress(address _toWhitelist)public{
        require(msg.sender == owner, "Youre not Allowed");
        whiteListed[_toWhitelist] = true;
    }

    function removeWhitelistAddress(address _toWhitelist)public{
        require(msg.sender == owner, "Youre not Allowed");
        delete whiteListed[_toWhitelist];
    }


}
