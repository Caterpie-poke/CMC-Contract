pragma solidity >=0.4.0 <0.7.0;
import './SafeMath.sol';

contract CMC_Token {
    using SafeMath for uint256;

    enum Genre {
        Book,
        Art,
        Audio,
        Game
    }
    struct CMCToken {
        address creater;     // creater (immutable) (MUST)
        uint256 price;    // minimum price of token (MUST)
        Genre genre;         // Genre enum (immutable) (MUST)
        string fileId;       // GoogleDrive-FileID of main file (immutable) (MUST)
        bytes32 origin;      // parent token
        string subFileId;    // GoogleDrive Share URL of public file (sample, demo etc.)
        bytes32[] tags;      // tag list
        string description;  // 140 characters
    }
    mapping(bytes32=>CMCToken) internal tokenOf;
    mapping(bytes32=>address[]) internal ownerOf;
    mapping(bytes32=>uint256) internal tagCount;
    bytes32[] internal tagSet;
    mapping(bytes32=>mapping(bytes32=>bool)) internal tagExistIn;

    event Inherit(bytes32 indexed parent, bytes32 indexed child);

    // Getter
    function getTokenBaseData(bytes32 _tokenId) public view returns(address, uint256, Genre) {
        CMCToken memory t = tokenOf[_tokenId];
        return (t.creater, t.price, t.genre);
    }
    function getTokenFileId(bytes32 _tokenId) public view returns(string memory) {
        require(tokenOf[_tokenId].creater == address(msg.sender), "Only creater can view");
        return tokenOf[_tokenId].fileId;
    }
    function getTokenOriginId(bytes32 _tokenId) public view returns(bytes32) {
        return tokenOf[_tokenId].origin;
    }
    function getTokenSubFileId(bytes32 _tokenId) public view returns(string memory) {
        return tokenOf[_tokenId].subFileId;
    }
    function getTokenTags(bytes32 _tokenId) public view returns(bytes32[] memory) {
        return tokenOf[_tokenId].tags;
    }
    function getTokenDescription(bytes32 _tokenId) public view returns(string memory) {
        return tokenOf[_tokenId].description;
    }
    function getTokenOwners(bytes32 _tokenId) public view returns(address[] memory) {
        return ownerOf[_tokenId];
    }
    function getTagCount(bytes32 _tag) public view returns(uint256) {
        return tagCount[_tag];
    }
    function getTagSet() public view returns(bytes32[] memory) {
        return tagSet;
    }

    // Setter
    function setPrice(bytes32 _tokenId, uint256 _price) public {
        require(tokenOf[_tokenId].creater == address(msg.sender), "Only creater can modify");
        tokenOf[_tokenId].price = _price;
    }
    function setOrigin(bytes32 _tokenId, bytes32 _parent) public {
        require(tokenOf[_tokenId].creater == address(msg.sender), "Only creater can modify");
        require(_parent != bytes32(0x0), "Cannot assign 0x0 as origin");
        require(tokenOf[_tokenId].origin == bytes32(0x0), "Origin is already assigned");
        tokenOf[_tokenId].origin = _parent;
        emit Inherit(_parent, _tokenId);
    }
    function setSubFileId(bytes32 _tokenId, string memory _subFileId) public {
        require(tokenOf[_tokenId].creater == address(msg.sender), "Only creater can modify");
        tokenOf[_tokenId].subFileId = _subFileId;
    }
    function setTag(bytes32 _tokenId, bytes32[] memory _tags) public {
        require(tokenOf[_tokenId].creater == address(msg.sender), "Only creater can modify");
        for(uint256 i = 0; i < _tags.length; i++){
            if(!tagExistIn[_tokenId][_tags[i]]){
                tagCount[_tags[i]].add(1);
                if(tagCount[_tags[i]] == 0){tagSet.push(_tags[i]);}
                tagCount[_tags[i]].add(1);
            }
        }
    }
    function setDescription(bytes32 _tokenId, string memory _dscr) public {
        require(tokenOf[_tokenId].creater == address(msg.sender), "Only creater can modify");
        tokenOf[_tokenId].description = _dscr;
    }

    // Internal function
    function createToken(uint256 _price, Genre _genre, string memory _fileId) internal returns(bytes32) {
        CMCToken memory t;
        t.creater = msg.sender;
        t.price = _price;
        t.fileId = _fileId;
        t.genre = _genre;
        bytes32 tokenId = genId(t);
        tokenOf[tokenId] = t;
        ownerOf[tokenId].push(msg.sender);
        return tokenId;
    }
    function genId(CMCToken memory _token) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_token.fileId, _token.creater, _token.genre));
    }
}
