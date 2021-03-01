// SPDX-License-Identifier: MIT

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

import "./ILighteningTrees.sol";

contract LighteningTrees is ILighteningTrees {
    address public lighteningProxy;

    bytes32[] public deposits;
    uint256 public lastProcessedDepositLeaf;

    bytes32[] public withdrawals;
    uint256 public lastProcessedWithdrawalLeaf;

    event DepositData(
        address instance,
        bytes32 indexed hash,
        uint256 block,
        uint256 index
    );
    event WithdrawalData(
        address instance,
        bytes32 indexed hash,
        uint256 block,
        uint256 index
    );

    struct TreeLeaf {
        address instance;
        bytes32 hash;
        uint256 block;
    }

    modifier onlyLighteningProxy {
        require(msg.sender == lighteningProxy, "Not authorized");
        _;
    }

    constructor(address _lighteningProxy) public {
        lighteningProxy = _lighteningProxy;
    }

    function registerDeposit(address _instance, bytes32 _commitment)
        external
        onlyLighteningProxy
    {
        deposits.push(
            keccak256(abi.encode(_instance, _commitment, blockNumber()))
        );
    }

    function registerWithdrawal(address _instance, bytes32 _nullifier)
        external
        onlyLighteningProxy
    {
        withdrawals.push(
            keccak256(abi.encode(_instance, _nullifier, blockNumber()))
        );
    }

    function getRegisteredDeposits()
        external
        view
        returns (bytes32[] memory _deposits)
    {
        uint256 count = deposits.length - lastProcessedDepositLeaf;
        _deposits = new bytes32[](count);
        for (uint256 i = 0; i < count; i++) {
            _deposits[i] = deposits[lastProcessedDepositLeaf + i];
        }
    }

    function getRegisteredWithdrawals()
        external
        view
        returns (bytes32[] memory _withdrawals)
    {
        uint256 count = withdrawals.length - lastProcessedWithdrawalLeaf;
        _withdrawals = new bytes32[](count);
        for (uint256 i = 0; i < count; i++) {
            _withdrawals[i] = withdrawals[lastProcessedWithdrawalLeaf + i];
        }
    }

    function blockNumber() public view returns (uint256) {
        return block.number;
    }
}
