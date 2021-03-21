pragma solidity 0.5.17;
import "./pancake/IPancakeRouter.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMasterChef {
    function updatePendingRewards() external;
}

//contract owner should be transferred to a time lock or multisig wallet
contract Treasury is Ownable {
    IPancakeRouter public router;
    mapping(address => address[]) public path;
    address public wrapNative;
    address public operator;
    IERC20 public lic;
    IMasterChef public masterchef;
    bool public _initialize = false;

    modifier onlyOperator() {
        require(msg.sender == operator, "!operator");
        _;
    }

    modifier onlyOperatorOrOwner() {
        require(msg.sender == operator || msg.sender == owner(), "!operator");
        _;
    }

    function initialize(
        address _operator
    ) public {
        require(!_initialize);
        _initialize = true;
        operator = _operator;
    }

    function setTokens(
        address _router,
        address _lic,
        address _masterchef) public onlyOwner {
        router = IPancakeRouter(_router);
        wrapNative = router.WETH();
        lic = IERC20(_lic);
        masterchef = IMasterChef(_masterchef);
    }

    function setSwapPath(address _token, address[] memory _path)
        public
        onlyOperatorOrOwner
    {
        require(_path.length > 1 && _path[_path.length - 1] == address(lic), "!failed");
        path[_token] = _path;
    }

    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }

    function setMasterchef(address _chef) external onlyOwner {
        masterchef = IMasterChef(_chef);
    }

    function buybackLIC(address _token) public onlyOperatorOrOwner {
        //buy LIC with all funds of the _token
        if (_token == address(1) || _token == address(0)) {
            router.swapExactETHForTokens.value(address(this).balance)(
                0,
                path[_token],
                address(this),
                block.timestamp + 100
            );
        } else {
            IERC20(_token).approve(address(router), uint256(-1));
            router.swapExactTokensForTokens(
                IERC20(_token).balanceOf(address(this)),
                0,
                path[_token],
                address(this),
                block.timestamp + 100
            );
        }
        forwardLICToPool();
    }

    function rescueFunds(address _token) external onlyOwner {
        if (_token == address(1) || _token == address(0)) {
            address(uint256(owner())).transfer(address(this).balance);
        } else {
            IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this)));
        }
    }
    function forwardLICToPool() public {
        lic.transfer(address(masterchef), lic.balanceOf(address(this)));
        masterchef.updatePendingRewards();
    }

    function() external payable {}
}
