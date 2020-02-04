pragma solidity ^0.5.0;

    /**
    * @title Linked list for reporting issues in external contract structures
    * @dev This chain will make an easy way to recover a full log of reported
    * issues in a data structure of an external contract.
    */

contract IssueChain{

    event AddIssue(bytes32 head,uint number,address emitter,string text);

    struct _Issue{
        bytes32 next;
        uint  number;
        address emitter;
        string text;
    }
    
    uint public issueNumbers=0;

    /// @dev Total amount of written issues
    uint public writtenTotal;

    /// @dev Head of the linked list
    bytes32 public head;

    /// @dev Current lenght of the list to iterate
    uint public length = 0;

    /// @dev Issue mapping
    mapping (bytes32 => _Issue) public issues;

    /// @dev Function to create a new issue
    /// @param _emitter of the emitter
    /// @param text describing the issue
    function addIssue(address _emitter, string calldata text) external returns (bool){
        _Issue memory issue = _Issue(head,length,_emitter,text);
        bytes32 id = bytes32(keccak256(abi.encodePacked(length,_emitter,block.number,length)));
        issues[id] = issue;
        head = id;
        length = length+1;
        emit AddIssue(head,issue.number,issue.emitter,text);
    }

    /// @dev Function to obtain the data of a specified Issue
    /// @param _id Id of the Issue to obtain
    function getIssue(bytes32 _id) public view returns (bytes32,uint,address,string memory){
        string memory issueText = issues[_id].text;
        return (issues[_id].next,issues[_id].number,issues[_id].emitter,issueText);
    }

    /// @dev Function to get the total amount of elements in the list
    function getTotal() public view returns (uint) {
        bytes32 current = head;
        uint totalCount = 0;
        while( current != 0 ){
            totalCount = totalCount + issues[current].number;
            current = issues[current].next;
        }
        return totalCount;
    }

    /// @dev Function to change the text in a specified issue
    /// @param _id Id of the Issue to obtain
    /// @param _newText The new text you want to set for the issue
    function setIssueText(bytes32 _id, string memory _newText) public returns (string memory){
        issues[_id].text = _newText;
        string memory issueText = issues[_id].text;
        return (issueText);
    }

    /// @dev Updates the total amount of elements in the list
    function setTotal(uint nTotal) public returns (bool) {
        writtenTotal = nTotal;
        return true;
    }

    /// @dev Resets the total amount of elements in the list
    function resetTotal() public returns (bool) {
        writtenTotal = 0;
        return true;
    }
    function getLast() public returns (bytes32){
        return head;
    }
}
