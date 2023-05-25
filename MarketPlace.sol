// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "hardhat/console.sol";
interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract ERC721 {
    mapping(address => uint) public _balanceOf;
    mapping(uint => address) public _ownerOf;
    mapping (uint => address) public _approved;
    mapping(address => mapping (address => bool)) public _isApprovedForAll;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256){
        require(_owner != address(0),"invalid address");
        return _balanceOf[_owner];
    }
    function ownerOf(uint256 _tokenId) external view returns (address){
        address owner = _ownerOf[_tokenId];
        require(owner != address(0),"invalid address");
        return owner;
    }
    function transferFrom(address _from, address _to, uint256 _tokenId) public payable{
        require(_ownerOf[_tokenId] == _from && _from != address(0) ,"Not owner") ;
        require(_to != address(0) ,"Not owner") ;
        require(msg.sender == _from || _isApprovedForAll[_from][msg.sender] || _approved[_tokenId] == msg.sender,
        "Not Allowed!");

        _balanceOf[_from]--;
        _balanceOf[_to]++;
        _ownerOf[_tokenId] = _to;

        delete _approved[_tokenId];
        emit  Transfer(_from, _to, _tokenId);
    }
     function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable{
         transferFrom(_from, _to, _tokenId);
        require(
            _to.code.length == 0 ||
                IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data) ==
                IERC721TokenReceiver.onERC721Received.selector,
            "unsafe recipient"
        );
     }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        transferFrom(_from, _to, _tokenId);
        require(
            _to.code.length == 0 ||
                IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "") ==
                IERC721TokenReceiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }
    function approve(address approved, uint256 _tokenId) public{
        console.log(msg.sender);
        address ownedBy = _ownerOf[_tokenId];
        require(ownedBy == msg.sender || _isApprovedForAll[ownedBy][msg.sender] == true ||
                tx.origin == ownedBy ||  _isApprovedForAll[ownedBy][tx.origin]  , "You are Not Authorized");
        _approved[_tokenId] = approved;
        emit Approval(ownedBy, approved, _tokenId);
    }
    function setApprovalForAll(address _operator, bool approved) external{
        _isApprovedForAll[msg.sender][_operator] = approved;
        emit ApprovalForAll(msg.sender, _operator, approved);
    }
    function getApproved(uint256 _tokenId) external view returns (address){
        require(_ownerOf[_tokenId] != address(0), "token doesn't exist");
        return _approved[_tokenId];
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool){
        return (interfaceID == type(IERC721).interfaceId || interfaceID == type(IERC165).interfaceId);
    }

    function _mint(address to, uint id) external  {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint id) external  {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approved[id];

        emit Transfer(owner, address(0), id);
    }
}

contract ERC4907 is ERC721 {
    struct Lessee
    {
        address user;
        uint expires;
    }

    mapping (uint256  => Lessee) internal lessees;

    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);

    function setUser(uint256 tokenId, address user, uint64 expires) public virtual{
        require(user != address(0),"no user");
        address owner =  _ownerOf[tokenId];
        require(owner != address(0), " not valid NFT" );
        require(( msg.sender == owner ||
                 _isApprovedForAll[owner][msg.sender] ||
            msg.sender == _approved[tokenId]), "Not Alowed");
        Lessee storage info =  lessees[tokenId];
        info.user = user;
        info.expires = block.timestamp + expires;
        emit UpdateUser(tokenId, user, expires);
    }

    function userOf(uint256 tokenId) public view virtual returns(address){
        if( uint256(lessees[tokenId].expires) >=  block.timestamp){
            return  lessees[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    function userExpires(uint256 tokenId) public view virtual returns(uint256){
        return lessees[tokenId].expires;
    }

}


contract NFTMarketPlace {
    struct Item {
        address seller;
        address tokenContract;
        uint tokenId;
        uint price;
        bool status;
    }
    mapping (uint => Item) public market;
    address payable public owner;
    uint public itemId;
    uint public listingfee;

    constructor(){
        owner = payable(msg.sender);
        itemId = 0;
        listingfee = 1000 wei;
    }

    event NFTListed(address sender, address _tokenContract, uint _tokenId, uint _price, uint itemId);

    function listNFT(address _tokenContract, uint _tokenId, uint _price) external payable returns(uint) {
        address tokenOwner = ERC4907(_tokenContract)._ownerOf(_tokenId);
        require(tokenOwner == msg.sender ||
                ERC4907(_tokenContract)._isApprovedForAll(tokenOwner,msg.sender) ||
                ERC4907(_tokenContract)._approved(_tokenId) == msg.sender
        ,"Youre not owner");
        require(msg.value >= listingfee , "Not Enough Listing Fee");

        Item memory item = Item({
            seller: msg.sender,
            tokenContract: _tokenContract,
            tokenId: _tokenId,
            price: _price,
            status: true
        });

        ERC4907(_tokenContract).approve(address(this), _tokenId);

        // bytes memory data = abi.encodeWithSelector(ERC4907(_tokenContract).approve.selector, address(this), _tokenId);
        // (bool success,) = _tokenContract.delegatecall(
        //     data
        // );

        // require(success, "call failed");

        market[itemId] = item;

        emit NFTListed(msg.sender, _tokenContract, _tokenId, _price, itemId);
        uint currentId = itemId;
        ++itemId;
        return currentId;
    }

    function buyNFT(uint _itemId) external payable{
        require (msg.value >= market[_itemId].price,"Insufficient balance Transfered!");
        require (market[_itemId].status,"Already sold");
        ERC4907(market[_itemId].tokenContract).transferFrom(market[_itemId].seller, msg.sender,
                market[_itemId].tokenId);

        market[_itemId].status = false;
        (bool success, ) = market[_itemId].seller.call{value: msg.value}("");
        require(success, "Failed to send funds to the seller");

        delete market[_itemId];
    }
    function deleteNFT(uint _itemId) public{
        require(msg.sender == market[_itemId].seller,"not auhorized" );
         delete market[_itemId];
    }
    function updateNFT(uint _itemId) public{
        require(msg.sender == market[_itemId].seller ||
                msg.sender == owner ,"not auhorized");
        market[_itemId].status = false;
    }

    function withraw()public{
        require(msg.sender == owner,"Only Owner");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Failed to send funds to the Owner");
    }


}

