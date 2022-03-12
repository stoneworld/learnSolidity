//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


/**
W3_1作业
* 发⾏⼀个 ERC20 Token： 
   * 可动态增发（起始发⾏量是 0） 
   * 通过 ethers.js. 调⽤合约进⾏转账
* 编写⼀个Vault 合约：
   * 编写deposite ⽅法，实现 ERC20 存⼊ Vault，并记录每个⽤户存款⾦额 ， ⽤从前端调⽤（Approve，transferFrom） 
   * 编写 withdraw ⽅法，提取⽤户⾃⼰的存款 （前端调⽤）
   * 前端显示⽤户存款⾦额
    */
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 public constant maxTokenNumber = 100000000 * 10 ** 18; // 限定最大数量

    address public owner;

    mapping(address => bool) public canMintAddresses;

    constructor() ERC20("Developer", "Dev") {
        owner = msg.sender;
        canMintAddresses[msg.sender] = true;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function addCanMintAddress(address _canMintAddress) public onlyOwner { // 增加可以增发的地址
        if (canMintAddresses[_canMintAddress] == false) {
            canMintAddresses[_canMintAddress] = true;
        }
    }

    modifier hasPermission(address _mintAddress) {
        require(canMintAddresses[_mintAddress] == true);
        _;
    }

    function claimToken(address _to, uint256 _amount) public hasPermission(_msgSender()) returns (bool){ // 仅仅代币发行者可以增发
        require(totalSupply() + _amount <= maxTokenNumber);
        _mint(_to, _amount);
        return true;
    }
}