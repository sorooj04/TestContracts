// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

struct Todo {
    string task;
    bool completed;
}

contract ToDo {
    Todo[] private tasks;

    function create(string memory _task) external {
        tasks.push(Todo(_task,false));
    }
    function updateStatus(uint _index) external {
        require(_index < tasks.length, "index out of bound");
        tasks[_index].completed = true;
    }
    function viewTask(uint _index) external view returns(string memory, bool ){
        require(_index < tasks.length, "index out of bound");
        return(tasks[_index].task ,tasks[_index].completed );
    }

}
