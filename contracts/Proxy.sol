pragma solidity 0.5.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";

import "./ILighteningInstance.sol";
import "./ILighteningTrees.sol";
import "./ENS.sol";

contract Proxy is EnsResolve {
    using SafeERC20 for IERC20;

    event EncryptedNote(address indexed sender, bytes encryptedNote);

    ILighteningTrees public lighteningTrees;
    address public governance;
    //ILighteningInstance
    mapping(address => bool) public instances;
    modifier onlyGovernance() {
        require(msg.sender == governance, "Not authorized");
        _;
    }

    constructor(
        bytes32 _lighteningTrees,
        bytes32 _governance,
        bytes32[] memory _instances
    ) public {
        lighteningTrees = ITornadoTrees(resolve(_lighteningTrees));
        governance = resolve(_governance);

        for (uint256 i = 0; i < _instances.length; i++) {
            instances[resolve(_instances[i])] = true;
        }
    }

    function deposit(
        ILighteningInstance _lightening,
        bytes32 _commitment,
        bytes calldata _encryptedNote
    ) external payable {
        require(instances[_tornado], "The instance is not supported");

        _lightening.deposit.value(msg.value)(_commitment);
        lighteningTrees.registerDeposit(address(_lightening), _commitment);
        emit EncryptedNote(msg.sender, _encryptedNote);
    }

    function updateInstance(ILighteningInstance _instance, bool _update)
        external
        onlyGovernance
    {
        instances[_instance] = _update;
    }

    function withdraw(
        ILighteningInstance _lightening,
        bytes calldata _proof,
        bytes32 _root,
        bytes32 _nullifierHash,
        address payable _recipient,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund
    ) external payable {
        require(instances[_lightening], "The instance is not supported");

        _lightening.withdraw.value(msg.value)(
            _proof,
            _root,
            _nullifierHash,
            _recipient,
            _relayer,
            _fee,
            _refund
        );
        lighteningTrees.registerWithdrawal(
            address(_lightening),
            _nullifierHash
        );
    }

    /// @dev Method to claim junk and accidentally sent tokens
    function rescueTokens(
        IERC20 _token,
        address payable _to,
        uint256 _balance
    ) external onlyGovernance {
        require(_to != address(0), "TORN: can not send to zero address");

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
            require(balance > 0, "TORN: trying to send 0 balance");
            _token.safeTransfer(_to, balance);
        }
    }
}
