// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract FlyOnTheWall {
    enum Status {
        OPEN,
        CLOSED
    }
    uint8 private constant status_length = 2;
    uint256 internal postID;

    struct Post {
        uint256 postID;
        string title;
        string url;
        address admin;
        Application[] applications;
        address[] winners;
        string[] rules;
        uint8 highestScore;
        Status status;
    }   

   struct PostUserScore {
        uint256 postID;
        mapping(address => uint8[]) scores;
   }

    struct Application {
        address applicant;
        string url;
    }

    mapping(uint256 => Post) public posts;
    mapping(uint256 => PostUserScore) public post_scores_list;
    Post[] post_list;
    
    error TooManyRules();
    error InvalidState();
    error CannotSetSameState();
    error OnlyAdminAllowed();
    error InvalidPost();
    error PostClosed();
    error ApplicationScoresShouldMatchRules();

    modifier validRules(string[] memory _rules) {
        if (_rules.length > 10) revert TooManyRules();
        _;
    }

    modifier validateScores(uint8[] memory _scores) {
        if (_scores.length > 10) revert TooManyRules();
        _;
    }

    modifier onlyAdmin(uint256 _postID) {
        Post storage post = posts[_postID];
        if (msg.sender != post.admin) revert OnlyAdminAllowed();
        _;
    }

    modifier validPost(uint256 _postID) {
        Post storage post = posts[_postID];
        if (post.admin == address(0)) revert InvalidPost();
        _;
    }

    // 1. anyone can create a post
        // post admin, title, rules, url, status
    function createPost(string memory _title, string memory _url, string[] memory _rules) public validRules(_rules) returns (uint256) {
        Post storage post = posts[postID];
        post.admin = msg.sender;
        post.title = _title;
        post.url = _url;
        post.rules = _rules;
        post.status = Status.OPEN;
        
        post_list.push(post);
        postID++;

        emit PostCreated(
          postID,
          msg.sender,
          block.timestamp  
        );
        return post.postID;
    }

    // 1a list all posts
    function listPosts() public view returns (Post[] memory) {
        return post_list;
    }

    function validateState(Status _status) internal pure returns (bool) {
        return (uint8(_status) <= status_length);
    }

    // 1b admin can close or reopen post
    function changePostState(uint256 _postID, Status _status) public onlyAdmin(_postID) {
        if (!validateState(_status)) revert InvalidState();
    
        Post storage post = posts[_postID];

        if (post.status == _status) revert CannotSetSameState();
        post.status = _status;

        emit PostStateChanged(
            _postID,
            msg.sender,
            _status,
            block.timestamp  
        );
    }


    // 2. anyone can apply to post
        // address, url, email?
    function applyToPost(uint256 _postID, string memory _url) public validPost(_postID) returns (bool) {
        Post storage post = posts[_postID];
        if (post.status == Status.CLOSED) revert PostClosed();

        Application memory application;
        application.applicant = msg.sender;
        application.url = _url;
        post.applications.push(application);

        emit PostApplication(
            _postID,
            msg.sender
        );

        return true;
    }

    // 3. admin can score applications
    // assumes each score is a one to one mapping to the rules, in the same array order
    function scoreApplicationForPost(uint256 _postID, address _applicant, uint8[] memory _scores) public onlyAdmin(_postID) validateScores(_scores) validPost(_postID) {
        Post storage post = posts[_postID];
        if (_scores.length != post.rules.length) revert ApplicationScoresShouldMatchRules();

        // TODO: validate that _applicant has an application
        PostUserScore storage ps = post_scores_list[_postID];
        ps.scores[_applicant] = _scores;

        uint8 totalScore;
        for (uint8 i = 0; i < _scores.length; i++) {
            totalScore += _scores[i];
        }

        if (totalScore > post.highestScore) {
            address[] memory new_winner;
            new_winner[0] = _applicant;
            post.winners = new_winner;
            post.highestScore = totalScore;
        } else if (totalScore == post.highestScore) {
            post.winners.push(_applicant);
        }

        emit ApplicationScored(
            _postID,
            _applicant,
            block.timestamp
        );
    }

    // 4. users can check winner
    function getWinner(uint256 _postID) public view validPost(_postID) returns (address[] memory) {
        Post memory post = posts[_postID];

        return post.winners;
    }

    // 4b. list application score for post

    // 5. users can view applications
    function listApplicationsForPost(uint256 _postID) public view validPost(_postID) returns (Application[] memory) {
        Post memory post = posts[_postID];

        return post.applications;
    }

    // 6. implement payable, in case tokens are sent to contract?

    event PostCreated(
        uint256 postID,
        address admin,
        uint256 timestamp
    );

    event PostApplication(
        uint256 postID,
        address applicant
    );

    event PostStateChanged(
        uint256 postID,
        address admin,
        Status state,
        uint256 timestamp
    );

    event ApplicationScored(
        uint256 postID,
        address applicant,
        uint256 timestamp
    );
}
