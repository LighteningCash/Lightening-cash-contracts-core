pragma solidity 0.5.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";

import "./ILighteningInstanceV2.sol";
import "../ILighteningTrees.sol";

contract ProxyV2 {
    using SafeERC20 for IERC20;

    event EncryptedNote(address indexed sender, bytes encryptedNote);

    ILighteningTrees public lighteningTrees;
    address public governance;
    //ILighteningInstance
    mapping(address => bool) public instances;
    bool public _initialize = false;
    modifier onlyGovernance() {
        require(msg.sender == governance, "Not authorized");
        _;
    }

    function initialize(
        address _lighteningTrees,
        address _governance,
        address[] memory _instances
    ) public {
        require(!_initialize);
        _initialize = true;
        lighteningTrees = ILighteningTrees(_lighteningTrees);
        governance = _governance;

        for (uint256 i = 0; i < _instances.length; i++) {
            instances[_instances[i]] = true;
        }
    }

    function deposit(
        ILighteningInstanceV2 _lightening,
        bytes32 _commitment,
        bytes calldata _encryptedNote
    ) external payable {
        require(
            instances[address(_lightening)],
            "The instance is not supported"
        );

        _lightening.deposit.value(msg.value)(_commitment);
        lighteningTrees.registerDeposit(address(_lightening), _commitment);
        emit EncryptedNote(msg.sender, _encryptedNote);
    }

    function updateInstance(ILighteningInstanceV2 _instance, bool _update)
        external
        onlyGovernance
    {
        instances[address(_instance)] = _update;
    }

    function withdraw(
        ILighteningInstanceV2 _lightening,
        bytes calldata _proof,
        bytes32 _root,
        bytes32 _nullifierHash,
        address payable[2] calldata _recipientAndSender,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund,
        uint256 _extraHash
    ) external payable {
        require(
            instances[address(_lightening)],
            "The instance is not supported"
        );
        require(_recipientAndSender[1] == address(this), "!sender to the mixers must be contract itself");
        require(_extraHash == uint256(0x99c3867a6b3606383303ed491e92e68582bbf1849fb98489feccb706fb85b271), "!extra hash must be hash of LIC-WITHDRAW when withdraw from proxy");

        _lightening.withdraw.value(msg.value)(
            _proof,
            _root,
            _nullifierHash,
            _recipientAndSender,
            _relayer,
            _fee,
            _refund,
            _extraHash
        );
        lighteningTrees.registerWithdrawal(
            address(_lightening),
            _nullifierHash
        );
    }

    function privacySwap(
        ILighteningInstanceV2 _lightening,
        bytes calldata _proof,
        bytes32 _root,
        bytes32 _nullifierHash,
        address payable[2] calldata _recipientAndSender,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund,
        uint256 _extraHash,
        address[] calldata path,
        address router
    ) external payable {
        require(
            instances[address(_lightening)],
            "The instance is not supported"
        );
        require(_recipientAndSender[1] == address(this), "!sender to the mixers must be contract itself");
        require(_recipientAndSender[0] == address(this), "!recipient must be contract itself for trading");
        bytes32 expectedExtraDataHash = keccak256(abi.encode(path, router));
        require(uint256(expectedExtraDataHash) == _extraHash, "!invalid data hash");

        _lightening.withdraw.value(msg.value)(
            _proof,
            _root,
            _nullifierHash,
            _recipientAndSender,
            _relayer,
            _fee,
            _refund,
            _extraHash
        );
        lighteningTrees.registerWithdrawal(
            address(_lightening),
            _nullifierHash
        );

        //swap with path and router
    }

    /// @dev Method to claim junk and accidentally sent tokens
    function rescueTokens(
        IERC20 _token,
        address payable _to,
        uint256 _balance
    ) external onlyGovernance {
        require(_to != address(0), "LIC: can not send to zero address");

        if (_token == IERC20(0)) {
            // for Ether
            uint256 totalBalance = address(this).balance;
            uint256 balance = _balance == 0
                ? totalBalance
                : Math.min(totalBalance, _balance);
            _to.transfer(balance);
        } else {
            // any other erc20
            uint256 totalBalance = _token.balanceOf(address(this));
            uint256 balance = _balance == 0
                ? totalBalance
                : Math.min(totalBalance, _balance);
            require(balance > 0, "LIC: trying to send 0 balance");
            _token.safeTransfer(_to, balance);
        }
    }
}
