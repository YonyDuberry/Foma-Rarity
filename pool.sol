// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Guild.sol" ;

contract Pool is FomoKey,Guild {
    using SafeMath for uint ;
    uint public totalPool   ;  //FTM  
    uint public keyPrice = 0.00005 ether ;
    uint public gameStartTime ;
    uint public gameOverTime ;
    uint public humanPool ;  //FTM
    uint private humanPercent = 55;
    mapping (uint=>uint) public summonPool ; //round => money
    uint public round = 1 ;
    uint private summonPercent = 40 ;
    uint public projectPool ; //FTM    
    uint private projectPercent = 5 ;
    uint private addGameTime = 10 ;
    struct buyInfo {
        uint time ;
        uint money ;
        address buyer ;
    }
    buyInfo[] public buyList ;
     
/**  
 * Fundation Pool details   total 5%
   developPercent = 25 ;
   Airdropbuyback = 50 ;
   fundationPercent = 25 ;
*/

/**
 * hold pool details    total 55%
*/
    uint public holdPool ; //FTM
    uint public finalRewardPool ; //FTM
    uint private finalRewardPercent = 30 ; 
    uint private holdPoolPercent = 70 ; 
    
    function _finishGame() private  {
        require(block.timestamp > gameOverTime , "Game not finish");
        uint lastID = buyList.length - 1 ;
        require(buyList[lastID].buyer == msg.sender,"Only winner can do this") ;
        payable(buyList[lastID].buyer).transfer(finalRewardPool);
    }
    
    function withdrawFinalReward() public  {
        _finishGame();
    }
    
    function _addOverTime(uint _ether) internal {
        uint add  = _ether.mul(10).div(1 ether) ;
        if (add == 0) add = 10 ;
        gameOverTime += add ;
        if( (gameOverTime-block.timestamp) > 2 days  ){
            gameOverTime = block.timestamp + 2 days ;
        }
    }

    
    function _distribution(uint _money) internal  {
        holdPool += _money.mul(humanPercent).mul(holdPoolPercent).div(10000) ;
        finalRewardPool += _money.mul(humanPercent).mul(finalRewardPercent).div(10000) ;
        humanPool =  holdPool + finalRewardPool ;
        summonPool[round]  += _money.mul(summonPercent).div(100) ;
        projectPool += _money.mul(projectPercent).div(100) ; 
        totalPool = humanPool + summonPool[round] ;
    }
    
    function buykey(address _inviter) external payable onlyAirdropFinish  {
        require(msg.value != 0 , "Need to input your FTM"); 
        if(msg.value >= 0.1 ether){
            uint exchangeKey = ((msg.value).mul(1 ether)).div(keyPrice) ;
            emit Transfer(address(this),msg.sender,exchangeKey) ;
            balanceOf[msg.sender] += exchangeKey ; 
            uint addLeaderMoney = 0 ;
            if( _inviter == address(0) ){
                if( belongLeader[msg.sender] != address(0) && leaderStatus[_inviter]==true ){
                    myMemberList[_inviter].push(guidMember(msg.sender,block.timestamp,addLeaderMoney)) ;
                    addLeaderMoney = msg.value - ((msg.value * inviterPercent).div(100)) ;
                    _rewardGuidLeader(addLeaderMoney , _inviter ) ;
                    balanceOf[msg.sender] += exchangeKey.mul(10).div(100) ;
                }
            }
            else {
                if ( leaderStatus[_inviter] == true ){
                    addLeaderMoney = msg.value - (msg.value * inviterPercent).div(100) ;
                    _rewardGuidLeader(addLeaderMoney , _inviter ) ;
                    myMemberList[_inviter].push(guidMember(msg.sender,block.timestamp,addLeaderMoney)) ;
                    belongLeader[msg.sender] = _inviter ;
                    balanceOf[msg.sender] += exchangeKey.mul(10).div(100) ;
                }
            }
            buyList.push(buyInfo(block.timestamp,msg.value,msg.sender)) ;
            _addOverTime(msg.value) ;
            uint addPoolMoney  = msg.value - addLeaderMoney ;
            nextPrice();
            _distribution(addPoolMoney) ;
        }
    }
    
    function viewLastBuy() public view returns (uint id ,address buyer, uint time ,uint money){
        id = buyList.length - 1 ;
        return(id,buyList[id].buyer,buyList[id].time,buyList[id].money);
    }
    
    function _rewardGuidLeader(uint _addMoney , address _inviter ) internal  {
        balanceGuild[_inviter] += _addMoney ; //FTM
    }

    function nextPrice() private  {
        keyPrice = ((totalPool * 1 ether).div(10000000)).div(1 ether) ; 
    }
    
    function adminWithdraw(uint _amount)public payable onlyAdmin {
        require(projectPool > _amount , "admin only can withdraw the profit of project");
        payable(admin).transfer(_amount) ;
        projectPool -= _amount ;
    }

    function viewTotalPool() external view returns(uint){
        return totalPool ;
    }
    

   
}