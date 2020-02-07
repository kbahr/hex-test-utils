pragma solidity ^0.5.16;

import "./HEX.sol"; // TODO: Windows file separator

contract HEXMock is HEX {

    struct LobbyEntry {
        uint256 amount;
        address referrer;
        bool cashed;
    }

    mapping(address => StakeStore[]) public stakeLists;
    mapping(uint256 => DailyDataStore) public dailyData;

    mapping (address => uint256) public balances;
    mapping (uint256 => uint256) public lobbySizes;
    mapping (uint256 => mapping (address => LobbyEntry)) public lobbyEntries;

    uint256 public HEX_LAUNCH_TIME; //TODO: FIX ME
    uint256 internal constant LOBBY_PAYOUT_BASE = 1e9 * 1e8;
    uint256 internal constant CLAIM_PHASE_END_DAY = 351;
    uint256 internal constant XF_LOBBY_DAY_WORDS = (CLAIM_PHASE_END_DAY + 255) >> 8;
    uint40 internal nextStakeId = 1;

    constructor(uint256 time)
    public
    {
        require(time != 0, "Needs time");
        HEX_LAUNCH_TIME = time;
    }

    function xfLobbyEnter(address referrerAddr)
    external
    payable
    {
        require(msg.value > 0, "Gotta send something");
        uint256 day = _getHexContractDay();
        require(day < CLAIM_PHASE_END_DAY, "WAAS has ended");
        LobbyEntry storage entry = lobbyEntries[day][msg.sender];
        require(entry.amount == 0, "Only 1 entry per person in mock contract");
        entry.amount = msg.value;
        entry.referrer = referrerAddr;
        entry.cashed = false;
        lobbySizes[day] += msg.value;
    }

    function xfLobbyExit(uint256 joinDay, uint256 count)
    external
    {
        uint256 day = _getHexContractDay();
        require(count == 0, "Resolve all is required in mock contract");
        require(joinDay < day, "Only leave lobbies for days that are over");
        LobbyEntry storage entry = lobbyEntries[joinDay][msg.sender];
        require(!entry.cashed, "Only leave once per lobby");
        require(entry.amount > 0, "Only leave lobbies you have joined");
        entry.cashed = true;
        uint256 dayPayout = calcDayPayout(joinDay);
        uint256 userPayout = dayPayout * entry.amount / lobbySizes[joinDay];
        balances[msg.sender] += userPayout;
        if(entry.referrer != address(0)){
            uint256 referralPayout = userPayout / 10;
            userPayout += referralPayout;
            uint256 referrerPayout = userPayout / 5;
            balances[msg.sender] += referralPayout;
            balances[entry.referrer] += referrerPayout;
        }
    }

     function xfLobbyPendingDays(address memberAddr)
        external
        view
        returns (uint256[XF_LOBBY_DAY_WORDS] memory words)
    {
        uint256 day = _getHexContractDay() + 1;

        if (day > CLAIM_PHASE_END_DAY) {
            day = CLAIM_PHASE_END_DAY;
        }

        while (day-- != 0) {
            if (lobbyEntries[day][memberAddr].amount > 0) {
                words[day >> 8] |= 1 << (day & 255);
            }
        }

        return words;
    }

    function xfLobbyEntry(address memberAddr, uint256 entryId)
        external
        view
        returns (uint256 rawAmount, address referrerAddr)
    {
        uint256 enterDay = entryId;

        LobbyEntry storage entry = lobbyEntries[enterDay][memberAddr];

        return (entry.amount, entry.referrer);
    }

    function currentDay()
    public
    view
    returns (uint256)
    {
        return _getHexContractDay();
    }

    function calcDayPayout(uint256 day)
    public
    pure
    returns (uint256)
    {
        uint256 payout = LOBBY_PAYOUT_BASE;
        for(uint16 i = 0; i < day; i++){
            payout = payout * 98 / 100;
        }
        return payout;
    }

    function dailyDataRange(uint256 beginDay, uint256 endDay)
        external
        view
        returns (uint256[] memory list)
    {
        require(beginDay < endDay && endDay <= _getHexContractDay(), "HEX: range invalid");

        list = new uint256[](endDay - beginDay);

        uint256 src = beginDay;
        uint256 dst = 0;
        uint256 v;
        do {
            v = uint256(dailyData[src].dayUnclaimedSatoshisTotal) << (72 * 2);
            v |= uint256(dailyData[src].dayStakeSharesTotal) << 72;
            v |= uint256(dailyData[src].dayPayoutTotal);

            list[dst++] = v;
        } while (++src < endDay);

        return list;
    }

    function stakeStart(uint256 newStakedHearts, uint256 newStakedDays)
    external
    {
        StakeStore memory newStake = StakeStore(
            nextStakeId++,
            uint72(newStakedHearts), //no bonus, whatever
            uint72(newStakedHearts),
            uint16(currentDay()+1),
            uint16(newStakedDays),
            0,
            false
        );
        stakeLists[msg.sender].push(newStake);
        _burn(msg.sender, newStakedHearts);
    }

    function stakeCount(address stakerAddr)
    external
    view
    returns (uint256)
    {
        return stakeLists[stakerAddr].length;
    }

    function globalInfo()
    external
    view
    returns (uint256[13] memory)
    {
        // junk method
        uint256 z = 0;
        return [z, z, z, z, z, z, z, z, z, z, z, z, z];
    }

    function testMint (address account, uint256 amount)
    external
    {
        _mint(account, amount);
    }

    function _getHexContractDay()
    private
    view
    returns (uint256)
    {
        require(HEX_LAUNCH_TIME < block.timestamp, "HEX: Launch is not before current block time");
        return (block.timestamp - HEX_LAUNCH_TIME) / 1 days;
    }
}