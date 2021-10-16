// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "./pool.sol" ;


interface RarityContract {
    function summoner(uint _summoner) external view returns (uint _xp, uint _log, uint _class, uint _level) ;
    function ownerOf(uint256 tokenId) external view returns (address owner);
}


contract Summon is Pool  {
    using SafeMath for uint ;
    address public rarityAddress ;
    RarityContract rarity =  RarityContract(0x62568220D205f316a6cF76Aa61f965ca0A3Fb3E8) ;
    RarityContract IERC721 =  RarityContract(0x62568220D205f316a6cF76Aa61f965ca0A3Fb3E8) ;
    
    mapping(address=>uint) public mySummonBalance ;
    mapping(address=>mapping(uint=>uint)) public mySummonPower ;  //sender => round => power
    mapping(uint => mapping(address => bool)) private battleStatus ;   //round => myaddress=> Joinstatus 
    mapping(address => myBattleInfo[]) public mySummonListID ;  //  myaddress =>round=>class=> JoinIDs
    mapping(uint => uint) public roundTime ;  //round => time
    uint private addTime = 4 hours ; 
    mapping(uint=>mapping(uint=>summonInfo[])) public summonList ;  //round=> class => ID => info
    
    struct summonInfo {
        uint myPower ;
        uint teamPower ;
        uint myKey ;
        uint totalKey ;
        address myAddress ;
        bool status ;
    }
    
    struct myBattleInfo{
        uint myRound ;
        uint myClass ;
        uint myID ;
    }
    
    function _viewMySummonTimes(address _address) public view returns (uint) {
        return mySummonListID[_address].length ; 
    }
    
    function _calWinner(uint _round) public view  returns(uint _class, uint power){
        power = 0 ;
        for(uint i=1; i<12 ;i++ ){
            uint last = summonList[_round][i].length - 1 ;
            if(summonList[_round][i][last].teamPower > power ){
                power = summonList[_round][i][last].teamPower ;
                _class = i ;
            }
        }
        return (_class,power) ;
    }
    
    function withdrawInMyTeamPool(uint8 _round ,uint _class ,uint _id ) external onlyClassWinner(_class,_round) onlyThisRoundFinish(_round) {
        (uint reward,uint percent ,bool status) = _mySummonTeamReward(_round,_class,_id);
        require(summonList[_round][_class][_id].myAddress == msg.sender) ; 
        require(status);
        if(reward > 0 && percent > 0){
            payable(msg.sender).transfer(reward) ;
            summonList[_round][_class][_id].status = false ;
        }
    }
    
    function _mySummonTeamReward (uint8 _round ,uint _class ,uint _id) public view  returns (uint reward,uint percent ,bool status){
        uint lastID = summonList[_round][_class].length - 1 ;
        status = summonList[_round][_class][_id].status ;
        percent = (summonList[_round][_class][_id].myKey.mul(1 ether)).div(summonList[_round][_class][lastID].totalKey) ;
        reward = (summonPool[_round].mul(percent)).div(1 ether) ;
        if(status){
            return ( reward ,percent ,status );
        }else{
            return (0,0,false);
        }
    }
    
    function joinSummon(uint _id , uint _amount) public onlyAirdropFinish onlyRarityOwner(_id) {
        if(block.timestamp > roundTime[round] && block.timestamp < gameOverTime ){
            round++ ;
            roundTime[round] = block.timestamp + 4 hours ;
            _addRoundFormat(round) ;
        }
        (uint class,uint power) =  _calPower(_id,_amount) ;
        transfer(address(this),_amount) ; 
        mySummonBalance[msg.sender] += _amount ;
        mySummonPower[msg.sender][round] += power ; 
        battleStatus[round][msg.sender] = true ;
        uint lastID = summonList[round][class].length - 1 ;
        uint thisID = lastID  + 1  ;
        uint finalPower = summonList[round][class][lastID].teamPower + power ;
        uint totalKey = summonList[round][class][lastID].totalKey + _amount ;
        summonList[round][class].push(summonInfo(power ,finalPower ,_amount,totalKey ,msg.sender,true));
        mySummonListID[msg.sender].push(myBattleInfo(round,class,thisID)) ;
        
    }
    
    function viewTeamInfo(uint _round,uint _class) public view returns (uint people,uint teamPower,uint totalKey){
        people = summonList[_round][_class].length ;
        teamPower = summonList[_round][_class][people-1].teamPower ; 
        totalKey = summonList[_round][_class][people-1].totalKey ; 
        return(people,teamPower,totalKey);
    }
    
    function _addRoundFormat(uint _round) internal {   //internal
        summonList[_round][1].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][2].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][3].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][4].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][5].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][6].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][7].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][8].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][9].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][10].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
        summonList[_round][11].push(summonInfo(0 ,0 ,0,0,address(0),false)) ;
    }
    
    modifier onlyFinishRound{
        require(block.timestamp > roundTime[round] && block.timestamp < gameOverTime) ;
        _;
    }
    
    function _calPower(uint _id,uint _amount) internal view returns (uint class,uint power) {
        uint level ;
        (, , class , level) = rarity.summoner(_id) ;
        uint addLevel = level - 1;
        power = ((_amount.mul(addLevel * 50 )).div(100) + _amount).div(1 ether) ;
        return (class ,power) ;
    }
    
    function _readSummon(uint _id) public view returns (uint xp ,uint log ,uint class , uint level){
       return  rarity.summoner(_id) ;
    }
    
    function _readRarityOwner(uint _id) public view returns(address owner){
        return IERC721.ownerOf(_id);
    }
    
    modifier onlyRarityOwner(uint _id) {
        require(IERC721.ownerOf(_id) == msg.sender,"you are not this summoner owner.") ;
        _;
    }
    
    function viewRarityOwner(uint _id) public view returns(address){
        return IERC721.ownerOf(_id);
    }
    
    modifier onlyInThisBattle(uint8 _round) {
        require(battleStatus[_round][msg.sender]) ;
        _;
    }
    
    modifier onlyClassWinner(uint _class,uint _round){
        (uint Rclass ,) = _calWinner(_round);
        require(_class == Rclass) ;
        _;
    }
    
    modifier onlyThisRoundFinish(uint8 _round){
        require(block.timestamp > roundTime[_round] , "This Round is not finish") ;
        _;
    }
}