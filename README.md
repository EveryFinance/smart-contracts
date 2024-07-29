# OVERVIEW

Transformative.Fi proposes 3 investment products with different risks for investors:

- Alpha with a high risk;
- Beta with a medium risk;
- Gamma with a low risk.

Each investment product is similar to a vault with a yield-bearing token.

To Invest in such a valut (.g. Alpha), an investor has to follow these steps:

1. Depositing the required asset in the contract InvestmentAlpha and mint his DepositProofAlpha ERC721 token.

2. Validating his deposit request by the manager. Then, his DepositProofAlpha token is burned , and his yield-bearing tokens ALPHA are minted based on its price.

The collected funds are invested in different digital assets and Vaults to match the expected return. However, the investor can withdraw his funds at any time. The withdrawal process is the following:

1. Making a Withrawal request by sending the equivalant value in Token ALPHA to the contract InvestmentAlpha, and minting a WithdrawalProofAlpha ERC721 token.

2. Validating the investor's Withdrawal request by the manager. Then, his tokens ALPHA are burned and an equivalent value in asset is received.

## yield-bearing token ALPHA/BETA/GAMMA

The yield-bearing token is implemented in the contract **Token**. It is a transferable ERC20 token.
The contract has two main function mint and burn. Besides, For each investor's account, a holding time is calculated in the contract **HoldTime** and stored in the variable _holdTimes_. This holding time is updated, when new tokens are minted. it consists in calculating an average value:

```
holdTimes[account] = (newToken * block.timestamp + balances[account] * FlowTimes[account]) / (newToken + balances[account])

```

## DepositProof/WithdrawalProof

When the investor makes a deposit or withdrawal request, the manager has to validate latter his request. In this case, the investor should hold an ERC721 token implemented in the contract **Proof**. This NFT is a proof of his deposit / withdrawal request.  
The contract **Proof** has the following main function: _mint_, _burn_,  _increasePendingRequest_, _decreasePendingRequest_ and _validatePendingRequest_ called by the contract **Investment** and used as follows:

- _mint_: This function is called to create a new DepositProof or WithdrawalProof token for an investor. If the later has already one, his request data will be updated. Thus, an investor can hold at most one DepositProof/ WithdrawalProof at the same time.

The data stored in the token **Proof** is the struct PendingRequest for each token Id.

- _burn_: This function is called to burn an existing DepositProof or WithdrawalProof token for an investor, when the manager fully validates his request.

- _increasePendingRequest_: this function is called when the investor makes a new request (deposit or withdraw) to increase his pending amount.
- _decreasePendingRequest_: this function is called when the investor cancels fully or partially his request (deposit or withdraw) to decrease his pending amount.
- _validatePendingRequest_: this function is called when the manager validates fully or partially the investor's request (deposit or withdraw) to decrease his pending amount.

## Management

The different management parameters are defined in the contract **Management**. One can classify those paramters as follows:

- Deposit Request Parameters: to manage the investor's deposit requests, we define:

  - _minDepositAmount_ : minimum asset amount per deposit request.

  - _minDepositFee_ : minimum deposit Fee to pay per deposit request.

  - _maxDepositFee_ : maximum deposit Fee to pay per deposit request.

  - _depositFeeRate_ : deposit Fee rate to determine the deposit fee based on the deposit asset amount .

  The deposit Fee is calculated as :

  ```
    depositFee  = Min(Max(depositFeeRate * amount,  minDepositFee), maxDepositFee)

  ```

  where _amount_ is the deposit amount in asset and _depositFee_ is the deposit fee amount in asset.

  - _isDepositCancel_ : Boolean variable to activate/deactivate the option of deposit request canceling for investors.

- Withdrawal Request Parameters: to manage the investor's withdrawal requests, we define:

  - _witdrawalFee_ : an array that defines a fee rate for a specific token holding time period. Each element of that array is a struct _Fee_ composed of _feeRate_ and _time_.

  for an investor the withdrawal fee is calculated as a function of its withdrawal fee rate and its token amount to withdraw.

  The function _calculateWithdrawalFeeRate_ determine the withdrawal fee rate based on the _holdTime_ variable as follows:

  let's _account_ be the investor's address , so his holdTime is _holdTimes[account]_.

  let's _n_ be the size of the array witdrawalFee.

  we distinguish three cases:

  1.  if `holdTimes[account] < witdrawalFee[1].Time`, then `withdrawlFeeRate = Fee_1.feeRate`

  2.  if `witdrawalFee[i].Time <= holdTimes[account] < witdrawalFee[i+1].Time`, then `withdrawlFeeRate = Fee_i.feeRate`

  3.  if `holdTimes[account] >= witdrawalFee[n].Time`, then `withdrawlFeeRate = 0`

  Then the withdrawal Fee in Token is calculated as:

  ```
  withdrawalFee = withdrawlFeeRate * amount

  ```

  where _amount_ is the withdrawal amount in token.

  - _isWithdrawalCancel_ : Boolean variable to activate/deactivate the option of withdrawal request canceling for investors.

