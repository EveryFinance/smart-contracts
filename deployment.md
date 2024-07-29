# Smart Contracts Deployment

The smart contracts has to be deployed in this order:
1. FlowTimeProxyAlpha
2. FlowTimeStorageAlpha with this input for its constructor:
  - address(FlowTimeProxyAlpha)
3. TokenAlpha with this input for its constructor:
  - address(FlowTimeStorageAlpha)
4. DepositConfirmationAlpha 
5. WithdrawalConfirmationAlpha 
6. TreasuryAlpha 
7. ManagementAlpha with these inputs for its constructor:
- a manager's address 
- address(TreasuryAlpha)
8. AssetsAlpha 
 - a manager's address 
9. SafeHouseAlpha with these inputs for its constructor:
 - address(AssetsAlpha)
 - a manager's address
10. InvestmentAlpha with these inputs for its constructor:
 - address(AssetsAlpha)
 - address(TokenAlpha)
 - address(ManagementAlpha)
 - address(DepositConfirmationAlpha)
 - address(WithdrawalConfirmationAlpha)

# Smart Contracts Setup

1. FlowTimeStorageAlpha: 
  - Connect FlowTimeStorageAlpha to TokenAlpha, using the function updateToken(address(Token)).

2.  TokenAlpha: 
  - connect TokenAlpha to InvestmenAlpha, using the function updateProxy(address(InvestmenAlpha)).

3. DepositConfirmationAlpha : 
  - connect DepositConfirmationAlpha to InvestmenAlpha, using the function updateProxy(address(InvestmenAlpha)).
  - set the value of maxIndexEvent (e.g. 5) using the function updateMaxIndexEvent(maxIndexEvent).

3. WithdrawalConfirmationAlpha : 
  - connect WithdrawalConfirmationAlpha to InvestmenAlpha, using the function updateProxy(address(InvestmenAlpha)).
  - set the value of maxIndexEvent (e.g. 5) using the function updateMaxIndexEvent(maxIndexEvent).

4. TreasuryAlpha: 
   - assign the role PROXY to InvestmenAlpha, using the function grantRole(PROXY, address(InvestmenAlpha)).

5. InvestmentAlpha:
 - assign the role MANAGER to an manager's address, using the function grantRole(MANAGER, manager).
 - set the value of eventBatchSize (e.g. 10) using the function updateEventBatchSize(eventBatchSize).

6. ManagementAlpha:
 - set model's parameters (all values are with 8 decimal digits). The value of the decimal number is defined on the library FeeMinter and the contract Management by the constant variable SCALING_FACTOR:
  * set maxDepositAmount using the function 
    updateMaxDepositAmount.
  * set maxWithdrawalAmount using the function 
    updateMaxWithdrawalAmount.
  * set depositFeeRate using the function 
    updateDepositFeeRate.
  * set minDepositFee using the function 
    updateMinDepositFee. 
  * set maxDepositFee using the function 
    updateMaxDepositFee. 
  * set managementFeeRate using the function 
    updateManagementFeeRate.
  * set performanceFeeRate using the function 
    updatePerformanceFeeRate. 
  * set slippageTolerance using the function 
    updateSlippageTolerance.      
  * set minDepositAmount using the function 
    updateMinDepositAmount. 
 - set the value of tokenPrice:
   * assign the role ORACLE to an account's address, using the function grantRole(ORACLE, account).
   * set tokenPrice using the function 
    updateTokenPrice.  
    

