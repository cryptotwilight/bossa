// SPDX-License-Identifier: UNLICENSED 
pragma solidity 0.6.12;


interface IBossaLiquidityPool {
    
    function getErc20Address() external view returns (address _erc20);
    
    function getBalance(address _address) external view returns (uint256 _balance);
    
    function deposit( uint256 _amount, address _erc20) external payable returns (uint256 _balance);
    
    function withdraw() external returns (uint256 _withdrawnAmount);
    
}