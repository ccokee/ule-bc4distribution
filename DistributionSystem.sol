pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./Date.sol";
import "./GpsTracks.sol";
import "./IssueChain.sol";
import "./LiabilityChain.sol";
import "./BC4Distribution.sol";

/**
 * @title Distribution system contract for each partaker
 * @dev This contract implements the full registry of each distribution
 * system registry.
 */

 contract DistributionSystem is Ownable {

  /// @dev Event for this contract
  event AddParcel(address Address, bytes32 parcelId, uint id);
  event RemoveParcel(address Address, bytes32 parcelId);
  event SetParcelStatus(address Address, bytes32 parcelId, Status status);
  event SetParcelDestLocation(address Address, bytes32 parcelId, uint id, string destLocation);
  event SetParcelExpectedTimestamp(address Address, bytes32 parcelId, uint id, uint expecteTimestamp);
  event SetParcelReceivedTimestamp(address Address, bytes32 parcelId, uint id, uint receivedTimestamp);

  /// @dev Parcel statuses
  enum Status { Registered, Ready, Sent, Queued, Received, Confirmed }

  /// @dev Contract's owner
  struct _Owner {
    address ownerAddres;
    string company;
    string location;
  } _Owner private Owner;

  /// @dev Parcel struct
  struct _Parcel {
    Status parcelStatus;
    address destination;
    string destLocation;
    uint id;
    string qrCode;
    uint createdTimeStamp;
    uint expectedTimeStamp;
    uint receivedTimeStamp;
    GpsTracks parcelTracks;
    LiabilityChain parcelManipulators;
    IssueChain parcelIssues;
  }

  /// @dev Apaño sucio
  struct _GPSTRACK {
        bytes32 next;
        string pos;
  }

  /// @dev Parcel mapping
  mapping(bytes32  => _Parcel) public parcels;
  bytes32 public parcelListHeader;

  /// @dev Distribution System Statistics
  uint public ParcelCount;
  uint public RegisteredParcels;
  uint public ReadyParcels;
  uint public SentParcels;
  uint public QueuedParcels;
  uint public ReceivedParcels;
  uint public ConfirmedParcels;


  /// @dev Contract constructor
  constructor(string memory company, string memory location) public{
          ParcelCount = 0;
          Owner.ownerAddres = msg.sender;
          Owner.company = company;
          Owner.location = location;
  }

  /*
  * Parcel relative functions
  */

  /// @dev Function to register a new parcel
  /// @param newParcel to push in the parcel
  function addParcel(_Parcel memory newParcel) public onlyOwner {
    _Parcel memory parcel = newParcel;
    bytes32 id = bytes32(keccak256(abi.encodePacked(newParcel.destination, block.number, newParcel.id, newParcel.expectedTimeStamp)));
    parcels[id] = parcel;
    parcelListHeader = id;
    ParcelCount += 1;
    emit AddParcel(msg.sender,id,parcel.id);
  }

  /// @dev Function to get a specific parcel data
  /// @param parcelId The id to retreive the parcel data
  function getParcel(bytes32 parcelId) public view returns (_Parcel memory parcel) {
    return(parcels[parcelId]);
  }

  /// @dev Function to get a specific parcel status
  /// @param parcelId The id to retreive the parcel data
  function getParcelStatus(bytes32 parcelId) public view returns (uint parcelStatus) {
    return uint256(parcels[parcelId].parcelStatus);
  }

  /// @dev Change parcel's status
  /// @param parcelId the id of the parcel to set
  /// @param newStatus the new status. Possibilities: Registered, Ready, Sent, Queued, Received, Confirmed
  function setParcelStatus(bytes32 parcelId, Status newStatus) public onlyOwner returns (bool) {
    parcels[parcelId].parcelStatus = newStatus;
    if(uint256(newStatus) == 4) {
      parcels[parcelId].receivedTimeStamp = now;
    }
    emit SetParcelStatus(msg.sender, parcelId, newStatus);
  }

  /// @dev Function to get a specific parcel status
  /// @param parcelId The id to retreive the parcel data
  function getParcelDestLocation(bytes32 parcelId) public view returns (string memory destLocation) {
    return parcels[parcelId].destLocation;
  }

  /// @dev Change parcel's destination
  /// @param parcelId the id of the parcel to set
  /// @param newDestLocation the updated destination
  function setParcelDestLocation(bytes32 parcelId, string memory newDestLocation) public onlyOwner returns (bool) {
    parcels[parcelId].destLocation = newDestLocation;
    emit SetParcelDestLocation(msg.sender, parcelId, parcels[parcelId].id, newDestLocation);
  }

  /// @dev Function to get a specific parcel creation timestamp
  /// @param parcelId The id to retreive the parcel data
  function getParcelCreatedTimestamp(bytes32 parcelId) public view returns (uint timesTamp) {
    return parcels[parcelId].createdTimeStamp;
  }

  /// @dev Function to get a specific parcel expected timestamp
  /// @param parcelId The id to retreive the parcel data
  function getParcelExpectedTimestamp(bytes32 parcelId) public view returns (uint timeStamp) {
    return parcels[parcelId].expectedTimeStamp;
  }

  /// @dev Change parcel expectedTimeStamp
  /// @param parcelId the id of the parcel to set
  /// @param newTimestamp the new timestamp
  function setParcelExpectedTimeStamp(bytes32 parcelId, uint newTimestamp) public onlyOwner returns (bool) {
    if(newTimestamp == 0){
      newTimestamp == now;
    }
    parcels[parcelId].expectedTimeStamp = newTimestamp;
    emit SetParcelExpectedTimestamp(msg.sender, parcelId, parcels[parcelId].id, newTimestamp);
  }

  /// @dev Function to get a specific parcel status
  /// @param parcelId The id to retreive the parcel data
  function getParcelReceivedTimestamp(bytes32 parcelId) public view returns (uint timeStamp) {
    return parcels[parcelId].receivedTimeStamp;
  }

  /// @dev Change parcel's receivedTimestamp
  /// @param parcelId the id of the parcel to set
  /// @param newTimestamp the new timestamp
  function setParcelReceivedTimestamp(bytes32 parcelId, uint newTimestamp) public onlyOwner returns (bool) {
    if(newTimestamp == 0){
      newTimestamp == now;
    }
    parcels[parcelId].receivedTimeStamp = newTimestamp;
    emit SetParcelReceivedTimestamp(msg.sender, parcelId, parcels[parcelId].id, newTimestamp);
  }

  /// @dev Parcel shredder
  /// @param parcelId The id of the parcel
  function shredParcel(bytes32 parcelId) public onlyOwner returns (bool){
    delete(parcels[parcelId].parcelTracks);
    delete(parcels[parcelId].parcelManipulators);
    delete(parcels[parcelId].parcelIssues);
    delete(parcels[parcelId]);
    ParcelCount -= 1;
    emit RemoveParcel(msg.sender, parcelId);
    return true;
  }

  /*
  * GIS position relative functions
  */

  /// @dev Add a new GIS Distribution position
  /// @param parcelId The id of the parcel
  /// @param GISPosition The new global position of the parcel
  function addTrack(bytes32 parcelId, string memory GISPosition) public returns (bool){
       GpsTracks tracks = GpsTracks(parcels[parcelId].parcelTracks);
       tracks.addTrack(GISPosition);
  }

  /// @dev Get last parcel's position
  /// @param parcelId The id of the parcel
  function getTrack(bytes32 parcelId) public view returns (address lastTrack) {
    return address(GpsTracks(parcels[parcelId].parcelTracks));
  }

  /*
  * Liability chain relative functions
  */

  /// @dev Add a new responsible
  /// @param parcelId The id of the parcel
  /// @param responsibleAddress The address of the worker
  function addResponsible(bytes32 parcelId, bytes32 responsibleAddress) public returns (bool) {
    LiabilityChain responsibles = LiabilityChain(parcels[parcelId].parcelManipulators);
    responsibles.addResponsible(responsibleAddress);
  }

  /// @dev Get all responsibles
  /// @param parcelId The id of the parcel
  function getAllResponsibles(bytes32 parcelId) public returns (address responsiblesContract) {
    return address(parcels[parcelId].parcelManipulators);
  }

  /// @dev Get last responsible
  /// @param parcelId The id of the parcel
  function getLastResponsible(bytes32 parcelId, bytes32 responsibleId) public returns (bytes32 lastResponsibleWallet) {
    LiabilityChain headofResponsibles = LiabilityChain(parcels[parcelId].parcelManipulators);
    lastResponsibleWallet = headofResponsibles.getHeadOfResponsibles();
    return lastResponsibleWallet;
  }

  /*
  * Issue list relative functions
  */

  /// @dev Add a new issue to the list
  /// @param parcelId The id of the parcel
  /// @param emitterAddress The address of the worker
  function addIssue(address emitterAddress, bytes32 parcelId, string memory text) public returns (bool) {
    IssueChain chainofIssues = IssueChain(parcels[parcelId].parcelIssues);
    chainofIssues.addIssue(emitterAddress,text);
  }

  /// @dev Get all issues from the parcel
  /// @param parcelId The id of the parcel
  /// @param emitterAddress The wallet of the emitter
  function getAllIssues(bytes32 parcelId, bytes32 emitterAddress) public returns (address parcelIssuesContract) {
    IssueChain fullChain = IssueChain(parcels[parcelId].parcelIssues);
    return address(fullChain);
  }

  /// @dev Get last issue
  /// @param parcelId The id of the parcel
  function getLastIssue(bytes32 parcelId, bytes32 emmiterAddress) public returns (bytes32 lastIssue) {
    IssueChain lastIssueOfParcel = IssueChain(parcels[parcelId].parcelIssues);
    bytes32 lastIssue = lastIssueOfParcel.getLast();
    return lastIssue;
  }

  /*
  * Contract's destructor
  */
  /// @dev Contracts destructor
  function kill() public onlyOwner{
    selfdestruct(msg.sender);
  }
}


