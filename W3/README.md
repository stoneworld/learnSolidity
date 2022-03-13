## 目录
1. [第一节课作业](#jump1)
2. [第二节课作业](#jump2)
3. [课程总结记录](#jump3)


### <span id="jump1">第一节课作业</span>

W3_1作业
* 发⾏⼀个 ERC20 Token： 
   * 可动态增发（起始发⾏量是 0） 
   * 通过 ethers.js. 调⽤合约进⾏转账
* 编写⼀个Vault 合约：
   * 编写deposite ⽅法，实现 ERC20 存⼊ Vault，并记录每个⽤户存款⾦额 ， ⽤从前端调⽤（Approve，transferFrom） 
   * 编写 withdraw ⽅法，提取⽤户⾃⼰的存款 （前端调⽤）
   * 前端显示⽤户存款⾦额

首先利用 openzeppelin 完成了 Token 合约基本代码的书写，起始发行量是 0，因为是可以可以动态增发，这里首先定义了一个 canMintAddresses 可增发的 mapping，合约的发行者有权限增发。

```
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 public constant maxTokenNumber = 100000000 * 10 ** 18; // 限定最大数量

    address public owner;

    mapping(address => bool) public canMintAddresses;

    constructor() ERC20("Developer", "Dev") {
        owner = msg.sender;
        canMintAddresses[msg.sender] = true;
    }
}

```

其次增发可能存在其他用户，定义了 addCanMintAddress 增加可增发地址，claimToken 时校验是否有权限增发。

```

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

```

在网页上增加 mint 功能按钮如下，点击按钮后 hash 地址如下：https://rinkeby.etherscan.io/tx/0x7850df6435404adee0e74a34fdc4f2f3b88e43543a889ed26ef800bb828ac281

<img src=./assets/WechatIMG266.png width=50% />


而后完成了 vault 合约代码如下：

```
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract Vault {
    using SafeERC20 for IERC20;

    mapping (address => mapping (address => uint256)) public deposits;
    // 编写deposit ⽅法，实现 ERC20 存⼊ Vault，并记录每个⽤户存款⾦额
    function deposit(address _token, uint256 _amount) public {
        // 存款⾦额记录
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        deposits[_token][msg.sender] += _amount;
    }

    function withdraw(address _token, uint _amount) public {
        // 提取⾦额记录
        require(deposits[_token][msg.sender] >= _amount, "not enough balance");
        IERC20(_token).safeTransfer(msg.sender, _amount);
        deposits[_token][msg.sender] -= _amount;
    }
}

```

浏览器端显示如下，授权的 hash 如下：https://rinkeby.etherscan.io/tx/0x9228218019422cd81e133eeb675b88bbceaae296074fcfcadf512b9cfe41e341

确认质押的 hash 如下：https://rinkeby.etherscan.io/tx/0xb3cafa0b0df8ef6b4324327cd6a076244b9b90d718b87d7fd08ea34efc2ed98e

<img src=./assets/WechatIMG269.png width=50% />

取款的 hash 如下：https://rinkeby.etherscan.io/tx/0x293bd43187ee81ab5a6235021cdf94273f5d9b0d4a36a7bc5f4343d88097eeb8


### <span id="jump2">第二节课作业</span>

TODO


### <span id="jump2">代码疑问总结记录</span>


type(I).interfaceId:
返回接口``I`` 的 bytes4 类型的接口 ID，接口 ID 参考： EIP-165 定义的， 接口 ID 被定义为 XOR （异或） 接口内所有的函数的函数选择器（除继承的函数

```
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
   return interfaceId == type(IERC165).interfaceId;
}
```




