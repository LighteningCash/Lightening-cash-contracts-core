pragma solidity 0.5.17;
import "./pancake/IPancakeRouter.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMasterChef {
    function updatePendingRewards() external;
}

contract Treasury is Ownable {
    IPancakeRouter public router;
    mapping(address => address[]) public path;
    address public wrapNative;
    IERC20 public lic;
    IMasterChef public masterchef;
    bool public _initialize = false;

    function initialize(
        address _router,
        address _lic,
        address _masterchef
    ) public {
        require(!_initialize);
        router = IPancakeRouter(_router);
        wrapNative = router.WETH();
        lic = IERC20(_lic);
        masterchef = IMasterChef(_masterchef);
        _initialize = true;
    }

    function setSwapPath(address _token, address[] memory _path)
        public
        onlyOwner
    {
        require(_path.length > 1 && _path[_path.length - 1] == address(lic), "!failed");
        path[_token] = _path;
    }

    function buybackLIC(address _token) public onlyOwner {
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

    function forwardLICToPool() public {
        lic.transfer(address(masterchef), lic.balanceOf(address(this)));
        masterchef.updatePendingRewards();
    }

    function() external payable {}
}
