/**
  * Submitted By
  * Anish Patel
  * 101227442
  */

pragma solidity ^0.5.2;

import "./Rewards.sol";

/**
  * @title SeedFunding
  * @type Contract
  * @description This is the main contract for the application.
  */
contract SeedFunding {
  address public InvestorAddress = address(this);
  uint public balance;
  address payable public owner;
  mapping(address => Investor) public investorsDB;
  Rewards public rewardsContract;
  uint256 public goal;
  uint256 public numParticipants;

  /**
    * @title Investor
    * @type Structure
    * @description A definite structure for Investor data.
    */
  struct Investor {
    bool isInvestor;
    uint256 investment;
  }

  constructor(address _rewardsContract, uint256 _goal) public {
    rewardsContract = Rewards(_rewardsContract);
    if(!rewardsContract.isMinter(InvestorAddress)) {
      rewardsContract.addMinters(InvestorAddress);
    }

    owner = tx.origin;
    goal = _goal;
    numParticipants = 0;
    InvestorAddress = address(this);
    balance = 0;
  }

  /**
    * @title isAuthorized
    * @type Modifier
    * @usage Allows investors only.
    */
  modifier isAuthorized() {
    require(investorsDB[tx.origin].isInvestor, "Unauthorized Access!");
    _;
  }

  /**
    * @title addInvestor
    * @type Function
    * @usage To add investors when accepting funds.
    */
  function addInvestor(address _investor) public {
    require(!investorsDB[tx.origin].isInvestor, "Duplicates restricted!");
    numParticipants = numParticipants + 1;
    investorsDB[_investor].isInvestor = true;

  }

  /**
    * @title removeInvestor
    * @type Function
    * @usage To remove investors.
    */
  function removeInvestor(address _investor) public {
    require(investorsDB[_investor].isInvestor, "Not Found!");
    investorsDB[_investor].isInvestor = false;
  }

  /**
    * @title invest
    * @type Function
    * @usage To submit investment funds.
    */
  function invest() public isAuthorized payable {
    require(msg.value > 0.5 ether, "Insufficient Amount!");
    require(balance < goal, "Funds are not being accepted anymore!");

    balance = InvestorAddress.balance/(1 ether) + balance;
    investorsDB[tx.origin].investment += msg.value;
  }

  /**
    * @title getInvestment
    * @type Function
    * @usage To make a transfer of funds.
    */
  function getInvestment() public {
    require(tx.origin == owner, "Unauthorized Access!");
    owner.transfer(InvestorAddress.balance);
  }

  /**
    * @title getInvestment
    * @type Function
    * @usage To make a transfer of funds.
    */
  function withdraw()public isAuthorized {
    rewardsContract.trigger();
    rewardsContract.withdraw();
  }

  /**
    * @title getInvestment
    * @type Function
    * @usage To make a transfer of funds.
    */
  function numParticipant()public isAuthorized view returns (uint) {
    return numParticipants;
  }
}

/**
  * @title FactoryForSeedFunding
  * @type Contract
  * @description Factory contract to deploy instances of SeedFunding contract.
  */
contract FactoryForSeedFunding {
  uint public SeedId;
  mapping(uint => SeedFunding ) SeedFundingList;
  address public rewards;
  uint256 goal;

  /**
    * @title deploy
    * @type Function
    * @usage To deploy instances of SeedFunding contract and log references in memory.
    */
  function deploy(uint256 _goal, address _rewards) public {
    SeedId++;
    goal = _goal;
    rewards = _rewards;

    SeedFunding s = new SeedFunding(rewards,goal);
    SeedFundingList[SeedId] = s;
  }

  /**
    * @title getFactoryById
    * @type Function
    * @usage GET request implementation for one contract.
    */
  function getFactoryById(uint _id) public view returns (SeedFunding) {
    return SeedFundingList[_id];
  }
}

/**
  * @title getFactoryById
  * @type Function
  * @usage GET request implementation for one contract.
  */
contract DashboardForSeedFunding {
  uint public Seedid;
  FactoryForSeedFunding public database;

  constructor(address _database) public {
    database = FactoryForSeedFunding(_database);
  }

  /**
    * @title newContract
    * @type Function
    * @usage GET request implementation for one contract.
    */
  function newContract(uint256 _goal,address _rewards) public {
    Seedid++;
    database.deploy(_goal,_rewards);
  }

  /**
    * @title getId
    * @type Function
    * @usage Get ID for seed.
    */
  function getId()public view returns(uint) {
    return Seedid;
  }

  /**
    * @title getAddInvestorById
    * @type Function
    * @usage Client facing implementation to add investor.
    */
  function getAddInvestorById(uint _id,address investor) public {
    SeedFunding s = SeedFunding(database.getFactoryById(_id));
    s.addInvestor(investor);
  }

  /**
    * @title getRemoveInvestorById
    * @type Function
    * @usage Client facing implementation to remove investor.
    */
  function getRemoveInvestorById(uint _id,address investor) public {
    SeedFunding s = SeedFunding(database.getFactoryById(_id));
    s.removeInvestor(investor);
  }

  /**
    * @title getInvestById
    * @type Function
    * @usage Client facing implementation to GET investor.
    */
  function getInvestById(uint _id) public payable {
    SeedFunding s = SeedFunding(database.getFactoryById(_id));
    s.invest.value(msg.value)();
  }

  /**
    * @title getWithdrawById
    * @type Function
    * @usage Client facing withdrawal implementation.
    */
  function getWithdrawById(uint _id) public payable {
    SeedFunding s = SeedFunding(database.getFactoryById(_id));
    s.withdraw();
  }

  /**
    * @title getGetInvestmentId
    * @type Function
    * @usage Client facing implementation to find investor by ID.
    */
  function getGetInvestmentId(uint _id) public payable {
    SeedFunding s = SeedFunding(database.getFactoryById(_id));
    s.getInvestment();
  }
}
