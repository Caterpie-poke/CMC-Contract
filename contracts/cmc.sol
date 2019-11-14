pragma solidity >=0.4.0 <0.7.0;
import './cmc_token.sol';
import './cmc_coin.sol';
import './cmc_review.sol';

contract CMC is CMC_Token, CMC_Coin,CMC_Review {
    struct User {
        string name;
        string email;
        bytes32[] publications;
        bytes32[] purchases;
        address[] payees;   // temp storage
        bytes32[] parents;  // temp storage
    }
    mapping(address=>User) private users;
    mapping(address=>mapping(bytes32=>bool)) private isFavor;

    event Publish(address indexed creater, bytes32 indexed tokenId, Genre indexed genre);
    event Purchase(address indexed buyer, bytes32 indexed tokenId);
    event Favorite(address indexed fan, bytes32 indexed tokenId);

    constructor(uint _ts) CMC_Coin(_ts) public {}

    // UserData initialize
    function initUserData(string memory _name, string memory _email) public {
        require(!compare(_name, '') && !compare(_email, ''), 'Invalid parameter');
        require(!isExistUserData(msg.sender), 'Already exist account');
        users[msg.sender].name = _name;
        users[msg.sender].email = _email;
    }

    // Getter
    function isExistUserData(address _target) public view returns(bool) {
        return !compare(users[_target].email, '');
    }
    function getUserName(address _target) public view returns(string memory) {
        return users[_target].name;
    }
    function getUserEmail(address _target) public view returns(string memory) {
        return users[_target].email;
    }
    function getUserPublications(address _target) public view returns(bytes32[] memory) {
        return users[_target].publications;
    }
    function getUserPurchased(address _target) public view returns(bytes32[] memory) {
        return users[_target].purchases;
    }
    function getIsFavor(address _target, bytes32 _tokenId) public view returns(bool) {
        return isFavor[_target][_tokenId];
    }

    // Setter
    function changeName(string memory _name) public {
        require(!compare(users[msg.sender].name, _name), 'Error: Same email address');
        users[msg.sender].name = _name;
    }
    function changeEmail(string memory _email) public {
        require(!compare(users[msg.sender].email, _email), 'Error: Same email address');
        users[msg.sender].email = _email;
    }
    function publish(uint256 _price, string memory _gdid, Genre _genre) public {
        bytes32 tokenId = createToken(_price, _genre, _gdid);
        users[msg.sender].publications.push(tokenId);
        emit Publish(msg.sender, tokenId, _genre);
    }
    function buy(bytes32 _tokenId, uint _pay) public {
        require(tokenOf[_tokenId].creater != address(0x0), "Error: Not exist token");
        require(tokenOf[_tokenId].price <= _pay, "Error: Not enough payment");
        address[] memory init;
        users[msg.sender].payees = init;
        traceUp(_tokenId);
        uint256[] memory dist = distribute(_pay, users[msg.sender].payees.length);
        for(uint256 i = 0; i < dist.length; i++){
            transfer(users[msg.sender].payees[i], dist[i]);
        }
        ownerOf[_tokenId].push(msg.sender);
        users[msg.sender].purchases.push(_tokenId);
        emit Purchase(msg.sender, _tokenId);
    }
    function favo(bytes32 _tokenId) public {
        isFavor[msg.sender][_tokenId] = true;
        emit Favorite(msg.sender, _tokenId);
    }

    // Internal function
    function compare(string memory _l, string memory _r) internal pure returns(bool) {
        return keccak256(bytes(_l)) == keccak256(bytes(_r));
    }
    function distribute(uint256 _total, uint256 _len) internal pure returns(uint256[] memory) {
        uint256[] memory dist = new uint256[](_len);
        uint256 remain = _total;
        for(uint256 i = 0; i < _len; i++){
            uint256 head = 2*remain/5;
            remain -= head;
            dist[i] = head;
        }
        dist[_len-1] += remain;
        return dist;
    }
    function traceUp(bytes32 _tokenId) internal {
        CMCToken memory t = tokenOf[_tokenId];
        users[msg.sender].payees.push(t.creater);
        users[msg.sender].parents.push(_tokenId);
        if(t.origin != bytes32(0x0) && notIn(t.origin)){
            traceUp(t.origin);
        }
    }
    function notIn(bytes32 _tokenId) internal view returns(bool) {
        for(uint256 i = 0; i < users[msg.sender].parents.length; i++){
            if(users[msg.sender].parents[i] == _tokenId){
                return false;
            }
        }
        return true;
    }
}
