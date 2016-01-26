contract Reserver{


//variables set at initialization

address owner = msg.sender;

//variables which are passed in with a constructor or registration function and then do not change:

uint deposit;
uint per_second_late_fee;
uint rental_period_in_seconds;

//variables that change with each new renter or function call:

uint current_penalty;
uint return_date;
address current_possessor;
address[] waitlist;
bool registeredYet;   //this can be removed when constructor is put back in place and regisrtation function removed

//constructor

//note: seeing as how 1000000000000000000 wei equals about .20 USD at the time of
//writing, 100000000000000000 (2.00 USD) might be a good value for _deposit and
//100000000000000000000000 (.000002 USD) might be a good _per_second_late_fee
//because .000002 x 60 x 60 x 24 = 0.1728 USD late fee per day

//note: the person who sets the contract becomes the first possessor of the item

//function Reserver(uint _deposit, uint _per_second_late_fee, uint _rental_period_in_seconds){
//deposit = _deposit;
//per_second_late_fee = _per_second_late_fee;
//rental_period_in_seconds = _rental_period_in_seconds;
//current_possessor = msg.sender;
//}

//add a register function, at least for time being, because current development environment does not allow for
//constructor when injecting contract onto testnet

     function register(uint _deposit, uint _per_second_late_fee, uint _rental_period_in_seconds) {
       if (msg.sender == owner && registeredYet == false) {
            deposit = _deposit;
            per_second_late_fee = _per_second_late_fee;
            rental_period_in_seconds = _rental_period_in_seconds;
            current_possessor = msg.sender;
       }
   }

//get into the waitlist for the item by calling this function and sending in the deposit amount

//note: any excess value sent in the message, over and above the deposit, is returned to the sender

function reserve(){
if (msg.value >= deposit){
waitlist.push(msg.sender);
msg.sender.send(msg.value - deposit);
}
}

//acknowledge that you have received the item (do not give the item to a new person unless they have called this)

//Note: this function first checks to make that the caller is the first person in the waitlist.
//If they are, it begins the process of refunding the current_possessor their deposit, if any. First, it 
//checks if there is currently an overdue fee due. If that is the case, and if the overdue fee is less 
//than the deposit, it returns the remainder. Next, it begins the process of rolling over the variables.
//First it sets the message sender as the current possessor. Then it deletes the first entry in the waitlist,
//in effect moving everyone on the waitlist up a spot. Next, it sets the new return date by adding the
//rental period to the current time. Lastly, it reverts the current_penalty to 0. 

function acknowledgeReception(){

if (msg.sender == waitlist[0]){

if ((now - return_date) >= 0){
current_penalty = ((now - return_date) * per_second_late_fee);
if (current_penalty < deposit){
current_possessor.send(deposit - current_penalty);
}
}

current_possessor = msg.sender;
delete waitlist[0];
return_date = now + rental_period_in_seconds;
current_penalty = 0;
}
}


//remove your name from the waitlist array, cancelling reservation

function cancelReservation(){
for(uint i = 0; i < waitlist.length; i++){
if (waitlist[i] == msg.sender){
delete waitlist[i];
}
} 
}


//a few functions to let people find out who the current possessor, the next in line, and the current possessor’s return date

function getCurrentPossessor() constant returns (address){
                   return current_possessor;
}

function getNextInLine() constant returns (address){
                   return waitlist[0];
}

function getReturnDate() constant returns (uint){
                   return return_date;
}


//function to destroy the contract via suicide, now called self-destruct. First returns a deposit 
//to all of the people on the waitlist. Then returns a deposit minus any applicable late fee to 
//the current possessor. Then pays out any remaining balance to the owner.

function kill(){

for(uint i = 0; i < waitlist.length; i++){
waitlist[i].send(deposit);
}

if ((now - return_date) >= 0){
current_penalty = ((now - return_date) * per_second_late_fee);
if (current_penalty < deposit){
current_possessor.send(deposit - current_penalty);
}
}
selfdestruct(current_possessor);
}


}