# learnSolidity
Solidity学习记录

```Solidity
    struct Employers {
        string name;
        mapping (int=>int) Users; // 公司下的用户
        int userCnt
    }

    mapping (int=>User) Users; // 所有的用户

    mapping(int => mapping (address => uint256)) donation; // 某个人被多少人捐助过

    mapping(address => uint256) userTotalDonation; // 某用户总捐助数量

    struct User {
        address _address;
        string name;
        int age;
    }

    Employee[] employees;
```