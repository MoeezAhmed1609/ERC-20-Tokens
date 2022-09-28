// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Mintable_Token {

    //name , symbol , decimals
    // total supply , balance of , allowance
    // tranfer , transfer from , allowed
    // increase & decrease allowance
    // mint & burn token

    address OWNER;
    
    struct Token {
        string name;
        string symbol;
        uint decimals;
        uint total_supply;
    }

    Token public token;

    constructor (
        string memory _name ,
        string memory _symbol,
        uint _decimals,
        uint _supply
    ) {
        
        OWNER = msg.sender;
        token = Token(_name , _symbol , _decimals , _supply);
        Balance[OWNER] = _supply;
    }

    mapping (address => uint) public Balance;
    mapping (address => mapping (address => uint)) public Allowed;

    modifier Only_Owner {
        require(msg.sender == OWNER , "You are not the owner, abborted!");
        _;
    }

    modifier Not_Add_Zero (address _user) {
        require(_user != address(0) , "Cannot perform transaction, abborted!");
        _;
    }

    event Token_Transfer (address _sender , address _to ,uint _amount , address _contract);
    event Allowance (address _owner , address _user , uint _amount , address _contract);
    event Delegate_Transfer(address _owner , address _from , address _to , uint _amount , address _contract);
    event Increase_Allowance (address _owner , address _of , uint _amount , address _contract);
    event Decrease_Allowance (address _owner , address _of , uint _amount , address _contract);
    event Mint (address _owner , uint _amount , uint _total_supply);


    // Show Token Details

    function token_details () public view returns (Token memory) {

        return token;
    }

    // Show Balance of address

    // function balance (address _owner) public view returns (uint) {
    //     return Balance[_owner];
    // }

    // // Show allowance of address

    // function allowance (address _owner , address _user) public view returns (uint) {
    //     return Allowed[_owner][_user];
    // }

    // Transfer Tokens from one account to another

    function transfer (address _to , uint _amount) public Not_Add_Zero(_to) returns (bool) {

        require(Balance[msg.sender] >= _amount , "Not enough Tokens in account, abborted!");

        Balance[msg.sender] -= _amount;
        Balance[_to] += _amount;

        emit Token_Transfer (msg.sender , _to , _amount , address(this));
        return true;
    }

    // Allow other address to use token on behalf of tokens owner (delegate call)

    function allow (address _user , uint _amount) public  Not_Add_Zero(_user) returns(bool) {

        Allowed[msg.sender][_user] = _amount;

        emit Allowance (msg.sender , _user , _amount , address(this));
        return true;
    }

    // Allowed accounts of token owners can transfer tokens to other or self accounts

    function transfer_from (address _from , address _to , uint _amount) public Not_Add_Zero(_to) returns (bool) {

        require(Balance[_from] >= _amount, "Not enough tokens in account, abborted!");
        require(Allowed[_from][msg.sender] >= _amount, "Not enough tokens in account, abborted!");

        Balance[_from] -= _amount;
        Allowed[_from][msg.sender] -= _amount;
        Balance[_to] += _amount;

        emit Delegate_Transfer(msg.sender , _from , _to , _amount , address(this));
        return true;

    }

    // Increase in allowance ammount of allowed address by owner of tokens

    function increase_allowance (address _of , uint _amount) public Not_Add_Zero(_of) returns (bool) {

        require(Balance[msg.sender] >= _amount, "Not enough tokens in account, abborted!");
        
        Allowed[msg.sender][_of] += _amount;

        emit Increase_Allowance (msg.sender , _of , _amount , address(this));
        return true;
    }

    // Decrease in allowance ammount of allowed address by owner of tokens

    function decrease_allowance (address _of , uint _amount) public Not_Add_Zero(_of) returns (bool) {

        require(Allowed[msg.sender][_of] >= _amount, "Not enough allowance provided, abborted!");

        Allowed[msg.sender][_of] -= _amount;

        emit Decrease_Allowance (msg.sender , _of , _amount , address(this));
        return true;
    }

    // Mint more token for supply by owner

    function mint_token (uint _amount) external Only_Owner{
        
        require(_amount > 0 , "Increase amount of tokens to mint, abborted!");

        token.total_supply += _amount;
        Balance[msg.sender] += _amount;

        emit Mint (msg.sender , _amount , token.total_supply);
    }

    // burn excess token to reduce supply by owner

    function burn_token (uint _amount) external Only_Owner {

        require(_amount > 0 , "Increase amount of tokens to mint, abborted!");

        token.total_supply -= _amount;
        Balance[msg.sender] -= _amount;

        emit Mint(msg.sender, _amount, token.total_supply);

    }

}