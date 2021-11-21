// SPDX-License-Identifier: UNLICENSED 
pragma solidity >=0.8.0 <0.9.0;



interface IPouch { 
    
    function credit(uint256 _amount, uint256 _targetValue, uint256 _maxTime, address _erc20, string memory _invoiceCID) external payable returns (address _pouchAddress);

    function isLiquidationReady() external view returns (bool isLiquidatable);
    
    function liquidate() external returns (bool _isLiquidated);
    
    function payout() external returns (uint256 _payoutAmount, uint256 _targetAmount, string memory _invoiceCID);
    
    function viewContents() external view returns (uint256 _creditAmount, uint256 _targetAmount, uint256 _currentBalance, uint256 _creditTime, uint256 _maxTime, address _erc20, address _creator, address _holder, string memory _invoiceCID);
  
    function getHolder() external view  returns (address _holder);
    
    function getState() external view returns (string memory _state);
}