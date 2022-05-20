// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts@4.5.0/security/Pausable.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";

contract CryptoCurrencyNetworkICO is Pausable, Ownable {
    address public constant CCN = 0x36443775D39A5091996F21e769d648c22Df977F4;
    address public constant TREASURY = 0x50Fb07B69505927F6a85C8Ff7BA77c34d3f1077C;
    address public constant RESEARCH_AND_DEVELOPMENT = 0x2D6433195E058eB8bd24b00061d7A6Ce8E7e587D;
    address public constant LIQUIDITY_POOL = 0x2D6433195E058eB8bd24b00061d7A6Ce8E7e587D;
    
    uint public constant MAX_ORDER_SIZE = 50000000000000000000000000;
    mapping(address => uint) public orders;
   
    uint public bnbPrice;
    uint public icoBalance;

    event Released(address indexed to, uint amount);

    function start() public onlyOwner {
       icoBalance = IERC20(CCN).balanceOf(address(this));
    }

    function purchese() public payable whenNotPaused returns (bool) {
        uint amount = (1250000000 * (bnbPrice * msg.value * 1000000000000)) / 1000000000000000000; 
       
        require(amount <= icoBalance, "ICO BALANCE IS LESS THAN YOUR ORDER");
        require(amount < MAX_ORDER_SIZE, "MAX_ORDER_SIZE ERROR");
        require((orders[msg.sender] + amount) < MAX_ORDER_SIZE, "YOU ARE LIMITED");

        (bool treasurySuccess, ) = LIQUIDITY_POOL.call{value: ((msg.value * 20) / 100)}("");
        (bool developmentSuccess, ) = RESEARCH_AND_DEVELOPMENT.call{value: ((msg.value * 20) / 100)}("");
        (bool liquiditySuccess, ) = RESEARCH_AND_DEVELOPMENT.call{value: ((msg.value * 60) / 100)}("");

        if(treasurySuccess && developmentSuccess && liquiditySuccess) {
            IERC20(CCN).transfer(msg.sender, amount);
            orders[msg.sender] += amount;
            icoBalance -= amount;
            emit Released(msg.sender,amount);

            return true;
        }

        return false;
    }

    function setBnbPrice(uint price) public onlyOwner {
        bnbPrice = price;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
