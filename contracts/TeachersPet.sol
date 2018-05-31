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
    bytes32[] milestones;
    uint tokensReceived;
  }

  mapping(bytes32 => Milestone) milestones;
  mapping(address => Student) students;
  mapping(bytes32 => bool) admins;

  modifier onlyAdmin() {
    require(admins[keccak256(msg.sender)] == true || msg.sender == owner);
    _;
  }

  event MilestoneAwarded(address _to, uint amount, bytes32 milestone, bytes32 _tags);

  function addAdministrator(address _newAdmin) onlyAdmin public {
    require(_newAdmin > 0);
    admins[keccak256(_newAdmin)] = true;
  }

  function removeAdministrator(address _oldAdmin) onlyAdmin public {
    require(_oldAdmin > 0);
    require(admins[keccak256(_oldAdmin)] == true);
    delete admins[keccak256(_oldAdmin)];
  }

  function isAdministrator(address _user) public view returns(bool) {
    require(_user > 0);
    return (admins[keccak256(_user)] || _user == owner);
  }

  function createMilestone(bytes32 _title, uint _reward, bytes32 _tags) onlyAdmin public {
    require(_title > 0 && _tags > 0 && _reward >= 0);
    Milestone memory milestone = Milestone(_reward,_tags);
    milestones[_title] = milestone;
  }

  function getMilestone(bytes32 _title) public view returns(bytes32, uint, bytes32){
    require(_title > 0);
    require(milestones[_title].tags > 0);
    return (_title, milestones[_title].reward, milestones[_title].tags);
  }

  function deleteMilestone(bytes32 _title) onlyAdmin public {
    require(_title > 0);
    require(milestones[_title].tags > 0);
    delete milestones[_title];
  }

  function giveMilestone(address _student, bytes32 _title) onlyAdmin public {
    require(_student > 0);
    require(_title > 0);
    require(students[_student].id > 0);
    require(milestones[_title].reward > 0 || milestones[_title].tags > 0);

    uint history = students[_student].milestones.length;
    bool duplicate = false;

    // Check for duplicate milestone for student
    for (uint index = 0; index < history; index++) {
      if(_title == students[_student].milestones[index] ) {
        duplicate = true;
        index = history;
      }
    }

    require(duplicate == false);
    students[_student].milestones.push(_title);
    students[_student].tokensReceived += milestones[_title].reward;
    approve(_student, milestones[_title].reward);
    transfer(_student, milestones[_title].reward);
    emit MilestoneAwarded(_student, milestones[_title].reward, _title, milestones[_title].tags);
  }

  function createStudent(address _address, bytes32 _id) public {
    require(_address > 0, 'Address not provided');
    require(_id > 0, 'Email not provided');
    require(students[_address].id == 0, 'Student already exist with this address');

    bytes32[] memory studentProgress;
    Student memory student = Student(_id,studentProgress,0);
    students[_address] = student;
  }

  function getStudentRecord(address _student) onlyAdmin public view returns(bytes32, bytes32[], uint){
    require(_student > 0);
    require(students[_student].id > 0);
    return (students[_student].id, students[_student].milestones, students[_student].tokensReceived);
  }

  function deleteStudent(address _student) onlyAdmin public returns(bool) {
    require(_student > 0);
    require(students[_student].id > 0);

    delete students[_student];
    return true;
  }

}