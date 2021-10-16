// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Token.sol" ;

contract Airdrop is FomoKey {
    
    using SafeMath  for uint256 ;
    mapping (address => invitee[] ) public myInvitee;    //inviter address => invitee id => invitee 
    mapping (address => bool ) public getAirdrop;
    uint256 public totalAirdrop = (totalSupply * 2).div(100);
    uint public eachAirdrop = totalAirdrop.div( 2 * 10000)  ;

    struct invitee {
        address invitee ; 
    }
   
    
    function airdrop(address _inviter) external  {
        if(totalAirdrop > eachAirdrop ){
            require(_inviter != address(0), "ERC20: inviter from the zero address");
            require(msg.sender != address(0) , "ERC20: transfer from the zero address");
            require(msg.sender != _inviter , "ERC20: you can not invite yourself");
            require(!getAirdrop[msg.sender], "You have already get the Airdrop token");
            myInvitee[_inviter].push(invitee(msg.sender)) ;
            uint len = myInvitee[_inviter].length ;
            if(len > 5 ){
                balanceOf[msg.sender] +=  eachAirdrop ;
                getAirdrop[msg.sender] = true ;
                emit Transfer(address(this),msg.sender,eachAirdrop) ;
                totalAirdrop = totalAirdrop - eachAirdrop  ;
            }else{
                balanceOf[msg.sender] +=  eachAirdrop ;
                balanceOf[_inviter] += eachAirdrop ;
                getAirdrop[msg.sender] = true ;
                emit Transfer(address(this),msg.sender,eachAirdrop) ;
                emit Transfer(address(this),_inviter,eachAirdrop) ;
                totalAirdrop -=  eachAirdrop.mul(2) ;
            }
            _autoReduce();
        }
    }
    
    function myInviteeNum(address _inviter) public view returns (uint num){
        return myInvitee[_inviter].length ;
    }
    
    function _autoReduce() internal {
        eachAirdrop  = eachAirdrop - 5 ether ;
    }
    
    
    modifier onlyAirdropFinish {
        require(block.timestamp > airdropOverTime , "Airdrop is not Finish.") ;
        require(airdropOverTime != 0 , "Airdrop is not Start.") ;
        _;
    }
    
    
}