- Management Fee : is a global fee over all investors. It is based on:

  - _managementFeeTime_ : the last updated time of the management fee. Its initial value is set to the time at which the manager validates the first deposit request.
  - _managementFeeRate_ : the management fee rate ( annual fee rate).

  The management fee is calculated as:

```
  managementFee  = (block.timestamp - managementFeeTime) * totalSupply *managementFeeRate / SECONDES_PER_YEAR

```

where totalSupply is the total supply of the vault's token.
The management fee is calculated by the _manager_ and minted in _Token_.

- Performance Fee : is a global fee on the performance of all investors. It is based on:

  - _tokenPrice_ : the current token price
  - _tokenPriceMean_: the average token price. It is updated when new tokens are minted. The update formula is:

  ```
  tokenPriceMean = (totalSupply * tokenPriceMean + amountToMint * tokenPrice) / (totalSupply + amountToMint)

  ```

  - _performanceFeeRate_: the performance fee rate
    (annual fee rate)

Then, the performance fee is calculated as follows:

```
 performanceFee  = (tokenPrice > tokenPriceMean) * (tokenPrice - tokenPriceMean) *  totalSupply * performanceFeeRate  / SECONDES_PER_YEAR

```

The performance fee is calculated by the _manager_ and minted in _Token_.

## Investment

The contract _Investment_ allows two processes: the investor's process and the manager's process. The general process works by cycles (events): investors make deposit and withdrawal requests at any time. However, the manager validates the investor's requests periodically. Each manger's validation cycle is called _event_.

### investor's process

The investor can interact with the smart contract _Investment_ to:

- Make a deposit request _depositRequest_ : for each investment product, the admin of the contract _Investment_ specifies the vault's asset. This asset can be an ERC20 token or the blockchain native token (e.g. ETH, BNB, ...). The investor makes a deposit request with asset'amount _amount_. The deposit fee is calculated and sent to _treasury_ and the rest of _amountAfterFee_ is sent to _Investment_ contract. If the investor can create a new _DepositProof_ token for his new deposit request or use /update an  existed depositProof token  to add the new invested amount _amountAfterFee_. 

- Cancel a deposit request _cancelDepositRequest_: the investor can cancel a partial or a full amount of his pending deposit request . However, he can't cancel an amount on processing by the manager. For that, the variable _eventId_ is introduced which is increased when a manager validation event starts. If the current value of _eventId_ is _i_, then the investor can cancel only the amount deposited from event _i_ partially or fully. In this case, the contract _Investment_ send the canceled amount in asset to the investor , and his struct _pendingRequest_ amount is updated in the contract _DepositProof_. When his _pendingRequest_ amount decreases to zero, his _DepositConfirmation_ token is burned.

- Make a withdrawal request _withdrawalRequest_: The investor makes a withdrawal request with Token amount _amount_. He deposits the vault's token (ALPHA/BETA/GAMMA) to receive later, when the manager validates his request, the corresponding amount in asset. A Withdrawl fee is calculated based on _amount_ and the Token _holdTime_ of the investor as explained before . The Withdrawal fee is sent to _treasury_ and the rest _amountAfterFee_ is sent to the contract _Investment_. The investor can choose to create a new withdrawal request for his new withdrawal request , or to use / update  an existed _WithdrawalProof_ token to add the new withdrawal amount _amountAfterFee_. 

- Cancel a withdrawal request _cancelWithdrawalRequest_: the investor can cancel a partial or a full amount of his pending withdrawal request. However, he can't cancel an amount on processing by the manager. If the current value of _eventId_ is _i_, then the investor can cancel only the amount withdrew from event _i_ partially or fully. In this case, the contract _Investment_ send the cancled amount in Token to the investor, and his _pendingRequest_ amount is updated in the contract _WithdrawalProof_. When his _pendingRequest_ amount decreases to zero, his _WithdrawalProof_ token is burned.

### manager's process

The manager' process consists of different steps:

1. Update the Token price: The collected funds from investors on different blockchains for the same investment product are invested in different assets and Vaults. Then, the token price is calculated as:

```
  tokenPrice  = total current value of assets and vauls / totalSupply.

```

where totalSupply is the total supply of Token over the different blockchains.

For the moment the calculation of the token price is centralized by Transformative.Fi and is done offchain. In the future, _Chainlink_ solution will be used to calculate the token price and update its value. For that , the role _ORACLE_ is introduced in the contract _Management_ to update the token price _updateTokenPrice_

2. Mint performance and management fee using from the contract _Investment_ the functions: _mintPerformanceFee_ and _mintManagementFee_.

3. update again the token price as the _totalSupply_ of Token is increased after minting the fee.
4. Increase the currentEventId.

5. Calculate offchain _netDepositInd_ and _netAmountEvent_:

