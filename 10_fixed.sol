// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC_Token_8 {

    //name , symbol , decimals
    // total supply , balance of , allowance
    // tranfer , transfer from , allowed
    // increase & decrease allowance

    address OWNER;

    string public token_name = "Rainbow";
    string public token_symbol = "RMB";
    uint public total_supply = 1000;
    uint public decimal;

    constructor () {
        OWNER = msg.sender;
        decimal = 10;
        Balance[OWNER] = total_supply;
    }

    modifier Not_Account_Zero (address _user) {
        require(_user != address(0) , "Cannot perform this transaction, abborted!");
        _;
    }

    modifier Check_Balance (address _user , uint _amount) {
        require(Balance[_user] >= _amount , "Not enough tokens, abborted!");
        _;
    }

    mapping (address => uint) Balance;
    mapping (address => mapping (address => uint)) Allowed;

    event Transfer_Token (address _owner , address _recipient , uint _amount , address _contract);
    event Transfer_Token_From (address _owner , address _sender , address _recipient , uint _amount , address _contract);
    event Increase_Allowance(address _owner, address _user, uint _amount);

    function transfer (address _to , uint _amount) public Not_Account_Zero(_to) Check_Balance(msg.sender , _amount) returns (bool) {

        Balance[msg.sender] -= _amount;
        Balance[_to] += _amount;

        emit Transfer_Token (msg.sender , _to , _amount , address(this));
        return true;
    }

    function allow (address _user , uint _amount) public Not_Account_Zero(_user) Check_Balance(msg.sender , _amount) returns (bool) {

        Allowed[msg.sender][_user] += _amount;

        emit Transfer_Token(msg.sender, _user, _amount, address(this));
        return true;

    }

    function transfer_from (address _from , address _to , uint _amount) public Not_Account_Zero(_to) Check_Balance(_from , _amount) returns (bool) {

        Allowed[_from][msg.sender] -= _amount;
        Balance[_from] -= _amount;
        Balance[_to] += _amount;

        emit Transfer_Token_From(_from, msg.sender, _to, _amount , address(this));
        return true;

    }

    function increase_allowance (address _user , uint _amount) public Not_Account_Zero(_user) Check_Balance(msg.sender , _amount) returns (bool){

        Allowed[msg.sender][_user] += _amount;

        emit Increase_Allowance(msg.sender, _user, _amount);
        return true;
    }

    function decrease_allowance (address _user , uint _amount) public Not_Account_Zero(_user) returns (bool){

        require(Allowed[msg.sender][_user] >= _amount , "Not enough allowance to user, abborted!");
        Allowed[msg.sender][_user] -= _amount;

        emit Increase_Allowance(msg.sender, _user, _amount);
        return true;
    }


}