pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

import "./lib/DydxFlashloanBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DydxFlashloaner is DydxFlashloanBase {
    address WETHAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address dydxAddr = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;

    address kovanDydxSoloMarginAddr = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;
    address kovanWETHAddr = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;

    struct MyCustomData {
        address token;
        uint256 repayAmount;
    }

    // _solo  = dydxAddr
    // _token = WETHAddr
    // _amount 借贷数量
    function initiateFlashLoan(address _solo, address _token, uint256 _amount)
        external
    {
        ISoloMargin solo = ISoloMargin(_solo);

        // Get marketId from token address
        uint256 marketId = _getMarketIdFromTokenAddress(_solo, _token);

        // Calculate repay amount (_amount + (2 wei))
        // Approve transfer from
        uint256 repayAmount = _getRepaymentAmountInternal(_amount);
        IERC20(_token).approve(_solo, repayAmount);

        // 1. Withdraw $
        // 2. Call callFunction(...)
        // 3. Deposit back $
        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, _amount);
        operations[1] = _getCallAction(
            // Encode MyCustomData for callFunction
            abi.encode(MyCustomData({token: _token, repayAmount: repayAmount}))
        );
        operations[2] = _getDepositAction(marketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        solo.operate(accountInfos, operations);
    }
}
