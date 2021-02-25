pragma solidity 0.5.17;

interface ITornadoTrees {
    function registerDeposit(address instance, bytes32 commitment) external;

    function registerWithdrawal(address instance, bytes32 nullifier) external;
}
