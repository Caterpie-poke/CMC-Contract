pragma solidity >=0.4.0 <0.7.0;

contract CMC_Review {
    enum Star {NONE, S1, S2, S3, S4, S5}

    mapping(address=>mapping(address=>Star)) internal star;
    mapping(address=>mapping(address=>string)) internal comment;
    mapping(address=>uint256[2]) internal starRateOf;  // [totalStar / amount] -> rate

    event Stared(address indexed _from, address indexed _to, Star indexed _star);
    event Commented(address indexed _from, address indexed _to, bytes32 indexed tokenId);

    // Getter
    function isReviewed(address _target) public view returns(bool) {
        return star[msg.sender][_target] != Star.NONE;
    }
    function getStar(address _from, address _to) public view returns(Star) {
        return star[_from][_to];
    }
    function getComment(address _from, address _to) public view returns(string memory) {
        return comment[_from][_to];
    }
    function getReviewRate(address _target) public view returns(uint256[2] memory) {
        return starRateOf[_target];
    }

    // Setter
    function changeStar(address _target, Star _star) public {
        require(star[msg.sender][_target] != Star.NONE, 'Not yet reviewed');
        require(_star != Star.NONE, 'Cannot set No Star');
        Star beforeStar = star[msg.sender][_target];
        star[msg.sender][_target] = _star;
        starRateOf[_target][0] += uint256(_star);
        starRateOf[_target][0] -= uint256(beforeStar);
        emit Stared(msg.sender, _target, _star);
    }
    function changeComment(address _target, bytes32 _tokenId, string memory _comment) public {
        require(star[msg.sender][_target] != Star.NONE, 'Not yet reviewed');
        comment[msg.sender][_target] = _comment;
        emit Commented(msg.sender, _target, _tokenId);
    }
    function firstReview(address _target, Star _star, bytes32 _tokenId, string memory _comment) public {
        require(star[msg.sender][_target] == Star.NONE, 'Already reviewed');
        star[msg.sender][_target] = _star;
        comment[msg.sender][_target] = _comment;
        starRateOf[_target][0] += uint256(_star);
        starRateOf[_target][1] += 1;
        emit Stared(msg.sender, _target, _star);
        emit Commented(msg.sender, _target, _tokenId);
    }
}
