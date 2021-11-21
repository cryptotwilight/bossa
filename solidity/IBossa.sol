// SPDX-License-Identifier: UNLICENSED 
pragma solidity >=0.8.0 <0.9.0;

interface IBossa { 
    
    
    function getPouchList() external returns (address [] memory _pouchList, string [] memory _status, address [] memory _holders);
    
    
    function createPouch(address payable _holder, 
                            
                            uint256 _initialBalance, 
                            uint256 _targetBalance, 
                            uint256 _maxTime, 
                            address _erc20, 
                            string memory _invoiceCID) external payable returns (address _pouchAddress);
    
    
    function sendPouch(address _pouchAddress) external returns(bool _sent);
    
    
    function checkPouches() external returns (uint256 _vestingCount, uint256 _liquidatedCount);
    
    
    
}