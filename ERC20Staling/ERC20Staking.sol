// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
// import "contracts/ERC20.sol";
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

contract ERC20Staking {

    uint public startTime;
    uint public endTime;
    uint public rewardRate;
    address public owner;
    // address contractAddress;
    mapping ( address => uint ) public stakedTokens;
    mapping ( address => uint ) public stakedFrom;

    constructor(uint _startTime, uint _endTime, uint _rewardRate) payable{
        require(_endTime > _startTime, "Invalid Time");
        startTime = block.timestamp + _startTime;
        endTime = block.timestamp + _endTime;
        rewardRate = _rewardRate;
        owner = msg.sender;
        // ERC20 erc20 = new ERC20(_totalSupply);
        // contractAddress = address(erc20);
    }

    // function transer(address a)public {
    //      bytes memory data = abi.encodeWithSignature("balanceOf(address)", a);
    //     (bool success, ) = contractAddress.delegatecall(data);
    //     require(success, "failed");
    // }

    function stake(address contractAddress, uint _amount) payable public{
        require(block.timestamp >= startTime, "Staking not started yet");
        require(block.timestamp <= endTime, "Staking Ended");
        require(_amount > 0, "Invalid Amount");
        require(IERC20(contractAddress).balanceOf(msg.sender) >= _amount,"Not enough balance");

        // bytes memory data = abi.encodeWithSignature("transfer(address,uint256)",
        //                     address(this),_amount);
        // (bool success, bytes memory returnedData ) = contractAddress.delegatecall(data);
        // bool a = abi.decode(returnedData, (bool));
        // console.log(a);
        // require(success, "failed");

        bool result = IERC20(contractAddress).transferFrom(msg.sender, address(this), _amount);
        require(result, "failed");

        if (stakedTokens[msg.sender] > 0 ){
           uint reward = ((block.timestamp -  stakedFrom[msg.sender])/ 60) * rewardRate;
            if(reward > 0){
                IERC20(contractAddress).transfer(msg.sender, reward);
            }
        }
        stakedTokens[msg.sender] += _amount;
        stakedFrom[msg.sender] = block.timestamp;

    }

    function claimBack(address contractAddress) public{
        require(block.timestamp > endTime, "Staking still in process");
        require(stakedTokens[msg.sender] > 0, "No tokens Staked");
        uint reward = ((block.timestamp -  stakedFrom[msg.sender])/ 60) * rewardRate * stakedTokens[msg.sender];
        require(reward > 0);
        stakedFrom[msg.sender] = block.timestamp;
        IERC20(contractAddress).transfer(msg.sender, stakedTokens[msg.sender] + reward);
        stakedTokens[msg.sender] = 0;
    }

    function increaseReward(uint _reward) public{
        require(rewardRate < _reward, "Cannot change");
        rewardRate = _reward;
    }


}
