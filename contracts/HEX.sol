pragma solidity ^0.5.16;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract HEX is ERC20{
    struct StakeStore {
        uint40 stakeId;
        uint72 stakedHearts;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
        bool isAutoStake;
    }

    struct DailyDataStore {
        uint72 dayPayoutTotal;
        uint72 dayStakeSharesTotal;
        uint56 dayUnclaimedSatoshisTotal;
    }

    mapping(address => StakeStore[]) public stakeLists;
    mapping(uint256 => DailyDataStore) public dailyData;

    function xfLobbyEnter(address referrerAddr)
    external
    payable;

    function xfLobbyExit(uint256 joinDay, uint256 count)
    external;

    function xfLobbyPendingDays(address memberAddr)
    external
    view
    returns (uint256[2] memory words);

    function xfLobbyEntry(address memberAddr, uint256 entryId)
    external
    view
    returns (uint256 rawAmount, address referrerAddr);

    function testMint (address recipient, uint256 amount)
    external;

    function currentDay ()
    external
    view
    returns (uint256);

    function dailyDataRange(uint256 beginDay, uint256 endDay)
    external
    view
    returns (uint256[] memory list);

    function stakeStart(uint256 newStakedHearts, uint256 newStakedDays)
    external;

    function stakeCount(address stakerAddr)
    external
    view
    returns (uint256);

    function globalInfo()
    external
    view
    returns (uint256[13] memory);
}