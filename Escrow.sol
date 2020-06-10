pragma solidity ^0.5.11;

import "browser/SafeMath.sol";

contract Escrow {
    mapping (address => uint256) private balances;

    address public seller;
    address public buyer;
    address public winner;
    address public escrowOwner;
    uint256 public disputeTime;
    uint public judgefees;
    uint public x;
    uint public escrowID;
    uint256 public escrowCharge;
   


   
    bool public buyerdispute;
    bool public buyerjudgePayout;
    bool public sellerjudgePayout;
    
   
    
    uint256[] public deposits;
   

    enum EscrowState { unInitialized, initialized, buyerDeposited, buyerDispute, escrowComplete,buyerfeesDeposited, sellerfeesDeposited }
    EscrowState public eState = EscrowState.unInitialized;

    event Deposit(address depositor, uint256 deposited);

    modifier onlyBuyer() {
        require(msg.sender == buyer) ;
        _;
    
    }

    modifier onlyEscrowOwner() {
        require (msg.sender == escrowOwner) ;
         _;
        }

    


    constructor(address fOwner, uint256 _escrowID) public {
        escrowOwner = fOwner;
        escrowID = _escrowID;
        escrowCharge = 0;
    }

    function () external{ 
        revert();
    }

    function initEscrow(address _seller, address _buyer, uint _judgefees, uint256 _disputeTime) public onlyEscrowOwner {
        require((_seller != msg.sender) && (_buyer != msg.sender));
        escrowID += 1;
        seller = _seller;
        buyer = _buyer;
        judgefees = _judgefees;
        disputeTime = _disputeTime;
        eState = EscrowState.initialized;
        balances[seller] = 0;
        balances[buyer] = 0;
    }
    

    function depositToEscrow(uint _x, uint256 amount) public  {
      require(msg.sender == buyer);
        x=_x;
        buyerdispute =  false;
        balances[buyer] = SafeMath.sub(balances[buyer], amount);
        deposits.push(amount);
        escrowCharge =escrowCharge+amount;
        eState = EscrowState.buyerDeposited;
        emit Deposit(msg.sender, amount);
        
        
    }

    function disputeEscrow() public {
        require(msg.sender == buyer && now<x);
        buyerdispute = true;
        eState =  EscrowState.buyerDispute;
        }
        
        
    function payJudgeFees() public payable{
        if(buyerdispute == true && now < disputeTime){
            
        if(msg.sender == buyer){
         balances[buyer] = SafeMath.sub(balances[buyer], msg.value);
        balances[escrowOwner] = SafeMath.sub(balances[escrowOwner], msg.value);
        buyerjudgePayout = true;
        eState = EscrowState.buyerfeesDeposited;
        }
            if(msg.sender == seller){
        balances[seller] = SafeMath.sub(balances[seller], msg.value);
        balances[escrowOwner] = SafeMath.sub(balances[escrowOwner], msg.value);
        sellerjudgePayout = true;
        eState = EscrowState.sellerfeesDeposited;
            }
        }
        
    }
    function JudgeDecision(address _winner) public{
        require(msg.sender== escrowOwner);
        require(buyerdispute == true && now> disputeTime);
        if(buyerjudgePayout == true && sellerjudgePayout == true){
            
            winner = _winner;
        }
        if(buyerjudgePayout == true && sellerjudgePayout == false){
            
            winner = buyer;
        }
        if(buyerjudgePayout ==  false && sellerjudgePayout == true){
            winner = seller ;
        }
    }
    function getrefund() public{
        if(now>= x && buyerdispute == false){
        require(msg.sender == seller);
        balances[seller] = SafeMath.add(balances[seller], escrowCharge);
        eState = EscrowState.escrowComplete;
       
            
        }
        
        if(winner == buyer){
            require(msg.sender == buyer);
             balances[buyer] = SafeMath.add(balances[buyer], escrowCharge);
             escrowCharge =0;
             eState = EscrowState.escrowComplete;
        }
        
        if(winner == seller){
            require(msg.sender == seller);

        balances[seller] = SafeMath.add(balances[seller], escrowCharge);
        escrowCharge = 0;
        eState = EscrowState.escrowComplete;
        }
        
    }
    

   

    function checkEscrowStatus() public view returns (EscrowState) {
        return eState;
    }
    
    function getEscrowContractAddress() public view returns (address) {
        return address(this);
    }
    
    function getAllDeposits() public view returns (uint256[] memory) {
        return deposits;
    }
    
    function hasBuyerDispute() public view returns (bool) {
        if (buyerdispute) {
            return true;
        } else {
            return false;
        }
    }

    function hasSellerfeesPayout() public view returns (bool) {
        if (sellerjudgePayout) {
            return true;
        } else {
            return false;
        }
    }
    
    function hasBuyerfeesPayout() public view returns (bool) {
        if(buyerjudgePayout) {
            return true;
        }
        return false;
    }
    
   
  
   
  
    function killEscrow() public {
        selfdestruct(address(uint160(escrowOwner)));
    }

   
}