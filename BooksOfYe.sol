// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract BooksOfYe is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
    struct SaleEvent {
        uint256 price;
        bool isActive;
        bool isPreSale;
        bool isPublicSale;
        uint256 minCardId;
        uint256 maxCardId;
        mapping(address => bool) whitelist;
        uint256 whitelistCount;
    }
    SaleEvent[] saleEvents;

    uint256 public maxSupply = 1000;
    uint256 public mintLimit = 8;
    string public baseURI;

    mapping(uint256 => string) private _URIS;
    mapping(address => uint256) public cardPurchaseTracker;
    mapping(address => bool) private luckTracker;
    mapping(uint256 => address) public tokenOwners;

    constructor() ERC1155(baseURI) {
        SaleEvent storage saleEvent1 = saleEvents.push();
        SaleEvent storage saleEvent2 = saleEvents.push();
        SaleEvent storage saleEvent3 = saleEvents.push();
        SaleEvent storage saleEvent4 = saleEvents.push();
        SaleEvent storage saleEvent5 = saleEvents.push();
    }

    //Public Functions

    function preSaleMint(uint256 eventNumber, uint256 cardId) public payable {
        uint256 nextEventNumber = eventNumber + 1;
        uint256 price = saleEvents[eventNumber].price;
        uint256 minCardId = saleEvents[eventNumber].minCardId;
        uint256 maxCardId = saleEvents[eventNumber].maxCardId;
        require(saleEvents[eventNumber].isActive, "Sale Is Not Active");
        require(
            saleEvents[eventNumber].isPreSale &&
                !saleEvents[eventNumber].isPublicSale,
            "PreSale Is Not Live"
        );
        require(
            saleEvents[eventNumber].whitelist[msg.sender],
            "Sorry You Aren't On The Whitelist"
        );
        require(
            cardId >= minCardId && cardId <= maxCardId,
            "This Card Is Not For Sale Or Doesn't Exist"
        );
        require(
            maxSupply - 1 >= 0,
            "Sorry, There Aren't Anymore Available Cards"
        );
        require(
            !exists(cardId),
            "Sorry This Card Is Already Minted By Someone Else"
        );
        require(
            cardPurchaseTracker[msg.sender] != mintLimit,
            "Sorry, You've Hit The Mint Limit"
        );
        require(msg.value >= price, "You Didn't Send Enough Ether");

        if (luckTracker[msg.sender]) {
            cardId = cardId + 1;
        }

        _mint(msg.sender, cardId, 1, "");

        tokenOwners[cardId] = msg.sender;
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
            saleEvents[nextEventNumber].whitelistCount =
                saleEvents[nextEventNumber].whitelistCount +
                1;
        }
    }

    function publicMint(uint256 eventNumber, uint256 cardId) public payable {
        uint256 nextEventNumber = eventNumber + 1;
        uint256 price = saleEvents[eventNumber].price;
        uint256 minCardId = saleEvents[eventNumber].minCardId;
        uint256 maxCardId = saleEvents[eventNumber].maxCardId;

        require(saleEvents[eventNumber].isActive, "Sale Is Not Active");
        require(
            !saleEvents[eventNumber].isPreSale &&
                saleEvents[eventNumber].isPublicSale,
            "Public Sale Is Not Live"
        );
        require(
            cardId >= minCardId && cardId <= maxCardId,
            "This Card Is Not For Sale Or Doesn't Exist"
        );
        require(
            maxSupply - 1 >= 0,
            "Sorry, There Aren't Anymore Available Cards"
        );
        require(
            !exists(cardId),
            "Sorry This Card Is Already Minted By Someone Else"
        );
        require(
            cardPurchaseTracker[msg.sender] != mintLimit,
            "Sorry, You've Hit The Mint Limit"
        );

        require(msg.value >= price, "You Didn't Send Enough Ether");

        if (luckTracker[msg.sender]) {
            cardId = cardId + 1;
        }

        _mint(msg.sender, cardId, 1, "");

        tokenOwners[cardId] = msg.sender;
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
            saleEvents[nextEventNumber].whitelistCount =
                saleEvents[nextEventNumber].whitelistCount +
                1;
        }
    }

    function activateCardPerks(uint256 cardId, uint256 eventNumber) public {
        address previousHolder = tokenOwners[cardId];
        require(
            balanceOf(msg.sender, cardId) > 0,
            "You Don't Have Any Cards In Your Wallet."
        );
        require(
            !saleEvents[eventNumber].isActive,
            "Please Wait For The Current Sale To Be Over."
        );

        for (uint256 i = 0; i <= 4; i++) {
            if (
                saleEvents[i].whitelist[previousHolder] &&
                saleEvents[i].whitelistCount != 0
            ) {
                saleEvents[i].whitelistCount = saleEvents[i].whitelistCount - 1;
            }
            saleEvents[i].whitelist[previousHolder] = false;
        }
        tokenOwners[cardId] = msg.sender;
        saleEvents[eventNumber].whitelist[msg.sender] = true;
    }

    function checkWhitelist(uint256 eventNumber, address _address)
        public
        view
        returns (bool isUserWL)
    {
        isUserWL = saleEvents[eventNumber].whitelist[_address];
        return isUserWL;
    }

    function checkTokenOwners(uint256 cardId)
        public
        view
        returns (address ownerOfToken)
    {
        ownerOfToken = tokenOwners[cardId];
        return ownerOfToken;
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
        uint256[] memory cardId,
        uint256 addToWhichWhitelist
    ) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
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
            tokenOwners[cardId[i]] = _addresses[i];
            saleEvents[addToWhichWhitelist].whitelist[_addresses[i]] = true;
            saleEvents[addToWhichWhitelist].whitelistCount =
                saleEvents[addToWhichWhitelist].whitelistCount +
                1;
        }
    }

    function editSaleMinCardId(
        uint256 eventNumber,
        uint256 _newMin,
        uint256 _newMax
    ) public onlyOwner {
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
        uint256 eventNumber,
        bool _isActive,
        bool _isPreSale,
        bool _isPublicSale
    ) public onlyOwner {
        require(eventNumber <= 4);
        saleEvents[eventNumber].isActive = _isActive;
        saleEvents[eventNumber].isPreSale = _isPreSale;
        saleEvents[eventNumber].isPublicSale = _isPublicSale;
    }

    function alterMintLimit(uint256 newLimit) public onlyOwner {
        mintLimit = newLimit;
    }

    function viewSaleStatus(uint256 eventNumber)
        public
        view
        onlyOwner
        returns (
            uint256 price,
            uint256 whitelistCount,
            bool isActive,
            bool isPreSale,
            bool isPublicSale,
            uint256 minCardId,
            uint256 maxCardId
        )
    {
        price = saleEvents[eventNumber].price;
        whitelistCount = saleEvents[eventNumber].whitelistCount;
        isActive = saleEvents[eventNumber].isActive;
        isPreSale = saleEvents[eventNumber].isPreSale;
        isPublicSale = saleEvents[eventNumber].isPublicSale;
        minCardId = saleEvents[eventNumber].minCardId;
        maxCardId = saleEvents[eventNumber].maxCardId;
        return (
            price,
            whitelistCount,
            isActive,
            isPreSale,
            isPublicSale,
            minCardId,
            maxCardId
        );
    }

    function editSalePrice(uint256 eventNumber, uint256 _newPriceInWei)
        public
        onlyOwner
    {
        require(eventNumber <= 4);
        saleEvents[eventNumber].price = _newPriceInWei;
    }

    function batchAddToWhitelist(
        address[] memory _addresses,
        uint256 eventNumber
    ) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            saleEvents[eventNumber].whitelist[_addresses[i]] = true;
            saleEvents[eventNumber].whitelistCount =
                saleEvents[eventNumber].whitelistCount +
                1;
        }
    }

    function batchRemoveFromWhitelist(
        address[] memory _addresses,
        uint256 eventNumber
    ) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
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

    function withdraw(address payable _to) public onlyOwner {
        require(_to != address(0), "Token cannot be zero address.");
        _to.transfer(address(this).balance);
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
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    fallback() external payable {}

    receive() external payable {}
}
