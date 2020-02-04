
pragma solidity ^0.5.0;

/**
 * CRUD Pattern
 * @dev This library has a CRUD style pattern for datasets with useful constraints
 * It uses an unordered 32byte key set and creates pointers.
 *
 */

 library CRUDUnorderedKeySetLib {

    struct Set {
        mapping(bytes32 => uint) keyPointers;
        bytes32[] keyList;
    }

    /// @dev Insert a new element in the data structure
    /// @param self The element to insert
    /// @param key The place in the mapping
    function insert(Set storage self, bytes32 key) internal {
        require(key != 0x0, "UnorderedKeySet(100) - Key cannot be 0x0");
        require(!exists(self, key), "UnorderedKeySet(101) - Key already exists in the set.");
        self.keyPointers[key] = self.keyList.push(key)-1;
    }

    /// @dev Remove element from the set
    /// @param self The element to remove
    /// @param key The place where the element is
    function remove(Set storage self, bytes32 key) internal {
        require(exists(self, key), "UnorderedKeySet(102) - Key does not exist in the set.");
        bytes32 keyToMove = self.keyList[count(self)-1];
        uint rowToReplace = self.keyPointers[key];
        self.keyPointers[keyToMove] = rowToReplace;
        self.keyList[rowToReplace] = keyToMove;
        delete self.keyPointers[key];
        self.keyList.length--;
    }

    /// @dev Retreive the set's length
    /// @param self the set itself
    function count(Set storage self) internal view returns(uint) {
        return(self.keyList.length);
    }

    /// @dev Does the element exist ?
    /// @param self the set itself
    /// @param key the object's place in the set
    function exists(Set storage self, bytes32 key) internal view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    /// @dev Retrieve key from index in the Set
    /// @param self the set itself
    /// @param index The object's place in the set
    function keyAtIndex(Set storage self, uint index) internal view returns(bytes32) {
        return self.keyList[index];
    }

    /// @dev Bye bye set
    /// @param self the set itself
    function nukeSet(Set storage self) public {
        delete self.keyList;
    }
}
