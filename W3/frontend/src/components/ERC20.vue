<script>
import { ethers } from "ethers";
import Token from "../../../artifacts/contracts/Token.sol/Token.json";
import Vault from "../../../artifacts/contracts/Vault.sol/Vault.json";

// import erc2612Abi from '../../../deployments/abi/ERC2612.json'
// import bankAddr from '../../../deployments/dev/Bank.json'
// import bankAbi from '../../../deployments/abi/Bank.json'

const erc20Address = "0xc2Eb7699606Cf48892a77b4aA234caD22946d5D1";
const vaultAddress = "0x84D4FAA8FFc5aA958bbb09Fc723747fd166C0cf6";


export default {
  name: "erc20",
  data() {
    return {
      recipient: null,
      amount: 0,
      balance: 0,
      tokenName: "",
      decimal: 0,
      symbol: "",
      supply: 0,
      account: "",
      stakeAmount: 0,
      deposit: 0,
    };
  },
  async created() {
    await this.initAccount();
    await this.initContract();
    await this.getInfo();  
    await this.getUserDeposit();
  },

  methods: {
    async initAccount() {
      if (typeof window.ethereum == "undefined") {
        alert("MetaMask is installed!");
        return;
      }
      try {
        this.accounts = await ethereum.request({
          method: "eth_requestAccounts",
        });
        this.account = this.accounts[0];
        this.currProvider = window.ethereum;
        this.provider = new ethers.providers.Web3Provider(window.ethereum);
        this.signer = this.provider.getSigner();
        let network = await this.provider.getNetwork();
        this.chainId = network.chainId;
      } catch (error) {
        console.log("User denied account access", error);
      }
    },
    async initContract() {
      this.erc20Token = new ethers.Contract(
        erc20Address,
        Token.abi,
        this.signer
      );
      this.vault = new ethers.Contract(vaultAddress,
        Vault.abi, this.signer);
    },


    async getUserDeposit() {
      let deposit = await this.vault.deposits(erc20Address ,this.account);
      this.deposit = ethers.utils.formatUnits(deposit, 18);
    },

    async getInfo() {
      const tokenName = await this.erc20Token.name();
      this.tokenName = tokenName;
      const tokenSymbol = await this.erc20Token.symbol();
      this.symbol = tokenSymbol;
      const decimal = await this.erc20Token.decimals();
      this.decimal = decimal;
      const tokenSupply = await this.erc20Token.totalSupply();
      this.supply = ethers.utils.formatUnits(tokenSupply, 18);
      const tokenBalance = await this.erc20Token.balanceOf(
        this.account
      );
      this.balance = ethers.utils.formatUnits(tokenBalance, 18);
    },
    async getNonce() {
      this.erc20Token.nonces(this.account).then((r) => {
        this.nonce = r.toString();
        console.log("nonce:" + this.nonce);
      });
    },
    async approve() {
      let amount = ethers.utils.parseUnits(this.stakeAmount, 18);
      this.erc20Token.approve(
        vaultAddress,
        amount,
      ).then((r) => {
        console.log(r);
      });
    },
    async transfer() {
      let amount = ethers.utils.parseUnits(this.amount, 18);
      this.erc20Token.transfer(this.recipient, amount).then((r) => {
        console.log(r); // 返回值不是true
        this.getInfo();
      });
    },
    async mintToken() {
      let amount = ethers.utils.parseUnits("3000", 18);
      this.erc20Token.claimToken(this.account, amount).then((r) => {
        console.log(r); // 返回值不是true
        this.getInfo();
      });
    },
    async confirmStake() {
      console.log(this.stakeAmount);
      this.erc20Token.allowance(this.account, vaultAddress).then((r) => {
        console.log(ethers.utils.formatUnits(r, 18));
      });
      let amount = ethers.utils.parseUnits(this.stakeAmount, 18);
      this.vault.deposit(erc20Address, amount).then((r) => {
        console.log(r); // 返回值不是true
        this.getUserDeposit();
      });
    },
    async confirmWithdraw() {
      let amount =  ethers.utils.parseUnits(this.deposit, 18);
      console.log(amount);
      this.vault.withdraw(erc20Address, amount).then((r) => {
        console.log(r); // 返回值不是true
        this.getUserDeposit();
      });
    },
  },
};
</script>

<template>
 <div className="flex flex-col items-center min-h-screen py-2 bg-slate-100">
      <button className="px-4 py-2 bg-purple-600 cursor-pointer text-white">
        我的地址：{{account}}
      </button>
      <button className="px-3 py-1 bg-purple-600 cursor-pointer text-white" @click="mintToken()">增发</button>
      <div>
        <li className='list-none tracking-widest'>Token名称 : {{ tokenName }}</li> 
        <li className='list-none tracking-widest'>Token符号 : {{ symbol }}</li> 
        <li className='list-none tracking-widest'>Token精度 : {{ decimal }} </li>
        <li className='list-none tracking-widest'>Token发行 : {{ supply }}</li>
        <li className='list-none tracking-widest'>我的总余额 : {{ balance }}</li>
      </div>
       <div >
        <br />转账到地址:
        <input type="text" v-model="recipient" />
        <br />
        <br />转账金额为:
        <input type="text" v-model="amount" />
        <br />
        <button className="px-3 py-1 bg-purple-600 cursor-pointer text-white" @click="transfer()"> 确认转账 </button>
      </div>
    <div >
      <br />质押到到Vault存款合约:
      <br />
      <br />
      <input type="text" v-model="stakeAmount" placeholder="输入质押量"/>
      <br />
      <br />
      <button className="px-3 py-1 bg-purple-600 cursor-pointer text-white" @click="approve"> 授权质押 </button>  &nbsp;  &nbsp;
      <button className="px-3 py-1 bg-purple-600 cursor-pointer text-white" @click="confirmStake()">确认质押</button>
      <br />
      我的存款金额: {{ deposit }}

      <button className="px-3 py-1 bg-purple-600 cursor-pointer text-white" @click="confirmWithdraw()">取回我的代币</button>

    </div>
    </div>
</template>