//Let’s create a short term rental agreement smart contract for Ethereum — 
//the kind of agreement that an apartment owner might use if someone 
//was going to rent their place for a night or a week. 

//Now this is really important. We’re going to create a contract that is between 
//a specific apartment owner and a specific renter. It’s not a standing offer 
//that you put on the blockchain and anyone can come and accept accept. 
//Further, we’re going to assume that these two parties have some kind of 
//pre-existing relationship and a way of communicating off-blockchain.

//The reason that is important is this: the way our contract works is that our 
//owner is going to issue this contract to the blockchain. Around the same 
//time, they’re going to send an encrypted apartment entry code to the renter. 
//They might use a service like encipher.it, for example, to do this. If the 
//renter pays the rental fee before the rental date, they’re going to get the key 
//or password to that encrypted entry code. The reason we can’t put both 
//the encrypted entry code and the key together on the blockchain should be 
//obvious. The blockchain is transparent. Anyone could decrypt the entry code 
//and run amok in the apartment.

contract RentalAgreement {

    //declare variables

    address apartmentOwner;
    address apartmentRenter;
    string  decryptionPassword;
    bool rentReceived = false;
    bool keyReceived = false;
    bool keySent = false;
    bool rentSent = false;
    bool killApproved = false;
    uint rentalDate;
    uint rentalFee;
    
    //constructor

    function RentalAgreement(address renter, uint _rentalFee, uint _rentalDate) {
        apartmentOwner = msg.sender; 
        apartmentRenter = renter; 
        rentalFee = _rentalFee;   
        rentalDate = _rentalDate; 
    }
    
    //function through which renter can pay the rental fee
	
	function payRent() {
        if (msg.sender == apartmentRenter && now <= rentalDate && msg.value >= rentalFee) {
                rentReceived = true;
            } else {
                msg.sender.send(msg.value);
            }
    }

    //function through which owner can set the key to decrypt the door access code    

    function setKey(string _decryptionPassword) {
               if (msg.sender == apartmentOwner && now <= rentalDate && rentRecieved == true){
                   decryptionPassword = _decryptionPassword;
                   keyReceived = true;
                   msg.sender.send(this.balance);
               }
        
    }
    
    //function through which renter can retreive the key that the owner has set

        function getKey() public returns (string) {
               if (msg.sender == apartmentRenter && now > rentalDate && keyReceived == true){
                   keySent = true;
                   return decryptionPassword;
               }
        
    }

    //function through which owner can retrieve the rental fee

        function getPaid() {
               if (msg.sender == apartmentOwner && now > rentalDate && keySent == true){
                   msg.sender.send(this.balance);
                   rentSent = true;
               }
        
    }

    //function through which renter can receive a refund if the renter paid but the key was not sent by rental date

        function refund(){
               if (msg.sender == apartmentRenter && now > rentalDate && rentReceived == true && keyReceived == false){
                   msg.sender.send(this.balance);
               }
        
    }

    //function through which renter can approve the contract’s undoing

        function killApprove(){
                if(msg.sender == apartmentRenter){
                    killApproved == true;
    }
} 

    //function through which owner can suicide the contract, sending the rental fee, if received, back to the renter 
  
        function kill(){
                if(msg.sender == apartmentOwner && killApproved == true){
                    suicide(apartmentRenter);
    }
}  
    
}
