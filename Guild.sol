// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./airdrop.sol" ;


// 
contract Guild is Airdrop {
    using SafeMath for uint256 ;
    mapping (address => bool) public leaderStatus ;
    mapping (address => uint) public balanceGuild ;  //FTM
    mapping (address => address) public belongLeader ;   //  member => Leader ;
    mapping (address => guidMember[]) public  myMemberList ;  //owner =>  member ;
    uint public inviterPercent = 50 ;
    uint private guildAmount = 499999 ether ;
    struct guidMember {
        address member ;
        uint date ;
        uint money ;
    }

    function changeGuildAmout(uint _amount) public onlyAdmin {
        guildAmount = _amount ;
    }

    
    function withdrawGuildBalance() payable public onlyGuildLeader {
        require(balanceGuild[msg.sender] > 0 , "You have not enough money to withdraw") ;
        require(msg.sender != address(0) , "You have not enough money to withdraw") ;
        payable(msg.sender).transfer(balanceGuild[msg.sender]);
        balanceGuild[msg.sender] = 0 ;
    }
    
    function joinGuild(uint _amount) public  {
        require(_amount >= guildAmount , "You need to pay enough Meta to Join this .") ;
        transfer(address(this),guildAmount);
        leaderStatus[msg.sender] = true ;
    }
    
    function _guildByAdmin(address _address) onlyAdmin public {
        leaderStatus[_address] = true ;
    }
    
    function vieMemberNum(address _leader) public view returns (uint n) {
        return myMemberList[_leader].length ;
    }
    
    modifier onlyGuildLeader {
        require(leaderStatus[msg.sender],"You are not leader") ;
        _;
    }
    
    
    
    
    
}