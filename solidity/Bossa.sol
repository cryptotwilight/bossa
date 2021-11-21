// SPDX-License-Identifier: UNLICENSED 

pragma solidity >=0.8.0 <0.9.0;

import "./IBossa.sol";
import "./Pouch.sol";
import "./IBossaLiquidityPool.sol";



contract Bossa is IBossa { 
    
    address administrator; 
    IBossaLiquidityPool pool; 
    
    
    Pouch[] globalPouchList; 
    
    mapping(address=>bool) checkPouchStatusByPouchAddress; 
    
    mapping(address=>Pouch[]) pouchListByAddress;
    

    constructor(address _admin, address _liquidityPool) {
        administrator = _admin;
        pool = IBossaLiquidityPool(_liquidityPool);
    }
    
    function getPouchList() override external view returns (address [] memory _pouchList, string [] memory _status, address [] memory _holders){
        Pouch [] memory pouchList_ = pouchListByAddress[msg.sender];
        _pouchList = new address[](pouchList_.length);
        _status = new string[](pouchList_.length);
        _holders = new address[](pouchList_.length);
        for(uint256 x = 0; x < pouchList_.length; x++){
            Pouch pouch = pouchList_[x];
            _pouchList[x] = address(pouch);
            _status[x] =  pouch.getState();
            _holders[x] = pouch.getHolder();
        }
        
        return (_pouchList, _status, _holders);
    }
    
    
    function createPouch(address payable _holder, 
                            
                            uint256 _initialBalance, 
                            uint256 _targetBalance, 
                            uint256 _maxTime, 
                            address _erc20, 
                            string memory _invoiceCID ) override external payable returns (address _pouchAddress){

        Pouch pouch_ = new Pouch(_holder, msg.sender, address(pool));
        
        pouch_.credit(_initialBalance, _targetBalance, _maxTime,_erc20, _invoiceCID);
        
        pouchListByAddress[msg.sender].push(pouch_);
        
        return address(pouch_);
    }
    
    
    function sendPouch(address _pouchAddress) override external returns(bool _sent) {
        Pouch pouch_ = Pouch(_pouchAddress);
        address holder = pouch_.getHolder(); 
        pouchListByAddress[holder].push(pouch_);
        globalPouchList.push(pouch_);
        checkPouchStatusByPouchAddress[_pouchAddress] = true; 
        return true; 
    }
    
    
    function checkPouches() override external returns (uint256 _vestingCount, uint256 _liquidatedCount) {
        for(uint256 x = 0; x < globalPouchList.length; x++){
            Pouch pouch_ = globalPouchList[x];
            if(checkPouchStatusByPouchAddress[address(pouch_)]){
                pouch_.updateBalance(); 
                if(pouch_.isLiquidationReady()){
                    pouch_.liquidate();
                    checkPouchStatusByPouchAddress[address(pouch_)] = false; 
                    _liquidatedCount++;
                }
                else{
                    _vestingCount++;
                }
            }
        }
    }
}