- _netDepositInd_: is a boolean variable equal to _1_ if _totalDepositAmount_ is higher than the _totalWithdrawalAmount_, _0_ otherwise.

_netAmountEvent_: is the net deposit amount in the case _netDepositInd = 1_, or net withdrawal amount in the case _netDepositInd = 0_

The calculation of the _netAmountEvent_ is as follows:

- calculate _totalDepositAmountToValidate_ : The maximum deposit amount (in asset) to be validated by the manager over investors for the current event:

```
 totalDepositAmountToValidate  = Min(totalDepositAmount, maxDepositAmount).

```

where _maxDepositAmount_ is an upper limit (in asset).

- calculate _totalWithdrawalAmountToValidate_ : The maximum withdrawal amount (in asset) to be validated by the manager over investors for the current event:

```
 totalWithdrawalAmountToValidate  = Min(totalWithdrawalAmount * tokenPrice , maxWithdrawalAmount).

```

where _maxWithdrawalAmount_ is an upper limit (in asset)_.

- calculate the _netAmountEvent_ as follows:

```
 netAmountEvent = netDepositInd * (totalDepositAmountToValidate - totalWithdrawalAmountToValidate) + (1- netDepositInd) * (totalWithdrawalAmountToValidate - totalDepositAmountToValidate)

```

6.  validate investor's deposit requests _validateDeposits_: The manager validates the investor's deposits requests (First In First Out). He validates _depositAmountToValidate_ (in asset) over all ivestors.

The validation of an investor's deposit request consists to minting him the equivalent of his invested amount in Token, and so to decreasing his _pendingRequest_ amount by this validated amount in the contract _DepositProof_. His token _DepositProof_ is burned when _pendingRequest_ amount become zero.

7. validate investor's withdrawal requests _validateWithdrawals_: The manager validates the investor's withdrawal requests proportionally to their _pendingRequest_ amount. For each investor, his _withdrawalAmountToValidate_ is calculated as:

```
withdrawalAmountToValidate = min( amount * totalWithdrawalAmountToValidate / totalWithdrawalAmount, amount)

```

where _amount_ is the _pendingRequest_ amount of the investor.

_totalWithdrawalAmountToValidate_ is in Token.

The validation of an investor's withdrawal request consists in sending him the equivalent of his _withdrawalAmountToValidate_ in asset, and so to decreasing his _pendingRequest_ amount by this validated amount in the contract _WithdrawalProof_. His token _WithdrawalProof_ is burned when _pendingRequest_ amount become zero. His Token amount _withdrawalAmountToValidate_ is burned.

8. mint or burn InvestmentFee: In the case of net withdrawal `(netDepositInd = 0)`, the manager has to swap some assets to the vault's asset to generate _netEventAmount_ in asset. The swap transactions could generate a slippage. We distinguish different cases:

- a negative fee  _amount_: In this case, _Treasury_ sends a partial of full amount of _amount_ and mint an equivalent amount in Token.

- a positive fee _amount_: In this case, _Treasury_ receives a partial of full amount of _fee_ and burn an equivalent amount in Token.

## SafeHouse

The **SafeHouse** contract is introduced to add an extra level of security to the protocol.

It aims at holding assets, tracking the manager's investments and controling withdrawas.

The **SafeHouse** contract is connected to the contract **AssetBook**.

The contract **AssetBook** consists in adding and removing assets for the portfolio management to choose to invest.

To add an asset, the admin has to specify, its address, the address of its chainlink AggregatorV3Interface to get its price in USD.

In order to have a more felxible solution for the asset's price, it is possible for an asset to specify and update its price without chainlink. It would be helpful, if the asset is not yet integrated in chainlink, or if there is an issue to continue getting its price from that source.

So, if the chainlink's address for an asset is added, chainlink is used as the only source for its price. Otherwise, the address zero is specified as the oracle's address and an external source has to set the asset's price (manualy by the amdmin or by an external oracle).

Then, the contract **SafeHouse** proposes the following functions:

- _WithdrawAsset_: The manager can withdraw assets from the safeHouse with a total withdrawal capicity:

```
withdrawalCapacity = min(withdrawalCapacity, maxWithdrawalCapacity)

```

where _withdrawalCapacity_ decreases by the asset's value withdrew by the manager. A price tolerance rate is considered when _*withdrawalCapacity*_ is updated:

```
withdrawalCapacity = withdrawalCapacity  - assetValue (1 + PriceToleranceRate)

```

_maxWithdrawalCapacity_ is a max capacity to limit the maximum amount that the manager can withdraw regardless of performance generated by assets.

_withdrawalCapacity_ and \*_maxWithdrawalCapacity_ have the same initial value.

- _depositAsset_: The manager has to send assets to the safeHouse to increase _withdrawalCapacity_ by the asset's values.

- _sendToVault_: The admin can add and remove some vault's addresses. So, the manager can send assets to an allowed vault without updating _withdrawalCapacity_. Indeed, such a vault is controled only by the admin.
