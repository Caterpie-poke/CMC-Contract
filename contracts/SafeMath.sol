pragma solidity >=0.4.0 <0.7.0;

library SafeMath {
   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      if (a == 0) {
         return 0;
      }
      uint256 c = a * b;
      require(c / a == b, 'SafeMath Mul Err');
      return c;
   }
   function div(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b > 0, 'SafeMath Div Err');
      uint256 c = a / b;
      return c;
   }
   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b <= a, 'SafeMath Sub Err');
      uint256 c = a - b;
      return c;
   }
   function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c >= a, 'SafeMath Add Err');
      return c;
   }
   function mod(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b != 0, 'SafeMath Mod Err');
      return a % b;
   }
   function exp(uint256 a, uint256 b) internal pure returns(uint256){
      require(b >= 0, 'SafeMath Exp Err');
      uint256 c = 1;
      for(uint256 i = 0 ; i < b ; i++){
         c = mul(c, a);
      }
      return c;
   }
}
