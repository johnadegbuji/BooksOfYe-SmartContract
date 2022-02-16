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
        mapping(uint256 => bool) cardsForSale;
        mapping(address => bool) whitelist;
        uint256 whitelistCount;
    }
    SaleEvent[] saleEvents;

    uint256 public maxSupply = 1000;
    uint256 public mintLimit = 8;
    string public baseURI;

    mapping(uint256 => string) private _URIS;
    mapping(address => uint256) private cardPurchaseTracker;
    mapping(uint256 => address) public tokenOwners;

    constructor() ERC1155(baseURI) {
        SaleEvent storage saleEvent1 = saleEvents.push();
        SaleEvent storage saleEvent2 = saleEvents.push();
        SaleEvent storage saleEvent3 = saleEvents.push();
        SaleEvent storage saleEvent4 = saleEvents.push();
        SaleEvent storage saleEvent5 = saleEvents.push();

        for (uint256 i = 0; i <= 4; i++) {
            saleEvents[i].isPreSale = false;
            saleEvents[i].isPublicSale = false;
        }

        for (uint256 i = 0; i <= 199; i++) {
            saleEvent1.cardsForSale[i] = true;
            saleEvent1.price = 200000000000000000;
        }
        for (uint256 i = 200; i <= 399; i++) {
            saleEvent2.cardsForSale[i] = true;
            saleEvent2.price = 600000000000000000;
        }
        for (uint256 i = 400; i <= 599; i++) {
            saleEvent3.cardsForSale[i] = true;
            saleEvent3.price = 1800000000000000000;
        }
        for (uint256 i = 600; i <= 799; i++) {
            saleEvent4.cardsForSale[i] = true;
            saleEvent4.price = 5400000000000000000;
        }
        for (uint256 i = 800; i <= 999; i++) {
            saleEvent5.cardsForSale[i] = true;
            saleEvent5.price = 16200000000000000000;
        }
    }

    //Public Functions

    function preSaleMint(uint256 eventNumber, uint256 cardId) public payable {
        uint256 nextEventNumber = eventNumber + 1;
        uint256 price = saleEvents[eventNumber].price;

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
            saleEvents[eventNumber].cardsForSale[cardId],
            "This Card Is Not For Sale"
        );
        require(cardId < 1000, "The Card Number Selected Does Not Exist");
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

        _mint(msg.sender, cardId, 1, "");
        tokenOwners[cardId] = msg.sender;
        maxSupply = maxSupply - 1;
        cardPurchaseTracker[msg.sender] = cardPurchaseTracker[msg.sender] + 1;

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

        require(saleEvents[eventNumber].isActive, "Sale Is Not Active");
        require(
            !saleEvents[eventNumber].isPreSale &&
                saleEvents[eventNumber].isPublicSale,
            "Public Sale Is Not Live"
        );
        require(
            saleEvents[eventNumber].cardsForSale[cardId],
            "This Card Is Not For Sale"
        );
        require(cardId < 1000, "The Card Number Selected Does Not Exist");
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

        _mint(msg.sender, cardId, 1, "");
        tokenOwners[cardId] = msg.sender;
        maxSupply = maxSupply - 1;
        cardPurchaseTracker[msg.sender] = cardPurchaseTracker[msg.sender] + 1;

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
            "You Don't Have This Card In Your Wallet."
        );
        require(
            !saleEvents[eventNumber].isActive,
            "Please Wait For The Current Sale To Be Over."
        );

        for (uint256 i = 0; i <= 4; i++) {
            if (saleEvents[i].whitelist[previousHolder]) {
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

    function giftMint(
        address _address,
        uint256 cardId,
        uint256 addToWhichWhitelist
    ) public onlyOwner {
        require(cardId < 1000, "The Card Number Selected Does Not Exist");
        require(
            maxSupply - 1 >= 0,
            "Sorry, There Aren't Anymore Available Cards"
        );
        require(
            !exists(cardId),
            "Sorry This Card Already Belongs To Someone Else"
        );

        _mint(_address, cardId, 1, "");
        tokenOwners[cardId] = _address;
        maxSupply = maxSupply - 1;
        saleEvents[addToWhichWhitelist].whitelist[_address] = true;
        saleEvents[addToWhichWhitelist].whitelistCount =
            saleEvents[addToWhichWhitelist].whitelistCount +
            1;
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
                "Sorry This Card Already Belongs To Someone Else"
            );

            _mint(_addresses[i], cardId[i], 1, "");
            maxSupply = maxSupply - cardId.length;
            tokenOwners[cardId[i]] = _addresses[i];
            saleEvents[addToWhichWhitelist].whitelist[_addresses[i]] = true;
            saleEvents[addToWhichWhitelist].whitelistCount =
                saleEvents[addToWhichWhitelist].whitelistCount +
                1;
        }
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
            bool isPublicSale
        )
    {
        price = saleEvents[eventNumber].price;
        whitelistCount = saleEvents[eventNumber].whitelistCount;
        isActive = saleEvents[eventNumber].isActive;
        isPreSale = saleEvents[eventNumber].isPreSale;
        isPublicSale = saleEvents[eventNumber].isPublicSale;
        return (price, whitelistCount, isActive, isPreSale, isPublicSale);
    }

    function editSalePrice(uint256 eventNumber, uint256 _newPriceInWei)
        public
        onlyOwner
    {
        require(eventNumber <= 4);
        saleEvents[eventNumber].price = _newPriceInWei;
    }

    function addCardToSale(uint256 eventNumber, uint256 cardId)
        public
        onlyOwner
    {
        require(eventNumber <= 4);
        require(!saleEvents[eventNumber].cardsForSale[cardId]);
        saleEvents[eventNumber].cardsForSale[cardId] = true;
    }

    function removeCardFromSale(uint256 eventNumber, uint256 cardId)
        public
        onlyOwner
    {
        require(eventNumber <= 4);
        require(saleEvents[eventNumber].cardsForSale[cardId]);
        saleEvents[eventNumber].cardsForSale[cardId] = false;
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
            saleEvents[eventNumber].whitelist[_addresses[i]] = false;
            saleEvents[eventNumber].whitelistCount =
                saleEvents[eventNumber].whitelistCount -
                1;
        }
    }

    function addToWhitelist(address _address, uint256 eventNumber)
        public
        onlyOwner
    {
        saleEvents[eventNumber].whitelist[_address] = true;
        saleEvents[eventNumber].whitelistCount =
            saleEvents[eventNumber].whitelistCount +
            1;
    }

    function removeFromWhitelist(address _address, uint256 eventNumber)
        public
        onlyOwner
    {
        saleEvents[eventNumber].whitelist[_address] = false;
        saleEvents[eventNumber].whitelistCount =
            saleEvents[eventNumber].whitelistCount -
            1;
    }

    function withdraw(address payable _to) public onlyOwner {
        require(_to != address(0), "Token cannot be zero address.");
        _to.transfer(address(this).balance);
    }

    function setURI(string memory _newURI) public onlyOwner {
        baseURI = _newURI;
    }

    //Misc Functions

    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (bytes(_URIS[_tokenId]).length != 0) {
            return string(_URIS[_tokenId]);
        }
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(_tokenId), ".json")
            );
    }

    function contractURI() public pure returns (string memory) {
        return "ipfs://QmTWdWZU6NdNbcQxgssujLo6Ma6EkWxoFFcCmgWrAmLoh1";
    }

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
