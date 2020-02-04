pragma solidity ^0.5.0;

    /**
    * @title Linked list for responsibility accounting
    * @dev This linked list will set a record of the people involved in the
    * responsibility/manipulation of the parcel.
    */

contract LiabilityChain{

    event AddResponsible(bytes32 head,bytes32 Address,bytes32 next);

    struct _Responsible{
        bytes32 next;
        bytes32 Address;
    }

    /// @dev Head of the linked list
    bytes32 public head;

    /// @dev Current lenght of the list to iterate
    uint public length = 0;

    /// @dev Responsible mapping
    mapping (bytes32 => _Responsible) public responsibles;

    /// @dev Function to create a new responsible
    /// @param _Address of the responsible
    function addResponsible(bytes32 _Address) public payable returns (bool){
        _Responsible memory responsible = _Responsible(head,_Address);
        bytes32 id = bytes32(keccak256(abi.encodePacked(responsible.Address,block.number,length)));
        responsibles[id] = responsible;
        head = id;
        length = length+1;
        emit AddResponsible(head,responsible.Address,responsible.next);
    }

    /// @dev Function to obtain the data of a specified responsible
    /// @param _id of the responsible involved
    function getResponsible(bytes32 _id) public view returns (bytes32,bytes32){
        return (responsibles[_id].next,responsibles[_id].Address);
    }
    /// @dev Function to obtain the data of a specified responsible
    function getHeadOfResponsibles() public view returns (bytes32){
        return head;
    }
    
}
