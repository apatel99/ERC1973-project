pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";



//share token  contract

contract ShareToken is ERC20Detailed {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupplyOfShareToken;
    
    mapping (address => uint256) public percentageShareOfToken;
    
    uint256 public percentageTotalOfShare;

    mapping (address => bool) public participantsOfShareToken;
    
    uint256 public totalParticipantsOfShareToken = 0;
    
    address public companyAddress;
    
    constructor(string memory name, string memory symbol, uint8 decimals,uint256 totalSupply) ERC20Detailed(name,symbol,decimals) public {
        _totalSupplyOfShareToken = totalSupply;
        _balances[msg.sender] = _totalSupplyOfShareToken;
        companyAddress = msg.sender;
        
    }


    function totalSupply() public view returns (uint256) {
        return _totalSupplyOfShareToken;
    }
    
     function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

 
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

 
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public onlyCompany returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    modifier onlyCompany(){
        require(msg.sender == companyAddress);
        _;
    }
    
     function mint(address account, uint256 amount) public  returns (bool) {
        _mint(account, amount);
        return true;
    }

  
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        
        
        if(_totalSupplyOfShareToken > 0 && _totalSupplyOfShareToken <=25){
            totalParticipantsOfShareToken = totalParticipantsOfShareToken + 25;
            percentageTotalOfShare = 400;
            //percentageTotalOfShare = percentageTotalOfShare.add(25);
            participantsOfShareToken[recipient] = true;
            
        }else if(_totalSupplyOfShareToken >25 && _totalSupplyOfShareToken <= 50){
            totalParticipantsOfShareToken = totalParticipantsOfShareToken + 25;
            percentageTotalOfShare = 200;
            //percentageTotal = percentageTotal.add(25);
            participantsOfShareToken[recipient] = true;
            
        }else if(_totalSupplyOfShareToken >50 && _totalSupplyOfShareToken <= 75){
            totalParticipantsOfShareToken = totalParticipantsOfShareToken + 25;
            percentageTotalOfShare = 133;
            //percentageTotal = percentageTotal.add(25);
            participantsOfShareToken[recipient] = true;
            
        }else if(_totalSupplyOfShareToken >75 && _totalSupplyOfShareToken <= 100){
            totalParticipantsOfShareToken = totalParticipantsOfShareToken + 25;
            percentageTotalOfShare = 100;
            //percentageTotal = percentageTotal.add(25);
            participantsOfShareToken[recipient] = true;
            
        }else if(_totalSupplyOfShareToken >100 && _totalSupplyOfShareToken <= 125){
            totalParticipantsOfShareToken = totalParticipantsOfShareToken + 25;
            percentageTotalOfShare =80;
            //percentageTotal = percentageTotal.add(25);
            participantsOfShareToken[recipient] = true;
            
        }
       
        emit Transfer(sender, recipient, amount);
    }

       
    function getParticipantState(address _address) public view returns (bool){
        return participantsOfShareToken[_address];
    }
    
    
    function getPercentageShare(address _address) public view returns (uint256){
        return percentageShareOfToken[_address];
    }
    

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        require(account == companyAddress);

        _totalSupplyOfShareToken = _totalSupplyOfShareToken.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    
    function getTotalParticipantOfShareToken() public view returns (uint256){
        return totalParticipantsOfShareToken;
    }
    
    function getTotalPercentageShareToken() public view returns (uint256){
        return percentageTotalOfShare;
    }
}
