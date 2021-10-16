

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "./safemath.sol" ;




contract FomoKey  {
    using SafeMath for uint256 ;

    
    string public name = 'Fomo Rarity';
    string public symbol = 'Meta';
    uint8 public decimals = 18 ;
    uint256 public totalSupply = 100000000000 ether;
    address public admin ;
    uint public airdropStartTime ;
    uint public airdropOverTime ;
    
    mapping (address => uint256) public balanceOf;
    event Transfer(address indexed _from, address indexed _to , uint _amount) ;
    function transfer(address _to , uint _amount) public {
        _transfer(msg.sender,_to,_amount) ;
    }
    
    function _transfer(address _from ,address _to ,uint _amount) internal virtual {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(_from, _to, _amount);
        uint256 senderBalance = balanceOf[msg.sender];
        require(senderBalance >= _amount, "ERC20: transfer amount exceeds balance");
        balanceOf[_from] = senderBalance - _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = balanceOf[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        balanceOf[account] = accountBalance - amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    
    modifier onlyAdmin {
       require(msg.sender == admin,"Only admin can do this" );
       _;
    }
    
}






    

