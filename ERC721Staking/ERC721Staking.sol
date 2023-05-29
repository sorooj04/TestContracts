// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "contracts/interfaces.sol";
import "hardhat/console.sol";

contract ERC721Staking {

    uint public startTime;
    uint public endTime;
    uint public rewardRate;
    uint public rewardTime;
    address public owner;
    address public erc20ContractAddress;
    mapping ( address => uint ) public stakedToken;
    mapping ( address => uint ) public stakedFrom;

    constructor(uint _startTime, uint _endTime, uint _rewardRate, address _erc20ContractAddress, uint _rewardTime) payable{
        require(_endTime > _startTime, "Invalid Time");
        startTime = block.timestamp + _startTime;
        endTime = block.timestamp + _endTime;
        rewardRate = _rewardRate;
        owner = msg.sender;
        rewardTime = 10;//60*60*24;//_rewardTime;
        erc20ContractAddress = _erc20ContractAddress;
    }

    function stake(address contractAddress, uint _id) payable public{
        require(block.timestamp >= startTime, "Staking not started yet");
        require(block.timestamp <= endTime, "Staking Ended");
        require(_id > 0, "Invalid Id");
        require(stakedToken[msg.sender] == 0, "already staked");
        require(IERC721(contractAddress).ownerOf(_id) == msg.sender ||
                IERC721(contractAddress). getApproved(_id) == msg.sender ||
                IERC721(contractAddress).isApprovedForAll(IERC721(contractAddress).ownerOf(_id), msg.sender)
        ,"Not Approved" );

        IERC721(contractAddress).transferFrom(msg.sender, address(this), _id);
        stakedFrom[msg.sender] = block.timestamp;
        stakedToken[msg.sender] = _id;

    }

    function claimBack(address contractAddress) public{
        require(block.timestamp > endTime, "Staking still in process");
        require(stakedToken[msg.sender] > 0, "No token Staked");

        uint reward = ((block.timestamp -  stakedFrom[msg.sender])/ rewardTime) * rewardRate;
        require(reward > 0,"Not Sufficient Time passed to Get Reward");
        uint _stakedToken = stakedToken[msg.sender];
        stakedToken[msg.sender] = 0;
        stakedFrom[msg.sender] = block.timestamp;
        bool result = IERC20(erc20ContractAddress).transfer(msg.sender, reward);
        require(result, "Reward NOt Given");
        IERC721(contractAddress).transferFrom(address(this),msg.sender, _stakedToken);
    }

    function increaseReward(uint _reward) public{
        require(rewardRate < _reward, "Cannot change");
        rewardRate = _reward;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

}
