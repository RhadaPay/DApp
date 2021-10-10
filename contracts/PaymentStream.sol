// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.0;

import {ISuperfluid, ISuperToken, ISuperApp, ISuperAgreement, SuperAppDefinitions} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import {SuperAppBase} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract PaymentStream is SuperAppBase {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint8 ratioPct = 100;
    mapping(address => uint256) userScores;
    address[] receivers;
    address _owner; 

    IConstantFlowAgreementV1 private _cfa;
    ISuperfluid private _host;

    ISuperToken _token;
    bytes32 _lastAgreementId;

    //only dao registry should call it
    function setUserScores(address[] memory users, uint256[] memory scores) public {
        require(msg.sender == _owner, "!auth");
        require(users.length == scores.length);
        receivers = users;
        for (uint256 i = 0; i < users.length; i++) {
            userScores[receivers[i]] = scores[i];
        }
    }

    function updatePayments() public {
        require(_lastAgreementId != bytes32(0));
        int96 flowRate;
        uint256 deposit;

        (, flowRate, deposit, ) = _cfa.getFlowByID(_token, _lastAgreementId);
        _updateMultiFlow(_token, flowRate, deposit, new bytes(0));
    }

    constructor(IConstantFlowAgreementV1 cfa, ISuperfluid superfluid, address defaultReceiver) {
        assert(address(cfa) != address(0));
        assert(address(superfluid) != address(0));
        _cfa = cfa;
        _host = superfluid;
        _owner = msg.sender; 

        uint256 configWord = SuperAppDefinitions.APP_LEVEL_FINAL |
            SuperAppDefinitions.BEFORE_AGREEMENT_CREATED_NOOP |
            SuperAppDefinitions.BEFORE_AGREEMENT_UPDATED_NOOP |
            SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP;

        //Default receiver to don't lose funds before the setUserScores
        receivers.push(defaultReceiver);
        userScores[defaultReceiver] = 1;

        _host.registerApp(configWord);
    }

    function _sumProportions() internal view returns (uint256 sum) {
        for (uint256 i = 0; i < receivers.length; i++) {
            sum += userScores[receivers[i]];
        }
    }

    function _updateMultiFlow(
        ISuperToken superToken,
        int96 flowRate,
        uint256 appAllowanceGranted,
        bytes memory ctx
    ) private returns (bytes memory newCtx) {
        uint256 sum = _sumProportions();

        newCtx = ctx;

        // in case of mfa, we underutlize the app allowance for simplicity
        int96 safeFlowRate = _cfa.getMaximumFlowRateFromDeposit(
            superToken,
            appAllowanceGranted - 1
        );
        appAllowanceGranted = _cfa.getDepositRequiredForFlowRate(
            superToken,
            safeFlowRate
        );

        // scale the flow rate and app allowance numbers
        appAllowanceGranted = (appAllowanceGranted * ratioPct) / 100;
        flowRate = (flowRate * ratioPct) / 100;

        for (uint256 i = 0; i < receivers.length; i++) {
            address to = receivers[i];
            uint256 targetAllowance = (appAllowanceGranted * userScores[to]) /
                sum;
            int96 targetFlowRate = _cfa.getMaximumFlowRateFromDeposit(
                superToken,
                targetAllowance
            );
            flowRate -= targetFlowRate;

            newCtx = new bytes(0);
            if (keccak256(ctx) == keccak256(newCtx)) {
                createOrUpdateFlow(superToken, to, targetFlowRate);
            } else {
                newCtx = createOrUpdateFlowWithCtx(
                    superToken,
                    to,
                    targetFlowRate,
                    ctx
                );
            }
        }
        assert(flowRate >= 0);
    }

    function afterAgreementCreated(
        ISuperToken superToken,
        address agreementClass,
        bytes32 agreementId,
        bytes calldata agreementData,
        bytes calldata, /*cbdata*/
        bytes calldata ctx
    ) external override onlyHost returns (bytes memory newCtx) {
        assert(agreementClass == address(_cfa));

        int96 flowRate;
        uint256 deposit;

        _token = superToken;
        _lastAgreementId = agreementId;

        (, flowRate, deposit, ) = _cfa.getFlowByID(superToken, agreementId);
        newCtx = _updateMultiFlow(superToken, flowRate, deposit, ctx);
    }

    function beforeAgreementUpdated(
        ISuperToken superToken,
        address agreementClass,
        bytes32 agreementId,
        bytes calldata, /*agreementData*/
        bytes calldata /*ctx*/
    ) external view override onlyHost returns (bytes memory cbdata) {
        assert(agreementClass == address(_cfa));
        (, int256 oldFlowRate, , ) = _cfa.getFlowByID(superToken, agreementId);
        return abi.encode(oldFlowRate);
    }

    function afterAgreementUpdated(
        ISuperToken superToken,
        address agreementClass,
        bytes32 agreementId,
        bytes calldata agreementData,
        bytes calldata, /* cbdata */
        bytes calldata ctx
    ) external override onlyHost returns (bytes memory newCtx) {
        assert(agreementClass == address(_cfa));
        int96 flowRate;
        uint256 deposit;

        _token = superToken;
        _lastAgreementId = agreementId;
        (, flowRate, deposit, ) = _cfa.getFlowByID(superToken, agreementId);
        newCtx = _updateMultiFlow(superToken, flowRate, deposit, ctx);
    }

    function afterAgreementTerminated(
        ISuperToken superToken,
        address agreementClass,
        bytes32 agreementId,
        bytes calldata agreementData,
        bytes calldata, /*cbdata*/
        bytes calldata ctx
    ) external override onlyHost returns (bytes memory newCtx) {
        assert(agreementClass == address(_cfa));

        _token = superToken;
        _lastAgreementId = agreementId;
        int96 flowRate;
        uint256 deposit;

        (, flowRate, deposit, ) = _cfa.getFlowByID(superToken, agreementId);
        newCtx = _updateMultiFlow(superToken, flowRate, deposit, ctx);
    }

    modifier onlyHost() {
        assert(msg.sender == address(_host));
        _;
    }

    /**************************************************************************
     * Utility methods for Superfluid
     *************************************************************************/
    function createOrUpdateFlowWithCtx(
        ISuperToken superToken,
        address to,
        int96 targetFlowRate,
        bytes memory ctx
    ) internal returns (bytes memory newCtx) {
        (, int96 outFlowRate, , ) = _cfa.getFlow(superToken, address(this), to);

        bytes4 selector;

        if (outFlowRate > 0) {
            selector = _cfa.updateFlow.selector;
        } else {
            selector = _cfa.createFlow.selector;
        }

        if (targetFlowRate == 0) {
            if (outFlowRate > 0) {
                selector = _cfa.deleteFlow.selector;
            } else {
                return ctx;
            }
        }

        bytes memory callData = abi.encodeWithSelector(
            selector,
            superToken,
            to,
            targetFlowRate,
            new bytes(0)
        );
        (newCtx, ) = _host.callAgreementWithContext(
            _cfa,
            callData,
            new bytes(0), // user data
            ctx
        );
    }

    function createOrUpdateFlow(
        ISuperToken superToken,
        address to,
        int96 targetFlowRate
    ) internal {
        (, int96 outFlowRate, , ) = _cfa.getFlow(superToken, address(this), to);

        bytes4 selector;

        if (outFlowRate > 0) {
            selector = _cfa.updateFlow.selector;
        } else {
            selector = _cfa.createFlow.selector;
        }

        if (targetFlowRate == 0) {
            if (outFlowRate > 0) {
                selector = _cfa.deleteFlow.selector;
            } else {
                return;
            }
        }

        bytes memory callData = abi.encodeWithSelector(
            selector,
            superToken,
            to,
            targetFlowRate,
            new bytes(0)
        );
        _host.callAgreement(_cfa, callData, "0x");
    }
}

