// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "hardhat/console.sol";

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
    function balanceOfAddress(address _owner, uint256 _id) external view returns (uint256);
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC1155TokenReceiver is  IERC165{

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}

contract ERC1155 /* is ERC165 */ {
    mapping (address => mapping (uint => uint)) private balanceOf;
     mapping (address => mapping (address => bool)) public approvals;

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);

    function _mint(address _to, uint _id,uint _value) external{
        balanceOf[_to][_id] += _value;
    }
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external{
        require(_from == msg.sender || approvals[_from][msg.sender], "Not Allowed");
        require(_to != address(0), "Wrong Addresss");
        require(balanceOf[_from][_id] >= _value, "Insufficient balance" );
        balanceOf[_from][_id] -= _value;
        balanceOf[_to][_id] += _value;
        emit TransferSingle(msg.sender,_from, _to, _id, _value);
        if (_to.code.length > 0 ) {
            try IERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _id, _value, _data) returns (bytes4 response) {
                if (response != IERC1155TokenReceiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }


    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external{
        require(_from == msg.sender || approvals[_from][msg.sender], "Not Allowed");
        require(_to != address(0), "Wrong Addresss");
        require(_ids.length == _values.length, "wrong Input");
        for(uint i = 0 ; i < _ids.length; i++){


        require(balanceOf[_from][_ids[i]] >= _values[i], "Insufficient balance" );
        balanceOf[_from][_ids[i]] -= _values[i];
        balanceOf[_to][_ids[i]] += _values[i];
        }
        emit TransferBatch(msg.sender, _from, _to,  _ids, _values);

        if (_to.code.length > 0 ) {
            try IERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _ids, _values, _data) returns (
                bytes4 response
            ) {

                if (response != IERC1155TokenReceiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function balanceOfAddress(address _owner, uint256 _id) external view returns (uint256){
        require(_owner != address(0), "Invalid Address");
        return balanceOf[_owner][_id];
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory){
        require(_owners.length == _ids.length, "Invalid inputs");

        uint[] memory balances =  new uint256[](_owners.length);
        for(uint i=0; i<_owners.length; i++){
            balances[i] = balanceOf[_owners[i]][_ids[i]];
        }
        return balances;
    }

    function setApprovalForAll(address _operator, bool _approved) external{
       require( _operator != address(0), "Invalid Address");
       require( _operator != msg.sender, "No Self Approvals");
       approvals[msg.sender][_operator] = _approved;
       emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        require(_owner != address(0) && _operator != address(0), "Invalid Address");
        return approvals[_owner][_operator];
    }
}
