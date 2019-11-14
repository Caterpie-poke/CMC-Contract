pragma solidity >=0.4.0 <0.7.0;
import './SafeMath.sol';

contract CMC_Coin {
    using SafeMath for uint;

    uint internal _totalSupply;
    mapping(address=>uint) internal balances;
    mapping(address=>mapping(address=>uint)) internal allowed;

    event Transfer(address indexed _from, address indexed _to, uint _tokens);
    event Approval(address indexed _tokenOwner, address indexed _spender, uint _tokens);

    constructor(uint ts) public {
        _totalSupply = ts;
        balances[msg.sender] = _totalSupply;
    }

    // Original
    function mint(uint256 _amount) public {
        _totalSupply = _totalSupply.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
    }

    // ERC20 Standard
    function totalSupply() public view returns (uint){
        return _totalSupply;
    }
    function balanceOf(address tokenOwner) public view returns (uint){
        return balances[tokenOwner];
    }
    function allowance(address tokenOwner, address spender) public view returns (uint){
        return allowed[tokenOwner][spender];
    }
    function transfer(address to, uint tokens) public returns (bool){
        require(to != address(0x0), 'Cannot specify 0x0 address');
        require(balances[msg.sender] >= tokens, 'Cannot transfer token over your balances');
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool){
        require(spender != address(0x0), 'Cannot specify 0x0 address');
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool){
        require(to != address(0x0), 'Cannot specify 0x0 address');
        require(tokens <= balances[from], 'Cannot transfer token over your balances');
        require(tokens <= allowed[from][msg.sender], 'Cannot transfer token over your allowance');
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}
