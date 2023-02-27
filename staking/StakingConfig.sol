// SPDX-License-Identifier: BSL 1.1
pragma solidity =0.8.17;

import "../openzeppelin/access/Ownable2Step.sol";
import "../openzeppelin/token/ERC20/ERC20.sol";


contract StakingConfig is Ownable2Step
    {
	ERC20 public salt;

	// Salty Protocol Owned Liquidity - the address holding the protocol liquidity
	address public saltyPOL;

	// Early Unstake Handler - early unstake fees are sent here and then distributed on upkeep
	address public earlyUnstake;

    // Changeable for debugging purposes to accelerate time
	uint256 public oneWeek = 5 minutes; // 1 weeks;

	uint256 public minUnstakePercent = 50;

	uint256 public minUnstakeWeeks = 2; // minUnstakePercent returned here
	uint256 public maxUnstakeWeeks = 26; // 100% staked returned here

	// Minimum time between deposits or withdrawals for each pool.
	// Prevents reward hunting where users could frontrun reward distributions and then immediately withdraw
	uint256 public depositWithdrawalCooldown = 1 hours;

	// Keeps track of what pools are valid
	address[] allPools;
	mapping(address=>bool) poolAdded;													// [poolID]
	mapping(address=>uint256) poolWhitelisted;												// [poolID]


	constructor( address _salt )
		{
		salt = ERC20( _salt );
		}


	function setSALT( address _salt ) public onlyOwner
		{
		salt = ERC20( _salt );
		}


	function setSaltyPOL( address _saltyPOL ) public onlyOwner
		{
		saltyPOL = _saltyPOL;
		}


	function setEarlyUnstake( address _earlyUnstake ) public onlyOwner
		{
		earlyUnstake = _earlyUnstake;
		}


	function whitelist( address poolID ) public onlyOwner
		{
		// Make sure the pool hasn't already been added to allPools
		if ( ! poolAdded[poolID] )
			{
			allPools.push( poolID );
			poolAdded[poolID] = true;
			}

		poolWhitelisted[poolID] = 1;
		}


	function blacklist( address poolID ) public onlyOwner
		{
		poolWhitelisted[poolID] = 0;
		}


	function setOneWeek( uint256 _oneWeek ) public onlyOwner
		{
		oneWeek = _oneWeek;
		}


	function setUnstakeParams( uint256 _minUnstakeWeeks, uint256 _maxUnstakeWeeks, uint256 _minUnstakePercent ) public onlyOwner
		{
		require( _minUnstakeWeeks < _maxUnstakeWeeks );

		minUnstakeWeeks = _minUnstakeWeeks;
		maxUnstakeWeeks = _maxUnstakeWeeks;

		minUnstakePercent = _minUnstakePercent;
		}


	function setDepositWithdrawalCooldown( uint256 _depositWithdrawalCooldown ) public onlyOwner
		{
		depositWithdrawalCooldown = _depositWithdrawalCooldown;
		}


	// ===== VIEWS =====
	function isValidPool( address poolID ) public view returns (bool)
		{
		return poolWhitelisted[poolID] == 1;
		}


	function whitelistedPools() public view returns (address[] memory)
		{
		address[] memory valid = new address[](allPools.length);

		uint256 numValid = 0;
		for( uint256 i = 0; i < allPools.length; i++ )
			{
			address poolID = allPools[i];

			if ( isValidPool( poolID ) )
				valid[ numValid++ ] = poolID;
			}

		address[] memory valid2 = new address[](numValid);
		for( uint256 i = 0; i < numValid; i++ )
			valid2[i] = valid[i];

		return valid2;
		}
    }