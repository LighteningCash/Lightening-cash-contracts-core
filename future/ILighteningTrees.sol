pragma solidity 0.5.17;

interface ILighteningTrees {
    function registerDeposit(address instance, bytes32 commitment) external;

    function registerWithdrawal(address instance, bytes32 nullifier) external;
}
