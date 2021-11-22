// SPDX-License-Identifier: MIT
pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyPFPlandv2 is ERC721Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter internal toyTokenIDs;
    CountersUpgradeable.Counter internal paintingTokenIDs;
    CountersUpgradeable.Counter internal statuetteTokenIDs;

    uint256 internal toyTokenIDBase;
    uint256 internal paintingTokenIDBase;
    uint256 internal statuetteTokenIDBase;

    address public _owner;
    bool public isOpenPayment;

    bool public isPausedClaimingToy;
    bool public isPausedClaimingPainting;
    bool public isPausedClaimingStatteute;

    mapping(address => uint256) internal addressToClaimedToy;
    mapping(address => uint256) internal addressToClaimedPainting;
    mapping(address => uint256) internal addressToClaimedStateutte;

    mapping(uint256 => bool) public oldTokenIDUsed;

    mapping(address => uint256) internal addressToMigratedCameo;
    mapping(address => uint256) internal addressToMigratedHonorary;
    
    mapping(address => uint256) internal addressToRoyalty;
    ERC721 blootNFT;

    struct Point {
        uint256 x;
        uint256 y;
    }

    struct Rectangle {
        Point leftBottom;
        Point rightTop;
    }

    struct LandMetadata {
        uint256 collectionID;
        uint256 tokenID;
    }

    struct LandDerivateMetadata {
        address collectionAddress;
        uint256 tokenID;
    }

    bool public allowMetadataForAllReserved;
    uint256 landWidth;
    uint256 landHeight;
    uint256 totalCollection;
    uint256 constant clearLow = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
    uint256 constant clearHigh = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
    uint256 constant factor = 0x100000000000000000000000000000000;
    mapping(address => mapping(uint256 => uint256)) public claimedLandOf;
    mapping(uint256 => address) public landOwnerOf;
    mapping(address => uint256) public claimedLandBalanceOf;
    mapping(address => uint256[]) internal landsOf;
    mapping(uint256 => LandMetadata) public landRoyalMetadataOf;
    mapping(uint256 => LandDerivateMetadata[]) public landDerivativeMetadataOf;
    mapping(uint256 => uint256) public landDerivativeCountOf;
    mapping(uint256 => address) public collectionAddressByIndex;
    mapping(address => uint256[]) public collectionIndicesByAddress;
    mapping(uint256 => Rectangle) public collectionRectByIndex;

    mapping(address => uint256) internal honoraries;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function initialize() initializer external {
        __ERC721_init("MyPFPland", "MyPFPland");
        _owner = msg.sender;

        toyTokenIDBase = 0;
        paintingTokenIDBase = 300;
        statuetteTokenIDBase = 400;
        // blootNFT = ERC721(0x72541Ad75E05BC77C7A92304225937a8F6653372);
        blootNFT = ERC721(0xCAccb157236B0969fe21eb486f2Bc5dc0662a5c5);
        landWidth = 100;
        landHeight = 100;
        totalCollection = 0;

        // 1- Bored Apes
        setCollectionRect(0, 0, 10, 10, 0x12860d0293bEfa056568506ba9D78971b5B6fa18);
        // 2- Cool Cats
        setCollectionRect(10, 10, 20, 20, 0xDB5B9D4003c6cf1AcbC1216E594ECfd835D8314C);
        // 3- Metaheroes
        setCollectionRect(10, 0, 20, 10, 0xC072c57C0B3a9671c711FEBbcED17d67d4644889);
        // 4- Deadfellaz
        setCollectionRect(0, 10, 10, 20, 0xa6A584D72580c2a35fe0845aAa7558FdeEF26946);
        // 5- Robotos
        setCollectionRect(20, 0, 30, 10, 0x7052936413285D673f518e17267877E1Eb88634f);
        // 6- Dogs Unchained
        setCollectionRect(20, 10, 30, 20, 0xcACcb157236B0969fe21eB486f2bC5dC0662A5c4);
        // 7- BlootElves
        setCollectionRect(30, 0, 40, 10, 0xCAccb157236B0969fe21eb486f2Bc5dc0662a5c5);
        // 8- Buttheads
        setCollectionRect(30, 10, 40, 20, 0xAF564d031279Ef148f09e2879E14F59B0E9a7846);
        // 9- 0n1
        setCollectionRect(0, 20, 10, 30, 0xbA8886bf3a6f0740e622AF240c54c9A6439DE0bE);
        // 10- Mekaverse
        setCollectionRect(10, 20, 20, 30, 0x69684Ca8500Ac25553719f46E40EBa31F47Bfc64);
        // 11- World of Women
        setCollectionRect(20, 20, 30, 30, 0xc4956736b60c2ce0693bAe380732a8156EAe8842);
        // 12- Fluf World
        setCollectionRect(30, 20, 40, 30, 0x287be825bCeCeD75C2AbbD313efe0E1DcB8C260a);
        // 13- Cryptotoadz
        setCollectionRect(40, 0, 50, 10, 0xcACCb157236B0969FE21eB486f2BC5Dc0662A5D1);
        // 14- Sup Ducks
        setCollectionRect(40, 10, 50, 20, 0xCaCcB157236B0969FE21eb486F2Bc5dC0662a5D2);
        // 15- Doodles
        setCollectionRect(40, 20, 50, 30, 0xCAcCB157236b0969fE21eB486f2bC5dc0662A5d3);
        // 16- BlootElves honorary
        setCollectionRect(0, 30, 10, 40, 0xCAccb157236B0969fe21eb486f2Bc5dc0662a5c5);
        // 17- Bored Apes
        setCollectionRect(10, 30, 20, 40, 0x12860d0293bEfa056568506ba9D78971b5B6fa18);
    }

    function claim(uint256 _category, uint256 _count) external payable {
        require(_category >= 1, "out of range");
        require(_category <= 3, "out of range");
        if (_category == 1)
            require(isPausedClaimingToy == false, "toy claiming is paused");
        if (_category == 2)
            require(isPausedClaimingPainting == false, "painting claiming is paused");
        if (_category == 3)
            require(isPausedClaimingStatteute == false, "statteute claiming is paused");
        
        uint256 totalDerivative = getTotalDerivative(msg.sender, _category);
        if (_category == 1)
            totalDerivative += addressToMigratedCameo[msg.sender];
        else if (_category == 2)
            totalDerivative += addressToMigratedHonorary[msg.sender];

        uint256 tokenID = 0;
        if (_category == 1)
            require(totalDerivative >= addressToClaimedToy[msg.sender] + _count, "already claimed all toys");
        else if (_category == 2)
            require(totalDerivative >= addressToClaimedPainting[msg.sender] + _count, "already claimed all paintings");
        else if (_category == 3)
            require(totalDerivative >= _count, "already claimed all statteutes");
    
        for (uint8 i = 0; i < _count; i++) {
            if (_category == 1) {
                toyTokenIDs.increment();
                tokenID = toyTokenIDs.current() + toyTokenIDBase;
            } else if (_category == 2) {
                paintingTokenIDs.increment();
                tokenID = paintingTokenIDs.current() + paintingTokenIDBase;
            } else if (_category == 3) {
                statuetteTokenIDs.increment();
                tokenID = statuetteTokenIDs.current() + statuetteTokenIDBase;
            }
            _safeMint(msg.sender, tokenID);
            _setTokenURI(tokenID, uint2str(tokenID));
        }

        if (_category == 1)
            addressToClaimedToy[msg.sender] += _count;
        else if (_category == 2)
            addressToClaimedPainting[msg.sender] += _count;

        // set oldTokenIDUsed true for those IDs already used
        if (totalDerivative > 0 && _category == 3) {
            for (uint8 i = 0; i < blootNFT.balanceOf(msg.sender); i++) {
                uint256 tokenId = blootNFT.tokenOfOwnerByIndex(msg.sender, i);
                if (tokenId <= 1484) {
                    oldTokenIDUsed[tokenId] = true;
                }
            }
        }
    }

    function airdrop(address[] calldata _claimList, uint256[] calldata _tokenIDs, uint256 _count) external onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            uint256 tokenID = 0;
            if (_tokenIDs[i] <= 300) {
                toyTokenIDs.increment();
                tokenID = toyTokenIDs.current() + toyTokenIDBase;

                addressToClaimedToy[_claimList[i]] += 1;
            } else if (_tokenIDs[i] <= 400) {
                paintingTokenIDs.increment();
                tokenID = paintingTokenIDs.current() + paintingTokenIDBase;

                addressToClaimedPainting[_claimList[i]] += 1;
            } else {
                statuetteTokenIDs.increment();
                tokenID = statuetteTokenIDs.current() + statuetteTokenIDBase;
            }
            _safeMint(_claimList[i], tokenID);
            _setTokenURI(tokenID, uint2str(tokenID));
            if (tokenID > 400) {
                for (uint256 j = 0; j < blootNFT.balanceOf(_claimList[i]); j++) {
                    uint256 tokenId = blootNFT.tokenOfOwnerByIndex(_claimList[i], j);
                    if (tokenId <= 1484)
                        oldTokenIDUsed[tokenId] = true;
                }
            }
        }
    }

    function getDerivativesToClaim(address _claimer, uint256 _category) external view returns(uint256) {
        uint256 remain = 0;
        if (_category < 1 || _category > 3)
            return remain;
        
        uint256 totalDerivative = getTotalDerivative(_claimer, _category);
        if (_category == 1) {
            totalDerivative += addressToMigratedCameo[_claimer];
            remain = totalDerivative - addressToClaimedToy[_claimer];
        }
        else if (_category == 2) {
            totalDerivative += addressToMigratedHonorary[_claimer];
            remain = totalDerivative - addressToClaimedPainting[_claimer];
        }
        else if (_category == 3) {
            remain = totalDerivative;
        }

        return remain;
    }

    function getTotalDerivative(address _claimer, uint256 _category) internal view returns(uint256) {
        uint256 result = 0;
        if (blootNFT.balanceOf(_claimer) == 0)
            return result;
        uint256 tokenIdMin;
        uint256 tokenIdMax;
        if (_category == 1) {
            tokenIdMin = 4790;
            tokenIdMax = 4962;
        } else if (_category == 2) {
            tokenIdMin = 4963;
            tokenIdMax = 5000;
        } else if (_category == 3) {
            tokenIdMin = 1;
            tokenIdMax = 1484;
        }

        for (uint256 i = 0; i < blootNFT.balanceOf(_claimer); i++) {
            uint256 tokenId = blootNFT.tokenOfOwnerByIndex(_claimer, i);
            if (tokenId >= tokenIdMin && tokenId <= tokenIdMax) {
                if (_category == 3) {
                    if (!oldTokenIDUsed[tokenId])
                        result++;
                }
                else
                    result++;
            }
        }

        return result;
    }

    function setPauseClaimingToy(bool _pauseClaimingToy) external onlyOwner {
        isPausedClaimingToy = _pauseClaimingToy;
    }

    function setPauseClaimingPainting(bool _pauseClaimingPainting) external onlyOwner {
        isPausedClaimingPainting = _pauseClaimingPainting;
    }

    function setPauseClaimingStatteute(bool _pauseClaimingStatteute) external onlyOwner {
        isPausedClaimingStatteute = _pauseClaimingStatteute;
    }

    function setBatchCameoWhitelist(address[] calldata _whitelist, uint256 _count) external onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            addressToMigratedCameo[_whitelist[i]] += 1;
        }
    }

    function setBatchHonoraryWhitelist(address[] calldata _whitelist, uint256 _count) external onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            addressToMigratedHonorary[_whitelist[i]] += 1;
        }
    }

    // additional honoraries, will be supplimentary for addressToMigratedHonorary
    function setBatchHonoraries(address[] calldata _whitelist, uint256 _count) external onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            honoraries[_whitelist[i]] += 1;
        }
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {
        super._setBaseURI(_baseURI);
    }

    function setTokenURI(uint256 _tokenID, uint256 _tokenURI) external onlyOwner {
        super._setTokenURI(_tokenID, uint2str(_tokenURI));
    }

    function setTokenURIs(uint256[] calldata _tokenIDs, uint256[] calldata _tokenURIs, uint256 _count) external onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            super._setTokenURI(_tokenIDs[i], uint2str(_tokenURIs[i]));
        }
    }

    function openPayment(bool _open) external onlyOwner {
        isOpenPayment = _open;
    }

    function setBatchRoyalty(address[] calldata _people, uint256[] calldata _amount, uint256 _count) external onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            addressToRoyalty[_people[i]] = _amount[i];
        }
    }

    function setRoyalty(address _person, uint256 _amount) external onlyOwner {
        addressToRoyalty[_person] = _amount;
    }

    function royaltyOf(address _person) external view returns(uint256) {
        return addressToRoyalty[_person];
    }

    function withdraw() external onlyOwner {
        (bool success, ) = _owner.call{value: address(this).balance}("");
        require(success, "Failed to send");
    }

    function withdrawRoyalty() external {
        require(isOpenPayment == true, "Payment is closed");
        require(addressToRoyalty[msg.sender] > 0, "You don't have any royalties");
        require(address(this).balance >= addressToRoyalty[msg.sender], "Insufficient balance in the contract");
        require(msg.sender != address(0x0), "invalid caller");

        (bool success, ) = msg.sender.call{value: addressToRoyalty[msg.sender]}("");
        require(success, "Failed to send eth");
        addressToRoyalty[msg.sender] = 0;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function claimLand(uint256 x, uint256 y, uint256 collectionID) external {
        require(x <= landWidth && y <= landHeight, "exceeds boundary");
        Rectangle memory area = collectionRectByIndex[collectionID];
        require(x > area.leftBottom.x && y > area.leftBottom.y && x <= area.rightTop.x && y <= area.rightTop.y, "not contained");

        address collectionAddress = collectionAddressByIndex[collectionID];
        uint256 claimable;
        if (collectionID == 15) { // honorary collection id
            claimable = addressToMigratedHonorary[msg.sender] + honoraries[msg.sender];
        } else {
            ERC721 collection = ERC721(collectionAddress);
            claimable = collection.balanceOf(msg.sender);
            if (collectionID == 6) // BlootElves collection id
                claimable -= (addressToMigratedHonorary[msg.sender] + honoraries[msg.sender]);
        }
        require(claimable > 0, "Don't own any NFT in this collection");
        require(claimedLandOf[msg.sender][collectionID] < claimable, "Already claimed all lands");
        uint256 assetID = _encodeTokenId(x, y);
        require(landOwnerOf[assetID] == address(0x0), "This land is already claimed");
        landOwnerOf[assetID] = msg.sender;
        landsOf[msg.sender].push(assetID);
        claimedLandBalanceOf[msg.sender] ++;
        uint256[] memory collectionIndices = collectionIndicesByAddress[collectionAddress];
        for (uint256 i = 0; i < collectionIndices.length; i++) {
            claimedLandOf[msg.sender][collectionIndices[i]] ++;
        }
    }

    function getLandOfByIndex(address claimer, uint256 index) external view returns(uint256) {
        return landsOf[claimer][index];
    }

    function updateLandRoyalMetaData(uint256 x, uint256 y, uint256 collectionIDOfRoyalMetadata, uint256 tokenID) external {
        require(x <= landWidth && y <= landHeight, "exceeds boundary");
        uint256 assetID = _encodeTokenId(x, y);
        require(landOwnerOf[assetID] == msg.sender, "You are not the owner of this land");
        if (!allowMetadataForAllReserved) {
            Rectangle memory area = collectionRectByIndex[collectionIDOfRoyalMetadata];
            require(x > area.leftBottom.x && y > area.leftBottom.y && x <= area.rightTop.x && y <= area.rightTop.y, "not contained");
        }
        address collectionAddress = collectionAddressByIndex[collectionIDOfRoyalMetadata];
        ERC721 collection = ERC721(collectionAddress);
        require(collection.ownerOf(tokenID) == msg.sender, "You are not the owner of this tokenID");
        LandMetadata memory royalMetadata;
        royalMetadata.collectionID = collectionIDOfRoyalMetadata;
        royalMetadata.tokenID = tokenID;
        landRoyalMetadataOf[assetID] = royalMetadata;
    }

    function updateLandDerivativeMetaData(uint256 x, uint256 y, address[] calldata collectionAddrsOfDerMetadata, uint256[] calldata tokenIDs, uint256 count) external {
        require(x <= landWidth && y <= landHeight, "exceeds boundary");
        uint256 assetID = _encodeTokenId(x, y);
        require(landOwnerOf[assetID] == msg.sender, "You are not the owner of this land");
        for (uint256 i = 0; i < count; i++) {
            ERC721 collection = ERC721(collectionAddrsOfDerMetadata[i]);
            require(collection.ownerOf(tokenIDs[i]) == msg.sender, "You are not the owner of this tokenID");
            LandDerivateMetadata memory derivativeMetadata;
            derivativeMetadata.collectionAddress = collectionAddrsOfDerMetadata[i];
            derivativeMetadata.tokenID = tokenIDs[i];
            landDerivativeMetadataOf[assetID].push(derivativeMetadata);
        }
    }

    function setAllowMetadataForAllReserved(bool _allowMetadataForAllReserved) external onlyOwner {
        allowMetadataForAllReserved = _allowMetadataForAllReserved;
    }

    function getLandMetaData(uint256 collectionID, uint256 tokenID) external view returns(string memory) {
        address collectionAddress = collectionAddressByIndex[collectionID];
        ERC721 collection = ERC721(collectionAddress);
        try collection.tokenURI(tokenID) returns(string memory tokenURI) {
            return tokenURI;
        } catch Error(string memory /*reason*/) {
            return "";
        }
    }

    function tokenIDByIndexInCollection(uint256 collectionID, address claimer, uint256 index) external view returns(uint256){
        address collectionAddress = collectionAddressByIndex[collectionID];
        ERC721 collection = ERC721(collectionAddress);
        try collection.tokenOfOwnerByIndex(claimer, index) returns(uint256 tokenID) {
            return tokenID;
        } catch Error(string memory /*reason*/) {
            return 100000;
        }
    }

    function tokenBalanceOfInCollection(uint256 collectionID, address claimer) external view returns(uint256){
        address collectionAddress = collectionAddressByIndex[collectionID];
        ERC721 collection = ERC721(collectionAddress);
        try collection.balanceOf(claimer) returns (uint256 balance) {
            return balance;
        } catch Error(string memory /*reason*/) {
            return 0;
        }
    }

    function collectionIDAndClaimerAt(uint256 x, uint256 y) external view returns (uint256, address) {
        uint256 collectionID;
        address claimer;
        if (x > landWidth || y > landHeight) {
            collectionID = 100000;
            claimer = address(0x0);
            return (collectionID, claimer);
        }
        uint256 assetID = _encodeTokenId(x, y);
        claimer = landOwnerOf[assetID];
        Rectangle memory area;
        Point memory pt;
        pt.x = x;
        pt.y = y;
        for (uint256 i = 0; i < totalCollection; i++) {
            area = collectionRectByIndex[i];
            if (isInsideCollectionRect(pt, area)) {
                collectionID = i;
                return (collectionID, claimer);
            }
        }
        collectionID = 100000;
        return (collectionID, claimer);
    }

    function isInsideCollectionRect(Point memory point, Rectangle memory area) public pure returns(bool) {
        if (point.x > area.leftBottom.x && point.y > area.leftBottom.y && point.x <= area.rightTop.x && point.y <= area.rightTop.y)
            return true;
        else
            return false;
    }

    function setCollectionRect(uint256 leftBottomX, uint256 leftBottomY, uint256 rightTopX, uint256 rightTopY, address collectionAddress) public onlyOwner {
        Rectangle memory area;
        area.leftBottom.x = leftBottomX;
        area.leftBottom.y = leftBottomY;

        area.rightTop.x = rightTopX;
        area.rightTop.y = rightTopY;
        collectionRectByIndex[totalCollection] = area;
        collectionAddressByIndex[totalCollection] = collectionAddress;
        collectionIndicesByAddress[collectionAddress].push(totalCollection);
        totalCollection ++;
    }

    function updateCollectionRect(uint256 leftBottomX, uint256 leftBottomY, uint256 rightTopX, uint256 rightTopY, address collectionAddress, uint256 collectionID) public onlyOwner {
        Rectangle memory area;
        area.leftBottom.x = leftBottomX;
        area.leftBottom.y = leftBottomY;

        area.rightTop.x = rightTopX;
        area.rightTop.y = rightTopY;
        collectionRectByIndex[collectionID] = area;
        collectionAddressByIndex[collectionID] = collectionAddress;
    }

    function _encodeTokenId(uint256 x, uint256 y) public pure returns (uint256) {
        return ((uint256(x) * factor) & clearLow) | (uint256(y) & clearHigh);
    }

    function _decodeTokenId(uint256 value) public pure returns (uint256 x, uint256 y) {
        x = expandNegative128BitCast((value & clearLow) >> 128);
        y = expandNegative128BitCast(value & clearHigh);
    }

    function expandNegative128BitCast(uint256 value) internal pure returns (uint256) {
        if (value & ( 1 << 127) != 0) {
            return uint256(value | clearLow);
        }
        return uint256(value);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
