pragma solidity ^0.5.0;

    /**
    * @title Linked list for tracking parcel positions
    * @dev This linked list will set a record of the tracks emited by one
    * particular parcel with a gps
    */

contract GpsTracks{

    event AddTrack(bytes32 head,string pos,bytes32 next);

    struct _GpsTrack{
        bytes32 next;
        string pos;
    }

    /// @dev Head of the linked list
    bytes32 public head;

    /// @dev Current lenght of the list to iterate
    uint public length = 0;

    /// @dev GpsTrack
    mapping (bytes32 => _GpsTrack) public tracks;

    /// @dev Function to add a new track
    /// @param _pos the GPS position
    function newTrack(string memory _pos) public returns (bool){
        _GpsTrack memory track = _GpsTrack(head,_pos);
        bytes32 id = bytes32(keccak256(abi.encodePacked(track.pos,block.number,length)));
        tracks[id] = track;
        head = id;
        length = length+1;
        emit AddTrack(head,track.pos,track.next);
    }

    function addTrack(string memory _pos) public returns (bool){
        newTrack(_pos);
    }

    /// @dev Function to retrieve the id
    /// @param _id id of the track to match
    function getTrack(bytes32 _id) public view returns (bytes32,string memory){
        return (tracks[_id].next,tracks[_id].pos);
    }

}
