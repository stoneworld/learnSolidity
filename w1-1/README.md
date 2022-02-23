[啤酒]W1-1作业：
- 安装 Metamask、并创建好账号
- 执行一次转账
- 使用 Remix 创建任意一个合约
- VSCode IDE 开发环境配置
- 使用 Truffle 部署 Counter 合约 到 test 网络（goerli）（提交交易 hash）
- 编写一个测试用例
### 安装 MetaMask，并创建账号。

安装的扩展如图所示：

<img src=./assets/WX20220223-122921@2x.png width=20% />

通过 https://chainlist.org/ 网站，增加了 OK 测试链，并在水龙头获取测试币（OKT）。

### 执行一次转账

转账交易hash如下：
https://www.oklink.com/zh-cn/oec-test/tx/0x92b2a84b88bfe793490098ae2a351156d7462fe07436d43d2d74425bc02ffa91

### 使用 Remix 创建任意一个合约

部署示例图如下：

<img src=./assets/WX20220223-123823@2x.png width=20% />

合约创建的hash地址如下：
https://www.oklink.com/zh-cn/oec-test/tx/0x2714a406a21d9dee4f564b94defbc86c79c54f20bb79e9b44770f7890e337f20

### VSCode IDE 开发环境配置

<img src=./assets/WX20220223-191402.png width=30% />

### 使用 hardhat 部署合约 到 test 网络（goerli）（提交交易 hash）

npm init

npm i hardhat --save-dev

安装完毕后，运行：

npx hardhat

选择第一项 "Create a basic sample project"，一路回车即可：

* contracts为合约文件夹，用于存档各种你写的sol文件
* script为脚本文件夹，里面可以存放各种自定义js脚本，比如合约部署脚本等等
* test为单元测试
* hardhat.config.js文件用来配置hardhat的基本信息和各种自动化任务

我这里创建的虽然不是 Count 名称的合约，但功能类似如下：

```
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Company {
    int public totalUser; // 状态变量（函数之外声明的变量）默认为“存储”类型，永久写入区块链。 函数内的storage表示对状态变量的引用
    
    constructor(int _totalUser) { // 构造函数初始化 totalUser = _totalUser
        console.logInt(_totalUser);
        totalUser = _totalUser;
    }

    function incTotalUser() public {
        totalUser += 1;
    }

    function getTotalUser() public view returns (int) { // 定义可以公开访问的 getTotalUser 函数
        return totalUser;
    }
}

```

本地执行编译和测试后的结果如下：

<img src=./assets/WX20220223-134044.png width=30% />

Fork 主网

>你可以启动一个Fork主网的Hardhat Network实例。 Fork主网意思是模拟具有与主网相同的状态的网络，但它将作为本地开发网络工作。
>这样你就可以与部署的协议进行交互，并在本地测试复杂的交互。要使用此功能，你需要连接到存档节点。 建议使用Alchemy

在 hardhat.config.js 进行配置如下：

```
module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "rinkeby",
  networks: {
    hardhat: {},
    rinkeby: {
      url: "",
      accounts: ['']
    }
  },
};
```

随后执行：
> npx hardhat run scripts/sample-script.js --network rinkeby

执行后的交易hash地址如下：https://rinkeby.etherscan.io/address/0x6EAE2C1499f7372414AA3AaAEa4dCa6895fe73bF








