pragma solidity 0.5.17;

interface ILighteningInstance {
    function deposit(bytes32 commitment) external payable;

    function withdraw(
        bytes calldata proof,
        bytes32 root,
        bytes32 nullifierHash,
        address payable recipient,
        address payable relayer,
        uint256 fee,
        uint256 refund
    ) external payable;
}
