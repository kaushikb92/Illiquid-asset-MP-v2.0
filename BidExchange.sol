pragma solidity ^0.4.8;

contract BidExchange{

    mapping(bytes32=>uint) public mapDeadline;
    mapping(bytes32=>bool) public bidActiveStatus;

    function startBid(bytes8 _bidId, uint _deadlineInMinutes) returns (bool _success){
        uint deadline = now + _deadlineInMinutes * 1 minutes;
        mapDeadline[_bidId] = deadline;
        bidActiveStatus[_bidId] = true;
        return true;
    }

    function getBidDeadline(bytes8 _bidId) constant returns (uint){
        return (mapDeadline[_bidId]);
    }

    function getAndSetDeadline(bytes32 _bidId) returns ()

}