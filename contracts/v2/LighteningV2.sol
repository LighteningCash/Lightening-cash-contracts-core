pragma solidity 0.5.17;

import "../MerkleTreeWithHistory.sol";
import "../IVerifier.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract LighteningV2 is MerkleTreeWithHistory, ReentrancyGuard {
    uint256 public denomination;
    mapping(bytes32 => bool) public nullifierHashes;
    // we store all commitments just to prevent accidental deposits with the same commitment
    mapping(bytes32 => bool) public commitments;
    IVerifier public verifier;
    address payable public treasury;

    uint256 public feeX10000 = 5;
    uint256 public withdrawFeeX10000 = 10;

    // operator can update snark verification key
    // after the final trusted setup ceremony operator rights are supposed to be transferred to zero address
    address public operator;
    modifier onlyOperator {
        require(
            msg.sender == operator,
            "Only operator can call this function."
        );
        _;
    }

    event Deposit(
        bytes32 indexed commitment,
        uint32 leafIndex,
        uint256 timestamp
    );
    event Withdrawal(
        address to,
        bytes32 nullifierHash,
        address indexed relayer,
        uint256 fee
    );

    /**
    @dev The constructor
    @param _verifier the address of SNARK verifier for this contract
    @param _denomination transfer amount for each deposit
    @param _merkleTreeHeight the height of deposits' Merkle Tree
    @param _operator operator address (see operator comment above)
  */
    constructor(
        IVerifier _verifier,
        uint256 _denomination,
        uint32 _merkleTreeHeight,
        address _operator,
        address payable _treasury
    ) public MerkleTreeWithHistory(_merkleTreeHeight) {
        require(_denomination > 0, "denomination should be greater than 0");
        verifier = _verifier;
        operator = _operator;
        denomination = _denomination;
        treasury = _treasury;
    }

    /**
    @dev Deposit funds into the contract. The caller must send (for ETH) or approve (for ERC20) value equal to or `denomination` of this instance.
    @param _commitment the note commitment, which is PedersenHash(nullifier + secret)
  */
    function deposit(bytes32 _commitment) external payable nonReentrant {
        require(!commitments[_commitment], "The commitment has been submitted");

        uint32 insertedIndex = _insert(_commitment);
        commitments[_commitment] = true;
        _processDeposit();

        emit Deposit(_commitment, insertedIndex, block.timestamp);
    }

    /** @dev this function is defined in a child contract */
    function _processDeposit() internal;

    /**
    @dev Withdraw a deposit from the contract. `proof` is a zkSNARK proof data, and input is an array of circuit public inputs
    `input` array consists of:
      - merkle root of all deposits in the contract
      - hash of unique deposit nullifier to prevent double spends
      - the recipient of funds
      - optional fee that goes to the transaction sender (usually a relay)
  */
    function withdraw(
        bytes calldata _proof,
        bytes32 _root,
        bytes32 _nullifierHash,
        address payable[2] calldata _recipientAndSender,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund,
        uint256 _extraInfoHash,
        uint256 _recipientForProof
    ) external payable nonReentrant {
        require(_fee <= denomination, "Fee exceeds transfer value");
        require(msg.sender == _recipientAndSender[1], "!Invalid sender");
        require(
            !nullifierHashes[_nullifierHash],
            "The note has been already spent"
        );
        require(isKnownRoot(_root), "Cannot find your merkle root"); // Make sure to use a recent one
        bytes32 h = keccak256(abi.encode(_recipientAndSender[0], _extraInfoHash, _recipientAndSender[1]));
        require(_recipientForProof == uint256(address(uint160(uint256(h)))), "invalid proof hash");
        require(
            verifier.verifyProof(
                _proof,
                [
                    uint256(_root),
                    uint256(_nullifierHash),
                    _recipientForProof,
                    uint256(_relayer),
                    _fee,
                    _refund
                ]
            ),
            "Invalid withdraw proof"
        );

        nullifierHashes[_nullifierHash] = true;
        _processWithdraw(_recipientAndSender[0], _relayer, _fee, _refund);
        emit Withdrawal(_recipientAndSender[0], _nullifierHash, _relayer, _fee);
    }

    function computeRecipient(address _recipient, uint256 _extraInfoHash, address _sender) external view returns (uint256) {
        //return uint256(address(uint160(uint256(h))));
        return uint256(address(uint160(uint256(keccak256(abi.encode(_recipient, _extraInfoHash, _sender))))));
    }

    function computeEncodePacked(address _recipient, uint256 _extraInfoHash, address _sender) external view returns (bytes memory) {
        //return uint256(address(uint160(uint256(h))));
        return abi.encode(_recipient, _extraInfoHash, _sender);
    }

    /** @dev this function is defined in a child contract */
    function _processWithdraw(
        address payable _recipient,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund
    ) internal;

    /** @dev whether a note is already spent */
    function isSpent(bytes32 _nullifierHash) public view returns (bool) {
        return nullifierHashes[_nullifierHash];
    }

    /** @dev whether an array of notes is already spent */
    function isSpentArray(bytes32[] calldata _nullifierHashes)
        external
        view
        returns (bool[] memory spent)
    {
        spent = new bool[](_nullifierHashes.length);
        for (uint256 i = 0; i < _nullifierHashes.length; i++) {
            if (isSpent(_nullifierHashes[i])) {
                spent[i] = true;
            }
        }
    }

    /**
    @dev allow operator to update SNARK verification keys. This is needed to update keys after the final trusted setup ceremony is held.
    After that operator rights are supposed to be transferred to zero address
  */
    function updateVerifier(address _newVerifier) external onlyOperator {
        verifier = IVerifier(_newVerifier);
    }

    /** @dev operator can change his address */
    function changeOperator(address _newOperator) external onlyOperator {
        operator = _newOperator;
    }

    function updateTreasury(address payable _treasury) external  onlyOperator {
        treasury = _treasury;
    }
}