contract MyFuture {

address buyer;
address seller;
address trustedthirdparty;
uint numberofunits;
uint deliverydate;
uint futureprice;
uint spotprice;
uint margin;
uint upperlimitmultiple;
bool sellerPaid = false;
bool buyerPaid = false;
bool delivered = false;
bool cancelled = false;

function MyFuture (uint units, uint date, uint fprice, uint _margin, address _trustedthirdparty) {
buyer = msg.sender;
numberofunits = units;
deliverydate = date;
futureprice = fprice;
margin = _margin;
trustedthirdparty = _trustedthirdparty;
}

function sellerPay(){
if (msg.sender == seller && msg.value >= ((futureprice * numberofunits)*upperlimitmultiple) && now <= deliverydate && cancelled == false){    
sellerPaid = true;    
}else{
    msg.sender.send(msg.value);
}
}

function buyerPay(){
if (msg.sender == buyer && msg.value >= (futureprice * numberofunits) && now <= deliverydate && cancelled == false){
buyerPaid = true;
seller.send(margin);
}
else {
msg.sender.send(msg.value);
}
}

function deliver (uint _spotprice){
if (msg.sender == trustedthirdparty && now <= deliverydate && buyerPaid == true && sellerPaid == true && cancelled == false){
spotprice = _spotprice;
if ((spotprice * numberofunits) < (futureprice * numberofunits)){
buyer.send((futureprice * numberofunits) - (spotprice * numberofunits));
seller.send(this.balance);
delivered = true;
}
else {
    if ((spotprice * numberofunits) >= ((futureprice * numberofunits)*upperlimitmultiple)){
    seller.send(this.balance);
      delivered = true;  
      }else {
          buyer.send(((spotprice * numberofunits) - (futureprice * numberofunits)) + (futureprice * numberofunits)); 
      seller.send(this.balance);
      delivered = true;
      }
      }
    }
    }

function cancel (){
    if ((msg.sender == buyer || msg.sender == seller) && now <= deliverydate && buyerPaid == true && sellerPaid == true && cancelled == false){
    buyer.send(futureprice * numberofunits);
    suicide(seller);
}
}
}