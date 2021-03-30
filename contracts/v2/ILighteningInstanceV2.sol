pragma solidity 0.5.17;

interface ILighteningInstanceV2 {
    function deposit(bytes32 commitment) external payable;

    function withdraw(
        bytes calldata proof,
        bytes32 root,
        bytes32 nullifierHash,
        address payable[2] calldata recipientAndSender,
        address payable relayer,
        uint256 fee,
        uint256 refund,
        uint256 extraHash,
        uint256 _recipientForProof
    ) external payable;
}
