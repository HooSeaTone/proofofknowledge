pragma solidity ^0.4.23;

import "./StandardToken.sol";

contract TeachersPet is StandardToken {
  string public name = "PrOOfOfKnowlEdgE"; 
  string public symbol = "POOOOKEE";
  uint public decimals = 18;
  uint public INITIAL_SUPPLY = 10000 * (10 ** decimals);

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  address owner = msg.sender;

  struct Milestone {
    uint reward;
    bytes32 tags;
  }

  struct Student {
    bytes32 id;
    bytes32[] milestone;
    uint tokensReceived;
  }

  mapping(bytes32 => Milestone) milestones;
  mapping(address => Student) students;

  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }

  function createMilestone(bytes32 _title, uint _reward, bytes32 _tags) onlyOwner public {
    require(_title > 0 && _tags > 0 && _reward >= 0);
    Milestone memory milestone = Milestone(_reward,_tags);
    milestones[_title] = milestone;
  }

  function getMilestone(bytes32 _title) public view returns(bytes32, uint, bytes32){
    require(_title > 0);
    require(milestones[_title].tags > 0);
    return (_title, milestones[_title].reward, milestones[_title].tags);
  }

  function deleteMilestone(bytes32 _title) onlyOwner public {
    require(_title > 0);
    require(milestones[_title].tags > 0);
    delete milestones[_title];
  }

  function giveMilestone(address _student, bytes32 _title) onlyOwner public {
    require(_student > 0);
    require(_title > 0);
    require(students[_student].id > 0);
    require(milestones[_title].reward > 0 || milestones[_title].tags > 0);

    uint history = students[_student].milestone.length;
    bool duplicate = false;

    // Check for duplicate milestone for student
    for (uint index = 0; index < history; index++) {
      if(_title == students[_student].milestone[index] ) {
        duplicate = true;
        index = history;
      }
    }

    require(duplicate == false);
    students[_student].milestone.push(_title);
    students[_student].tokensReceived += milestones[_title].reward;
    approve(_student, milestones[_title].reward);
    transfer(_student, milestones[_title].reward);
  }

  function createStudent(address _address, bytes32 _id) public {
    require(_address > 0, 'Address not provided');
    require(_id > 0, 'Email not provided');
    require(students[_address].id == 0, 'Student already exist with this address');

    bytes32[] memory studentProgress;
    Student memory student = Student(_id,studentProgress,0);
    students[_address] = student;
  }

  function getStudentRecord(address _student) public view returns(bytes32, bytes32[], uint){
    require(_student > 0);
    require(students[_student].id > 0);
    return (students[_student].id, students[_student].milestone, students[_student].tokensReceived);
  }

  function deleteStudent(address _student) onlyOwner public returns(bool) {
    // Check for valid address
    require(_student != 0);

    // Check for existing student
    require(students[_student].id > 0);

    delete students[_student];
    return true;
  }

}