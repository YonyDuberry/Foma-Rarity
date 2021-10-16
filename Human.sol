// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "./pool.sol" ;

contract Human is Pool   {
    using SafeMath for uint ;
    mapping(address=>bool) private humanOwner ;
    uint private minEther = 0.1 ether ;
    mapping(address=>uint) public myHumanBalance ;
    mapping(address=>uint[]) public myHumanIDs ;
    struct humanInfo {
        uint totalMoney ;
        uint totalKey ;
        uint thisID ;
        uint thisKey ;
        address thisAddress ;
        bool status ;
        uint txTime ;
    }
    uint private addTime = 60 ;
    humanInfo[] public humanList ;
    mapping(address => mapping(uint => bool)) public lotteryStatus ;
    
    // function _rightNumber() internal view returns (bool){
    //     uint randNum = addmod(uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty))), uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))), 100) ;
    //     if(randNum == 11 || randNum == 22 || randNum == 33 || randNum == 44 || randNum == 55){
    //         return true ;
    //     }else{
    //         return false ;
    //     }
    // }
    
    // function startAllGame() public onlyAdmin  {
    //     gameStartTime = block.timestamp ;
    //     gameOverTime = block.timestamp + 2 days ;
    // }
    
    function keyJoinHuman(uint _amount )external onlyAirdropFinish returns(uint _thisID ){  // onlyGameStart onlyAirdropFinish 
        require(_amount >= 10 ether , 'not enough key to join human') ;
        transfer(address(this),_amount) ;
        myHumanBalance[msg.sender] += _amount ; 
        if (!humanOwner[msg.sender]) humanOwner[msg.sender] = true ;
        uint totalKey  ;
        if(humanList.length > 0){
            uint lastID = humanList.length - 1 ;
            totalKey = humanList[lastID].totalKey + _amount ;
        }else{
            totalKey = _amount ;
        }
        uint totalMoney = holdPool ;
        uint thisID = humanList.length ;
        uint thisKey = _amount ;
        address thisAddress = msg.sender ;
        humanList.push(humanInfo(totalMoney,totalKey,thisID,thisKey,thisAddress,true,block.timestamp)) ;
        myHumanIDs[msg.sender].push(thisID) ;
        return (thisID);
    }
    

    function withdrawMyHuman(uint _id) external onlyHumanOwner {
        (,,uint reward,bool status) = _viewMyHumanReward(_id) ;
        require(humanList[_id].thisAddress == msg.sender,"The money is not yours...");
        require(status,"You have withdrawed before");
        payable(msg.sender).transfer(reward) ;
        humanList[_id].status = false ;
        myHumanBalance[msg.sender] -= humanList[_id].thisKey ;
        if(myHumanIDs[msg.sender].length < 2) humanOwner[msg.sender] == false ;
    }
    
    function _viewMyHumanReward(uint _id) public onlyHumanOwner view returns (uint mykey ,uint increase,uint reward,bool status)  {
        uint lastID = humanList.length - 1 ;
        increase = humanList[lastID].totalMoney - humanList[_id].totalMoney ;
        uint percent = (humanList[_id].thisKey * 10000 ether ).div(humanList[lastID].totalKey) ;
        reward = (increase.mul(percent)).div(10000 ether)  ;
        status = humanList[_id].status ;
        mykey = humanList[_id].thisKey ;
        return(mykey ,increase ,reward,status) ;
    }
    
    function viewMyHoldReward() internal view returns (uint){
        uint reward = SafeMath.div(holdPool * myHumanBalance[msg.sender],holdPool) ;
        return reward ;
    }
    
    function _viewHumanInfo() public view returns(uint  last , address  who , uint  txTime ,uint  money){
        last = humanList.length - 1 ;
        return (last,humanList[last].thisAddress,humanList[last].txTime,finalRewardPool);
    }
    
    function viewMyholdIDs(address _adr) public view returns(uint){
        return myHumanIDs[_adr].length ;
    }
    
    modifier onlyHumanOwner {
        require(humanOwner[msg.sender] == true , 'You are not human.') ;
        _;
    }
    
    modifier onlyGameStart {
        require(gameOverTime > block.timestamp , "Can not paticipate...Waiting for administrator to restart game");
        _;
    }
    
 
}