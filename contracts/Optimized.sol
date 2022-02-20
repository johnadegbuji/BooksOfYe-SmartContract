// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract BooksOfYe is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
    struct SaleEvent {
        uint price;
        uint minCardId;
        uint maxCardId;
        uint whitelistCount;
        bool isActive;
        bool isPreSale;
        bool isPublicSale;
        mapping(address => bool) whitelist;
        
    }

    SaleEvent[] saleEvents;

    uint public  maxSupply = 1000;
    uint public constant mintLimit = 8;
    string public baseURI;


    mapping(uint => string) private _URIS;
    mapping(address => uint128) public cardPurchaseTracker;
    mapping(address => bool) private luckTracker;
    mapping(address => uint) public tokenOwners;

    constructor() ERC1155(baseURI) {
        SaleEvent storage saleEvent1 = saleEvents.push();
        SaleEvent storage saleEvent2 = saleEvents.push();
        SaleEvent storage saleEvent3 = saleEvents.push();
        SaleEvent storage saleEvent4 = saleEvents.push();
        SaleEvent storage saleEvent5 = saleEvents.push();
    }

    //Public Functions

    function preSaleMint(uint eventNumber, uint cardId) public payable {
        uint nextEventNumber = eventNumber + 1;
        uint counter = saleEvents[nextEventNumber].whitelistCount;
        uint price = saleEvents[eventNumber].price;
        uint minCardId = saleEvents[eventNumber].minCardId;
        uint maxCardId = saleEvents[eventNumber].maxCardId;

        require(
            saleEvents[eventNumber].whitelist[msg.sender],
            "You Aren't On The Whitelist"
        );
        require(saleEvents[eventNumber].isActive, "Sale Is Not Active");
        require(
            saleEvents[eventNumber].isPreSale ||
                saleEvents[eventNumber].isPublicSale,
            "PreSale Not Live"
        );
        require(
            cardId >= minCardId && cardId <= maxCardId,
            "Card Not For Sale"
        );
        require(maxSupply - 1 >= 0, "Sold Out");
        require(!exists(cardId), "Card Is Already Minted");
        require(
            cardPurchaseTracker[msg.sender] != mintLimit,
            "Mint Limit Reached"
        );
        require(msg.value >= price, "Not Enough Ether Sent");

        _mint(msg.sender, cardId, 1, "");

        
        maxSupply = maxSupply - 1;
        cardPurchaseTracker[msg.sender] = cardPurchaseTracker[msg.sender] + 1;
        if (cardId == 0) {
            luckTracker[msg.sender] = true;
        }
        if (cardId == 200) {
            luckTracker[msg.sender] = true;
        }
        if (cardId == 400) {
            luckTracker[msg.sender] = true;
        }
        if (cardId == 600) {
            luckTracker[msg.sender] = true;
        }
        if (cardId == 800) {
            luckTracker[msg.sender] = true;
        }
        if (nextEventNumber <= 4) {
            saleEvents[nextEventNumber].whitelist[msg.sender] = true;
            saleEvents[nextEventNumber].whitelistCount = counter + 1;
        }
    }

    function publicMint(uint eventNumber, uint cardId) public payable {
        uint nextEventNumber = eventNumber + 1;
        uint counter = saleEvents[nextEventNumber].whitelistCount;
        uint price = saleEvents[eventNumber].price;
        uint minCardId = saleEvents[eventNumber].minCardId;
        uint maxCardId = saleEvents[eventNumber].maxCardId;

        require(saleEvents[eventNumber].isActive, "Sale Is Not Active");
        require(
            saleEvents[eventNumber].isPreSale ||
                saleEvents[eventNumber].isPublicSale,
            "PreSale Not Live"
        );
        require(
            cardId >= minCardId && cardId <= maxCardId,
            "Card Not For Sale"
        );
        require(maxSupply - 1 >= 0, "Sold Out");
        require(!exists(cardId), "Card Is Already Minted");
        require(
            cardPurchaseTracker[msg.sender] != mintLimit,
            "Mint Limit Reached"
        );
        require(msg.value >= price, "Not Enough Ether Sent");

        _mint(msg.sender, cardId, 1, "");

        
        maxSupply = maxSupply - 1;
        cardPurchaseTracker[msg.sender] = cardPurchaseTracker[msg.sender] + 1;
        if (cardId == 0) {
            luckTracker[msg.sender] = true;
        }
        if (cardId == 200) {
            luckTracker[msg.sender] = true;
        }
        if (cardId == 400) {
            luckTracker[msg.sender] = true;
        }
        if (cardId == 600) {
            luckTracker[msg.sender] = true;
        }
        if (cardId == 800) {
            luckTracker[msg.sender] = true;
        }
        if (nextEventNumber < 5) {
            saleEvents[nextEventNumber].whitelist[msg.sender] = true;
            saleEvents[nextEventNumber].whitelistCount = counter + 1;
        }
    }

    function checkWhitelist(uint128 eventNumber, address _address)
        public
        view
        returns (bool isUserWL)
    {
        isUserWL = saleEvents[eventNumber].whitelist[_address];
        return isUserWL;
    }

    //Only Owner Functions

    function setPriceAndInventory() public onlyOwner {
        saleEvents[0].price = 200000000000000000;
        saleEvents[1].price = 600000000000000000;
        saleEvents[2].price = 1800000000000000000;
        saleEvents[3].price = 5400000000000000000;
        saleEvents[4].price = 16200000000000000000;
        saleEvents[0].minCardId = 0;
        saleEvents[1].minCardId = 200;
        saleEvents[2].minCardId = 400;
        saleEvents[3].minCardId = 600;
        saleEvents[4].minCardId = 800;
        saleEvents[0].maxCardId = 199;
        saleEvents[1].maxCardId = 399;
        saleEvents[2].maxCardId = 599;
        saleEvents[3].maxCardId = 799;
        saleEvents[4].maxCardId = 999;
    }

    function batchGiftMint(
        address[] memory _addresses,
        uint[] memory cardId,
        uint addToWhichWhitelist
    ) public onlyOwner {
        for (uint128 i = 0; i < _addresses.length; i++) {
            require(
                cardId[i] < 1000,
                "The Card Number Selected Does Not Exist"
            );
            require(
                maxSupply - cardId.length >= 0,
                "Sorry, There Aren't Anymore Available Cards"
            );
            require(
                !exists(cardId[i]),
                "A Card Selected Already Belongs To Someone Else"
            );

            _mint(_addresses[i], cardId[i], 1, "0x");
            maxSupply = maxSupply - cardId.length;
            
            saleEvents[addToWhichWhitelist].whitelist[_addresses[i]] = true;
            saleEvents[addToWhichWhitelist].whitelistCount =
                saleEvents[addToWhichWhitelist].whitelistCount +
                1;
        }
    }

    function editMinMaxCardId(uint eventNumber, uint _newMin, uint _newMax) public onlyOwner {
        require(
            _newMin >= 0 && _newMin < 999,
            "Your new minimum is either below 0 or over 999"
        );
        require(
            _newMax >= 0 && _newMax < 999,
            "Your new maximum is either below 0 or over 999"
        );
        require(
            _newMin != _newMax,
            "Your minimum and maximum cannot be the same number"
        );

        saleEvents[eventNumber].minCardId = _newMin;
        saleEvents[eventNumber].maxCardId = _newMax;
    }

    function editSaleStatus(
        uint eventNumber,
        bool _isActive,
        bool _isPreSale,
        bool _isPublicSale
    ) public onlyOwner {
        require(eventNumber <= 4);
        saleEvents[eventNumber].isActive = _isActive;
        saleEvents[eventNumber].isPreSale = _isPreSale;
        saleEvents[eventNumber].isPublicSale = _isPublicSale;
    }

   

 

    function editSalePrice(uint eventNumber, uint _newPriceInWei)
        public
        onlyOwner
    {
        require(eventNumber < 5);
        saleEvents[eventNumber].price = _newPriceInWei;
    }

    function batchAddToWhitelist(address[] memory _addresses, uint eventNumber) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            saleEvents[eventNumber].whitelist[_addresses[i]] = true;
            saleEvents[eventNumber].whitelistCount = saleEvents[eventNumber].whitelistCount +1;
        }
    }

    function batchRemoveFromWhitelist(
        address[] memory _addresses,
        uint128 eventNumber
    ) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            require(
                saleEvents[eventNumber].whitelist[_addresses[i]] != false,
                "One of these users is already not on WL. Use the Check WhiteList function to solve"
            );
            saleEvents[eventNumber].whitelist[_addresses[i]] = false;
            saleEvents[eventNumber].whitelistCount =
                saleEvents[eventNumber].whitelistCount -
                1;
        }
    }

    function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }

    function setTokenURI(string memory _newURI) public onlyOwner {
        baseURI = _newURI;
    }

    function contractURI() public pure returns (string memory) {
        return "ipfs://QmcCVnnRiy7TAgREHxKJJrcZLCSBmz2fYm1Lum5vjVY6Ge";
    }

    //Misc Functions

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    fallback() external payable {}

    receive() external payable {}
}
