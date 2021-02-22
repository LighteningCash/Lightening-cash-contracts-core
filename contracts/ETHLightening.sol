pragma solidity 0.5.17;

import "./Lightening.sol";

contract ETHLightening is Lightening {
    constructor(
        IVerifier _verifier,
        uint256 _denomination,
        uint32 _merkleTreeHeight,
        address _operator,
        address payable _treasury
    )
        public
        Lightening(
            _verifier,
            _denomination,
            _merkleTreeHeight,
            _operator,
            _treasury
        )
    {}

    function _processDeposit() internal {
        require(
            msg.value == (denomination * (10000 + feeX10000)) / 10000,
            "Please send `mixDenomination` ETH along with transaction"
        );
        uint256 forTreasury = msg.value - denomination;
        (bool success, ) = treasury.call.value(forTreasury)("");
        require(success, "payment to treasury did not go thru");
    }

    function _processWithdraw(
        address payable _recipient,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund
    ) internal {
        // sanity checks
        require(
            msg.value == 0,
            "Message value is supposed to be zero for ETH instance"
        );
        require(
            _refund == 0,
            "Refund value is supposed to be zero for ETH instance"
        );

        uint256 withdrawFee = ((denomination - _fee) * withdrawFeeX10000) /
            10000;
        (bool success, ) = _recipient.call.value(
            denomination - _fee - withdrawFee
        )("");
        require(success, "payment to _recipient did not go thru");

        (success, ) = treasury.call.value(withdrawFee)("");
        require(success, "payment to treasury did not go thru");
        if (_fee > 0) {
            (success, ) = _relayer.call.value(_fee)("");
            require(success, "payment to _relayer did not go thru");
        }
    }
}
