// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

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

contract ERC721 /*is IERC721*/ {
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
    //  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        transferFrom(_from, _to, _tokenId);
        require(
            _to.code.length == 0 ||
                IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "") ==
                IERC721TokenReceiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }
    function approve(address approved, uint256 _tokenId) external payable{
        address ownedBy = _ownerOf[_tokenId];
        require(ownedBy == msg.sender || _isApprovedForAll[ownedBy][msg.sender] == true, "You are Not Authorized");
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
    // function isApprovedForAll(address _owner, address _operator) external view returns (bool){
    // }
    function supportsInterface(bytes4 interfaceID) external pure returns (bool){
        return (interfaceID == type(IERC721).interfaceId || interfaceID == type(IERC165).interfaceId);
    }

    function _mint(address to, uint id) external {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint id) external {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approved[id];

        emit Transfer(owner, address(0), id);
    }
}
