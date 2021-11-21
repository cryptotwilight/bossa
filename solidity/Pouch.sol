// SPDX-License-Identifier: UNLICENSED 
pragma solidity >=0.8.0 <0.9.0;

import "./IBossaLiquidityPool.sol";
import "./IPouch.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


contract Pouch is IPouch { 
    
    IBossaLiquidityPool liquidityPool; 
    IERC20 erc20;
    
    address payable holder; 
    address creator; 
    
    uint256 targetBalance; 
    uint256 initialBalance; 
    uint256 currentBalance;
    
    uint256 creditTime; 
    uint256 maxTime; 
    
    string invoiceCID;
    
    bool credited; 
    string state; 
    
    address ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; 
    
    constructor(address payable _holder, address _creator, address _liquidityPool){
        holder = _holder; 
        creator = _creator; 
        liquidityPool = IBossaLiquidityPool(_liquidityPool);
        state = "CREATED";
    }
    
    function credit(uint256 _initialBalance, uint256 _targetBalance, uint256 _maxTime, address _erc20, string memory _invoiceCID) override external payable returns (address _pouchAddress){
        require(!credited, "00 - pouch already credited");
        maxTime = _maxTime; 
        initialBalance = _initialBalance; 
        targetBalance = _targetBalance; 
        currentBalance = _initialBalance; 
        erc20 = IERC20(_erc20);
        invoiceCID = _invoiceCID;
        
        if (_erc20 == ETH) {
            liquidityPool.deposit{ value : initialBalance }(initialBalance, address(ETH)); 
        }
        else { 
            erc20.transferFrom(msg.sender, address(this), initialBalance);
            erc20.approve(address(liquidityPool), initialBalance);
            liquidityPool.deposit(initialBalance, address(erc20));
        }
        
        state = "CREDITED";
        return address(this);
    }

    function updateBalance() external returns ( uint256 _currentBalance) {
         currentBalance = liquidityPool.getBalance(address(this));
         return currentBalance; 
    }
    
    function isLiquidationReady() override external view returns (bool isLiquidatable){
        require(!isEqual(state, "LIQUIDATED"), "01 - pouch liquidated");
       
        if (currentBalance >= targetBalance) {
            return true; 
        }
        if(block.timestamp >= maxTime) {
            return true; 
        }
        return false; 
    }
    
    function liquidate() override external returns (bool _isLiquidated){
        liquidityPool.withdraw();
        state = "LIQUIDATED";
        return true; 
    }
    
    function payout() override external returns (uint256 _payoutAmount, uint256 _targetBalance, string memory _invoiceCID){
        // transfer to the holder only 
        if (address(erc20) == ETH) {
            holder.transfer(currentBalance);
        }
        else { 
            erc20.transfer(holder, currentBalance);
        }
    
        _payoutAmount = currentBalance; 
        currentBalance = 0; 
    
        state = "PAID OUT";    
        return (_payoutAmount, targetBalance, _invoiceCID);
    }
    
    function viewContents() override external view returns (uint256 _initialBalance, uint256 _targetBalance, uint256 _currentBalance, uint256 _creditTime, uint256 _maxTime, address _erc20, address _creator, address _holder, string memory _invoiceCID){
        return (initialBalance, targetBalance, currentBalance, creditTime, maxTime, address(erc20), creator, holder, invoiceCID );
    }

    function getHolder() override external view returns(address _holder) {
        return holder; 
    }

    function getState() override external view returns (string memory _state){
        return state; 
    }


    function isEqual(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
}