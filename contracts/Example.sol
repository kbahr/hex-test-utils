pragma solidity >= 0.5.16;

import "./HEX.sol";

contract Example {

    HEX internal hx;

    mapping(address => uint256) public storedValue;
    mapping(uint256 => bool) public daysWithEntries;

    constructor(address hexContract)
    public
    {
        require(hexContract != address(0), "HEX contract address required");
        hx = HEX(hexContract);
    }

    function doExampleThing()
    public
    payable
    {
        // don't really do anything with this, just showing calling the interface
        uint256 day = hx.currentDay();
        hx.xfLobbyEnter.value(msg.value)(address(this));
        daysWithEntries[day] = true;
        storedValue[msg.sender] += msg.value;
    }

    function readState()
    public
    view
    returns (uint256)
    {
        // no point here, just implementing so the test passes 
        return storedValue[msg.sender];
    }
}