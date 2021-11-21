// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "./IBLP.sol";

import "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPool.sol";
import "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPoolAddressesProvider.sol";

import "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPoolAddressesProviderRegistry.sol";
import "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/misc/AaveProtocolDataProvider.sol";

import "./IERC20.sol";


contract AaveLiquidityPool is IBossaLiquidityPool {

    uint16 NO_REFERRAL = 0; 

    address administrator; 

    ILendingPoolAddressesProviderRegistry registry; 
    ILendingPoolAddressesProvider addressProvider; 
    AaveProtocolDataProvider dataProvider;     

    struct AaveDeposit{
        ILendingPool pool; 
        IERC20 erc20; 
        address sender; 
    }
    
    mapping(address=>AaveDeposit) depositBySender; 
    

    constructor(address _admin, address _lendingPoolAddressProviderRegistry, address _protocolDataProviderAddress) public {
        administrator = _admin; 
        registry = ILendingPoolAddressesProviderRegistry(_lendingPoolAddressProviderRegistry);
        addressProvider = ILendingPoolAddressesProvider(registry.getAddressesProvidersList()[0]);
        dataProvider = AaveProtocolDataProvider(_protocolDataProviderAddress);
    }

    
    function getErc20Address() override external view returns (address _erc20){
        return address(depositBySender[msg.sender].erc20);
    }
    
    function getBalance(address _address) override external view returns (uint256 _balance){

        (uint256 currentATokenBalance_,
        uint256 currentStableDebt_, 
        uint256 currentVariableDebt_,
        uint256 principalStableDebt_,
        uint256 scaledVariableDebt_,
        uint256 stableBorrowRate_,
        uint256 liquidityRate_, 
        uint40 stableRateLastUpdated_ , 
        bool usageAsCollateralEnabled) = dataProvider.getUserReserveData(this.getErc20Address(),msg.sender);
        return currentATokenBalance_;
    }
    
    
    function deposit( uint256 _amount, address _erc20) override external payable returns (uint256 _balance){
        
        ILendingPool pool_ = ILendingPool(addressProvider.getLendingPool()); 
        
        pool_.deposit(_erc20, _amount, msg.sender, NO_REFERRAL);
        
        AaveDeposit memory deposit_ = AaveDeposit({
            pool : pool_, 
            erc20 : IERC20(_erc20),
            sender : msg.sender 
        });
        
        depositBySender[msg.sender] = deposit_;
        
        return this.getBalance(msg.sender); 
    }
    
    function withdraw() override external returns (uint256 _withdrawnAmount) {
        AaveDeposit memory deposit_ = depositBySender[msg.sender];
        
        ILendingPool pool = deposit_.pool; 
        _withdrawnAmount = this.getBalance(msg.sender);
        pool.withdraw(address(deposit_.erc20),type(uint).max, msg.sender); 
        return _withdrawnAmount; 
    }
    
}