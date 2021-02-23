pragma solidity 0.5.17;
import "./pancake/IUniswapV2Router.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMasterChef {
    function updatePendingRewards() external;
}

contract Treasury is Ownable {
    IUniswapV2Router public router;
    mapping(address => address[]) public path;
    address public wrapNative;
    IERC20 public lic;
    IMasterChef public masterchef;

    constructor(
        address _router,
        address _lic,
        address _masterchef
    ) public {
        router = IUniswapV2Router(_router);
        wrapNative = router.WETH();
        lic = IERC20(_lic);
        masterchef = IMasterChef(_masterchef);
    }

    function setSwapPath(address _token, address[] memory _path)
        public
        onlyOwner
    {
        require(_path.length > 1 && _path[_path.length - 1] == address(lic));
        path[_token] = _path;
    }

    function buybackLIC(address _token) public onlyOwner {
        //buy LIC with all funds of the _token
        if (_token == address(0)) {
            router.swapExactETHForTokens.value(address(this).balance)(
                0,
                path[address(0)],
                address(this),
                block.timestamp + 100
            );
        } else {
            router.swapExactTokensForETH(
                IERC20(_token).balanceOf(address(this)),
                0,
                path[address(0)],
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
