// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

struct Car {
    string model;
    uint year;
    address owner;
}

contract CarRegistry {
    address public owner;
    Car[] public cars;
    address[] public carOwners;

    constructor(){
        owner = msg.sender;
    }
    function create( string calldata _model, uint _year) public {
        cars.push(Car(_model,_year,msg.sender));
        carOwners.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function findIndexInCarOwners(address _owner) private view returns(uint){
        for(uint i=0; i < carOwners.length; i++ ){
            if(keccak256(abi.encodePacked(carOwners[i])) == keccak256(abi.encodePacked(_owner))){
                return i;
            }
        }
        revert("This address has no car");
    }

    function changeOwnership(address _oldOwner, address _newOwner) public onlyOwner {
        uint index = findIndexInCarOwners(_oldOwner);
        cars[index].owner = _newOwner;
        carOwners[index] = _newOwner;
    }

    function ShowCarDetails(address _owner) public view returns(string memory, uint, address) {
        uint index = findIndexInCarOwners(_owner);
        return(cars[index].model,cars[index].year,cars[index].owner);
    }
    function transferOwnership(address _oldOwner, address _newOwner) public {
        uint index = findIndexInCarOwners(_oldOwner);
        require(_oldOwner == msg.sender, "you donot own this car so cannot change ownership");
        require(_oldOwner == cars[index].owner, "you donot own this car so cannot change ownership");
        cars[index].owner = _newOwner;
        carOwners[index] = _newOwner;
    }
    function getCarFromIndex(uint _index) public view returns(Car memory) {
        return cars[_index];
    }
    function getOwnerFromIndex(uint _index) public view returns(address ) {
        return carOwners[_index];
    }

}
