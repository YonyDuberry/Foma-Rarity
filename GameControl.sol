// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "./Guild.sol" ;
import "./Human.sol" ;
import "./Summon.sol" ;


contract GameControl is Airdrop,Guild,Human,Summon {
    using SafeMath for uint ;
    constructor(address _admin ,string memory _name ,string memory _symbol ){
        admin = _admin ;
        name = _name ;
        symbol = _symbol ;
        airdropStartTime = block.timestamp ;
        airdropOverTime = block.timestamp + 15 days ;
        totalSupply = totalSupply.sub(totalAirdrop) ;
    }
    
    function changeAdmin(address _newAdmin) public onlyAdmin returns(bool){
        admin = _newAdmin ;
        return true ;
    }
    
    function _finishAirdrop() public onlyAdmin {
        require( gameOverTime < 1 ) ;  
        airdropOverTime = block.timestamp ;
        totalAirdrop = 0 ;
        eachAirdrop = 0 ;
        gameStartTime = airdropOverTime ;
        gameOverTime = gameStartTime + 2 days ;
        roundTime[round] = gameStartTime + 4 hours ; 
        _addRoundFormat(round);
        _distribution(500 ether) ;
    }
    
    
    function finishGame()payable public onlyAdmin onlyGameFinish {
        payable(admin).transfer(address(this).balance) ;  //clear contract pool 
    }
    
    
    modifier onlyGameFinish {
        require((gameOverTime + 7 days) < block.timestamp)  ;
        _;
    }
    
    /////////delete/////////
    function _handleNextRound() public {
        roundTime[round] = block.timestamp ;
    }
    
    //////////delete//////////
    function _handleBurnAirdrop() public{
        totalAirdrop = 0 ;
    }
    
    /////////delete//////////
    function _hanleGanmeOver() public{
        gameOverTime = block.timestamp + 120 ;
    }

    
    

}
