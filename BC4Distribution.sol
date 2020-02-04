pragma solidity ^0.5.0;

import "./CRUDUnorderedKeySet.sol";
import "./DistributionSystem.sol";

/**
 * @title Block Chain 4 Distribution by Jorge Curbera
 * @dev A distribution system implemented with ethereum smart contracts.
 * This system will keep a distributed registry for parcels. The parcels will
 * be tracked with GPS emmiters, mantained with a list of manipulators, state
 * and the different issues registered for the parcel.
 */

 contract BC4Distribution{

  using CRUDUnorderedKeySetLib for CRUDUnorderedKeySetLib.Set;
  CRUDUnorderedKeySetLib.Set dsystemSet;

  struct DSystemStruct {
    address ownerAddress;
    string company;
    string location;
    DistributionSystem platform;
  }

  mapping(bytes32 => DSystemStruct) dsystems;

  event LogNewDSystem(address sender, string company, string location);

  event LogUpdateDSystem(address sender, string company, string location);

  event LogRemDSystem(address sender, bytes32 key);

  /// @dev Create new distribution system
  /// @param key The place in the map to insert the DS
  /// @param ownerAddress The address of the sender
  /// @param company The name of the company
  /// @param location The place where the company is
  function newDSystem(bytes32 key, address ownerAddress,
  string memory company, string memory location) public {
        dsystemSet.insert(key); // Note that this will fail automatically if the key already exists.
        DistributionSystem ds;
        DSystemStruct storage d = dsystems[key];
        d.ownerAddress = msg.sender;
        d.company = company;
        d.location = location;
        d.platform = ds;
        emit LogNewDSystem(msg.sender, d.company, d.location);
    }

  /// @dev Update one distribution system
  /// @param key The place of the element we want to update
  /// @param company The name of the company
  /// @param location The place where the company is
  function updateDSystem(bytes32 key, string memory company, string memory location) public {
        require(dsystemSet.exists(key), "Can't update a dsystem that doesn't exist.");
        DSystemStruct storage d = dsystems[key];
        d.company = company;
        d.location = location;
        emit LogUpdateDSystem(msg.sender, d.company, d.location);
    }

  /// @dev Create new distribution system
  /// @param key The place of the element we want to remove
  function remDSystem(bytes32 key) public {
        dsystemSet.remove(key); // Note that this will fail automatically if the key doesn't exist
        delete dsystems[key];
        emit LogRemDSystem(msg.sender, key);
    }

  /// @dev Retreive distribution system
  /// @param key The place in the map to insert the DS
  function getDSystem(bytes32 key) public view returns(string memory company,
    string memory location, DistributionSystem platform) {
        require(dsystemSet.exists(key), "Can't get a dsystem that doesn't exist.");
        DSystemStruct storage d = dsystems[key];
        return(d.company, d.location, d.platform);
    }

  /// @dev Get the count of clients
  function getDSystemCount() public view returns(uint count) {
        return dsystemSet.count();
    }
  /// @dev Retreive one distribution system's map address by index
  /// @param index The index number of the wanted address
  function getDSystemAtIndex(uint index) public view returns(bytes32 key) {
        return dsystemSet.keyAtIndex(index);
    }

}
