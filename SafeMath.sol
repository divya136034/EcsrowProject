pragma solidity ^0.5.0;

library SafeMath {
  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        //require(b <= a, "invalid data is here");
        uint256 c=a-b;
        require(c>=0, "c should be positive");
        return c;
        
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

}
