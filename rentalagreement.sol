contract RentalAgreement {
    address apartmentOwner;
    address apartmentRenter;
    string  decryptionPassword;
    bool rentPaid = false;
    bool keySent = false;
    bool keyReceived = false;
    uint rentalDate;
    uint rentalFee;
    
    
    function RentalAgreement(address renter, uint _rentalFee, uint _rentalDate){
        apartmentOwner = msg.sender; 
        apartmentRenter = renter; 
        rentalFee = _rentalFee;   
        rentalDate = _rentalDate; 
    }
    
    function payRent(){
        if (msg.sender == apartmentRenter && now <= rentalDate && msg.value >= rentalFee) {
                rentPaid = true;
            } else {
                msg.sender.send(msg.value);
            }
    }
    
    function setKey(string _decryptionPassword){
               if (msg.sender == apartmentOwner && now <= rentalDate && rentPaid == true){
                   decryptionPassword = _decryptionPassword;
                   keySent = true;
                   msg.sender.send(this.balance);
               }
        
    }
    
        function getKey() public returns (string) {
               if (msg.sender == apartmentRenter && now > rentalDate && rentPaid == true && keySent == true){
                   keyReceived = true;
                   return decryptionPassword;
               }
        
    }
    
        function refund(){
               if (msg.sender == apartmentRenter && now > rentalDate && rentPaid == true && keySent == false){
                   msg.sender.send(this.balance);
               }
        
    }
    
function kill(){
    if(msg.sender == apartmentOwner){
        suicide(apartmentOwner);
    }
}  
    
}
