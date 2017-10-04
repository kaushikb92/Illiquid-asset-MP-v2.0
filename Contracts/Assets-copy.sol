pragma solidity ^0.4.8;


contract Assets{

    /* This will create an array of stracures to hold asset details*/ 
    assetDetails[] public Assets;

    /* Stracture to hold each user's details*/
    mapping(bytes32=> assetDetails) public assetDetailsByAID;
    mapping(address=> bytes32) public assetWalletAddress;
    mapping(address=> mapping(bytes32=>bool)) public assetVisibility;
    mapping(address=> mapping(bytes32=>uint)) public assetQuantityOfOwner;
    mapping(address=> mapping(bytes32=>uint256)) public assetPrice;

    /* Stracture to hold traded assets ids*/
    struct assetByOwner{
        bytes32[] AID;
    }

    /* Map to link traded asset ids for separate wallet addresses*/
    mapping(address => assetByOwner) assetsByOwner;

    /* Stracture to hold asset details*/
    struct assetDetails{
        bytes32 assetName;
        bytes32 assetType;
        address holder;
        bytes32 assetID;
        uint blockTime;
    }

    /* Function to register a new asset*/
    function addNewAsset(address _ownerOfAsset, bytes32 _assetName, uint _quantity, uint256 _priceOfEach, bytes32 _assetType, bytes32 _assetID) returns (bool addAsset_Status){

        assetDetails memory newRegdAsset;
        newRegdAsset.assetName = _assetName;
        newRegdAsset.assetType = _assetType;
        newRegdAsset.holder = _ownerOfAsset;
        newRegdAsset.assetID = _assetID;
        newRegdAsset.blockTime = block.timestamp;
        Assets.push(newRegdAsset);

        assetVisibility[_ownerOfAsset][_assetID] = true;
        assetDetailsByAID[_assetID] = newRegdAsset;
        assetWalletAddress[_ownerOfAsset] = _assetID;
        assetQuantityOfOwner[_ownerOfAsset][_assetID] = _quantity;
        assetPrice[_assetID] = _priceOfEach;
        assetsByOwner[_ownerOfAsset].AID.push(_assetID);

        return true;
    }

    /* Function to link an asset id with buyer address after the trade is done*/
    function addAssetWithWalletAfterSell(address _newOwner, bytes32 _assetID) returns (bool success){
        uint length = assetsByOwner[_newOwner].AID.length;
        bytes32[] memory assetIDs = new bytes32[](length);
        uint count = 0;
        assetIDs = assetsByOwner[_newOwner].AID;

        for(uint i = 0; i<length; i++){

            if (assetIDs[i] == _assetID){
                count += 1;
            }
        }

        if (count < 1)
        {
            assetsByOwner[_newOwner].AID.push(_assetID);
            return true;
        }
        else
        {
            throw;
        }
    }

    /* Function to get all asset ids associted with an account address*/
    function getAssetIdsByAddress(address _owner) constant returns (bytes32[]){
        return (assetsByOwner[_owner].AID);
    }

    /* Function to query asset details by asset id an associated account address*/
    function getAssetDetailsByAssetIdAndAddress(address _owner, bytes32 _assetID) constant returns (bytes32,bytes32,uint,uint256,uint){
        bytes32 aName = assetDetailsByAID[_assetID].assetName;
        bytes32 aType = assetDetailsByAID[_assetID].assetType;
        uint aQuantity = assetQuantityOfOwner[_owner][_assetID];
        uint256 aRate = assetPrice[_assetID];
        uint timestamp = assetDetailsByAID[_assetID].blockTime;
        return (aName,aType,aQuantity,aRate,timestamp);
    }

    /* Function to get all registered asset details */
    function getAllAssetDetails() constant returns(bytes32[], address[],bytes32[],bytes32[],uint256[],uint[]){
    uint length = Assets.length;
    bytes32[] memory assetIDs = new bytes32[](length);
    bytes32[] memory assetNames = new bytes32[](length);
    bytes32[] memory assetTypes = new bytes32[](length);
    address[] memory assetHolders = new address[](length);
    uint256[] memory assetPrices = new uint256[](length);
    uint[] memory assetQuantities = new uint[](length);
    
        for (var i = 0; i < length; i++) {

            assetDetails memory currentAsset;
            currentAsset = Assets[i];
            
            if(assetVisibility[currentAsset.holder][currentAsset.assetID])
            {
                assetIDs[i] = currentAsset.assetID;
                assetHolders[i] = currentAsset.holder;
                assetTypes[i] = currentAsset.assetType;
                assetNames[i] = currentAsset.assetName;
                assetPrices[i] = assetPrice[currentAsset.assetID];
                assetQuantities[i] = assetQuantityOfOwner[currentAsset.holder][currentAsset.assetID];
             }
        }
        return(assetIDs,assetHolders,assetTypes,assetNames,assetPrices,assetQuantities);
    }

    /* Function to get the number of assets associated with an single account address*/
    function getNoOfAssetRegisteredByAddress(address _owner) constant returns(uint){
        return (assetsByOwner[_owner].AID.length);
    }

    /* Function to update the quantity of a asset by its asset id*/
    function updateAssetQuantityOfSeller(address _owner, bytes32 _assetID, uint256 _soldAmount) returns (bool success){
        if (assetQuantityOfOwner[_owner][_assetID] < _soldAmount)
        {
            return false;
        }
        else
        {
            assetQuantityOfOwner[_owner][_assetID] -= _soldAmount; 
            return true;
        }
    }

    /* Function to get all assetids, asset names and asse4t type associated by its associated wallet address*/ 
    function getAssetDetailsByAddress(address _owner) constant returns(bytes32[], bytes32[], bytes32[],uint[]){
        uint length = assetsByOwner[_owner].AID.length;
        bytes32[] memory assetIDs = new bytes32[](length);
        bytes32[] memory assetNames = new bytes32[](length);
        bytes32[] memory assetTypes = new bytes32[](length);
        address[] memory assetHolders = new address[](length);
        uint[] memory assetTimes = new uint [](length);
        assetIDs = assetsByOwner[_owner].AID;
        for(uint i = 0; i<length; i++)
        {
            bytes32 asid = assetIDs[i];
            assetNames[i] = assetDetailsByAID[asid].assetName;
            assetTypes[i] = assetDetailsByAID[asid].assetType;
            assetTimes[i] = assetDetailsByAID[asid].blockTime;
            }
        return (assetIDs,assetNames,assetTypes,assetTimes);
    }

    function getTimeStampByAssetID(bytes32 _assetID) constant returns (uint){
            return assetDetailsByAID[_assetID].blockTime;
    }

    function getHolderOfAsset(bytes32 _assetID) constant returns (address){
            return assetDetailsByAID[_assetID].holder;
    } 

    /* Function to get quantity available for an asset by its asset id and seller's wallet address*/
    function getAssetQuantitybyAssetID(address _owner, bytes32 _assetID) constant returns (uint){
    return assetQuantityOfOwner[_owner][_assetID];
    }

    /* Function to get asset price by its asset id*/
    function getEachAssetPricebyAssetID(bytes32 _assetID) constant returns (uint256){
            return assetPrice[_assetID];
    }

    /* Function to list an asset in marketplace*/
    function enableVisibility(address _owner, bytes32 _assetID) returns (bool success){
        if (!assetVisibility[_owner][_assetID])
        {
            assetVisibility[_owner][_assetID] = true;
        }
        else
        {
            throw;
        }
        return true;
    }

    /* Function to remove an asset from marketplace list by its assetid and seller's address*/
    function disableVisibility(address _owner, bytes32 _assetID) returns (bool success){
        if (assetVisibility[_owner][_assetID])
        {
            assetVisibility[_owner][_assetID] = false;
        }
        else
        {
            throw;
        }
        return true;
    }

    /* Function to get all registered asset ids*/
    function getAssetIds() constant returns (bytes32[]){
        uint length = Assets.length;
        bytes32[] memory assetIDs = new bytes32[](length);
    
        for (var i = 0; i < length; i++) 
        {
            assetDetails memory currentAsset;
            currentAsset = Assets[i];
            assetIDs[i] = currentAsset.assetID;       
        }
        return assetIDs;
    }

    /* Function to get all registered asset names*/
    function getAssetNames() constant returns (bytes32[]){
        uint length = Assets.length;
        bytes32[] memory assetNames = new bytes32[](length); 
        
        for (var i = 0; i < length; i++) 
        {
                assetDetails memory currentAsset;
                currentAsset = Assets[i];
                assetNames[i] = currentAsset.assetName;
        }
        return assetNames;
    }

    /* Function to get all asset details by asset id*/
    function getAssetsDetailsByAssetIds(bytes32 _assetID) constant returns (bytes32[] , bytes32[], bytes32[], address[], uint256[] , uint[] ){
        uint length = Assets.length;
        bytes32[] memory assetNames = new bytes32[](length);
        bytes32[] memory assetTypes = new bytes32[](length);
        bytes32[] memory assetIDs = new bytes32[](length);
        address[] memory assetHolders = new address[](length);
        uint256[] memory assetPrices = new uint256[](length);
        uint[] memory assetQuantities = new uint[](length);
        
        for (var i = 0; i < length; i++) 
        {
            assetDetails memory currentAsset;
            currentAsset = Assets[i];
            assetNames[i] = currentAsset.assetName;
            assetTypes[i] = currentAsset.assetType;
            assetIDs[i] = currentAsset.assetID;
            assetHolders[i] = currentAsset.holder;
            assetPrices[i] = assetPrice[currentAsset.assetID];
            assetQuantities[i] = assetQuantityOfOwner[currentAsset.holder][currentAsset.assetID];
        }
        return(assetNames, assetTypes, assetIDs,assetHolders,assetPrices,assetQuantities);
    }

    /* Function to get asset name by asset id*/
    function getAssetNamebyAssetID(bytes32 _assetID) constant returns (bytes32){
        uint length = Assets.length;
        for (var i = 0; i < length; i++) 
        {
            assetDetails memory currentAsset;
            currentAsset = Assets[i];
            if(currentAsset.assetID == _assetID)
            {
                return (currentAsset.assetName);
            }
        }
    }

    /* Function to get asset type by asset id*/
    function getAssetTypebyAssetID(bytes32 _assetID) constant returns (bytes32){
        uint length = Assets.length;
        for (var i = 0; i < length; i++) 
        {
            assetDetails memory currentAsset;
            currentAsset = Assets[i];
            if(currentAsset.assetID == _assetID)
            {
                return (currentAsset.assetType);
            }
        }
    }
}