// SPDX-License-Identifier: MIT

pragma solidity 0.5.17;
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./MerkleTreeWithHistory.sol";
import "./IHasher.sol";

contract OwnableMerkleTree is Ownable, MerkleTreeWithHistory {
    constructor(uint32 _treeLevels, IHasher _hasher)
        public
        MerkleTreeWithHistory(_treeLevels)
    {
        initialize((_hasher));
    }

    function insert(bytes32 _leaf) external onlyOwner returns (uint32 index) {
        return _insert(_leaf);
    }

    function bulkInsert(bytes32[] calldata _leaves) external onlyOwner {
        _bulkInsert(_leaves);
    }
}
