...

mapping(address => bool) whitelistedAddresses;
bool public presaleOnly = true;

function presaleMint(uint qty) external payable {
        
        uint _maxPerWallet = maxPerWallet;
        require(whitelistedAddresses[msg.sender], "WL Only");
        require(balanceOf(msg.sender) + qty < _maxPerWallet, "Wallet Max");//balance in wallet + amount minting
        require(msg.value >= 25000000000000000 * qty, "Amount of Ether sent too small");
        require(qty < maxMint, "Greedy"); //Less than 10.
        require((_supply.current() + qty) < 5001, "SoldOut");
        
        for (uint i = 0; i < qty; i++) {
      _supply.increment();
      _mint(msg.sender, _supply.current());
    }
    
    //only owner
  function addUser(address  _addressToWhitelist) public onlyOwner {
    whitelistedAddresses[_addressToWhitelist] = true;
}

  function batchAddUsers(address[] memory _users) external onlyOwner{
      uint size = _users.length;
      for(uint i=0; i < size; i++){
          address user = _users[i];
          whitelistedAddresses[user] = true;
      }
  } 
