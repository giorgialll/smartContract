pragma solidity ^0.5.0;

import "./ERC721.sol";  


contract JobOfferManager is ERC721{
    
    address owner; /* Indirizzo creatore del contratto */

    uint32 lastid; // token numero di offerte create 


    
    // Struttura dati rappresentante un'offerta di lavoro
    struct jobOffer {
        uint256 expirationDate;   //data di scadenza  (in giorni)
        address  payable  worker;         //indirizzo del lavoratore
        address employer;       //indirizzo del datore di lavoro
        string name;            // nome offerta di lavoro
        string info;            // informazioni sull' offerta di lavoro
        uint8 workhours;        // numero ore di lavoro
        uint salary;         // quantità da pagare espressa in wei
    }
    
  
     // Array di offerte di lavoro
    struct Jobs {
        uint32[] jobs;
    }
    

    /*
    Lavori in corso di un lavoratore 
    */
    struct OnGoingJobs {
        uint32[] onGoingJobs;
    }
    
    constructor() payable public {
        owner = msg.sender;
    }
    
  
    
    /* 
    Mapping che data l'offerta ci dice se è scaduta o no
    */
    mapping( uint32 => bool) public _activeOffer; 

    
    /* 
    Mapping che associa ad un job token un booleano che indica se il lavoro è stato assegnato ad un lavoratore o meno
    - false: lavoro non ancora assegnato a nessun lavoratore
    - true: lavoro assegnato ad un lavoratore
    */
    mapping(uint32 => bool) public jobsAssigned;
    
    
    /* 
    Mapping che dato un datore di lavoro associo quanti soldi ha nel contratto
    */
    mapping(address => uint256) internal _depositOf;

    
    /* 
    Mapping che dato un datore di lavoro associo l'array degli id delle offerte create
    */
    mapping(address => Jobs) internal _offersBy;
    

     /* 
    Mapping che per ogni lavoratore assegno un array degli id dei lavoro in corso
    così un lavoratore può fare più lavori
    */
    mapping(address => OnGoingJobs) private _hiredinjobs;
    
    
    /* 
    Mapping che dato l'id dell'offerta otteniamo quali sono le sue caratteristiche
    */
    mapping(uint32 => jobOffer) private _jobs; 
    
      /* 
    Mapping che data l'id dell'offerta di lavoro (scaduta) indica se il denaro è già stato reso al datore di lavoro oppure no
    */
    mapping(uint32 => bool) public _moneyIsReturn;

    

    /*
     * 
     * funzione di fallback che è necessaria per catturare gli ether che vengono trasferiti al contratto
     */
    function() payable external { 
        //La funzione viene eseguita anche se il chiamante intendeva chiamare una funzione che non è disponibile. 
        require(msg.data.length == 0); 
        //preleva il valore che ho depositato e lo assegna
        _depositOf[msg.sender] += msg.value; 
    }
   
        /** Setters */
 
     
    /** Getters */
     /** Funzione che restituisce il numero delle offerte **/
     function getNumberOfOffers() public view returns(uint256 numberOfCompositions){
            return(lastid);
     }
     
    /* Funzione che restituisce il nome dell'offerta **/
    function getName(uint32  _tokenID) public view returns(string memory name) {
        return(_jobs[_tokenID].name);
    }
     
    function getExpirationDate(uint32  _tokenID) public view returns(uint256  expirationDate) {
         return(_jobs[_tokenID].expirationDate);
    }
    
    function getSalary(uint32  _tokenID) public view returns(uint  salary) {
         return(_jobs[_tokenID].salary);
    }
    
    /*
    * function: getAddressWorker
    View che permette di viasualizzare l'indirizzo del datore di lavoro data una determinata offerta
    */
    function getAddressWorker(uint32  _tokenID) public view returns(address  payable  worker) {
         return(_jobs[_tokenID].worker);
    }
    
    function getAddressEmployer(uint32  _tokenID) public view returns(address employer) {
         return(_jobs[_tokenID].employer);
    }
    
    function getInfo(uint32  _tokenID) public view returns(string memory info) {
        return(_jobs[_tokenID].info);
    }
    
    /*
     * function: getAmountHours
     * Restituisce ore di lavoro associate all'offerta di lavoro indicata dal token in input. 
     */ 
    function getAmountHours(uint32 _tokenID) public view returns(uint) {
        return _jobs[_tokenID].workhours; 
    }
    
      /*
     * function: getArrayActiveOffer
     * funzione che restituisce l'array di tutte le offerte attive che non sono ancora state assegnate 
     */
    function getArrayActiveOffer() public view returns(uint[]memory) {
        uint[] memory arrayOffersActive = new uint[](lastid);
        for(uint32 i=0 ; i < lastid ; i++){ //https://solidity.readthedocs.io/en/v0.4.24/types.html
            if( now <= ( _jobs[i].expirationDate) && _jobs[i].worker != address(0) ){
                arrayOffersActive[i] = i; //assegno l'indice del'offerta attiva 
            }
        }
        return arrayOffersActive;
    }
 
     /*
     * function: getJobOffer
     * Dato l'id dell'offerta restituisce le sue caratteristiche
     */
    function getJobOffer(uint32 token) public view 
    returns(

        address worker, 
        address employer, 
        string memory name, 
        string memory descritpion, 
        uint8 workhours, 
        uint256 totalSalary,
        uint256 expirationDate) 
        {
        return (
            //_jobs contiene le caratteristiche di un oggerta dato un token
            _jobs[token].worker,
            _jobs[token].employer,
            _jobs[token].name, 
            _jobs[token].info, 
            _jobs[token].workhours, 
            _jobs[token].salary,
            _jobs[token].expirationDate

            ); 
    }

    
    
      /*
     * function: getDepositedAmount
     * Restituisce il saldo del datore di lavoro sul contratto.
     */
     function getDepositedAmount() public view returns(uint256) {
        return _depositOf[msg.sender];
    }
    
    /*
     * function: getOffersBy
     * funzione che mostra le offerte create da un address
     */
    function getOffersBy(address _employer) public view returns(uint32[] memory jobOffers) {
        return _offersBy[_employer].jobs;
    }
    
    /* Funzione che restituisce l'array dei lavori che sta svolgendo un lavoratore */
    function getApplicantOf(address _worker) public view returns(uint32[] memory ){
        return _hiredinjobs[_worker].onGoingJobs;
    
    }
    

    function getTokenId() public view returns(uint){
        return lastid;
    
    }
    
   function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function getIsActiveOffer(uint32 _tokenid) public view returns(bool){
        return (now <= ( _jobs[_tokenid].expirationDate));
    
    }
    
    function getIsMoneyIsReturn(uint32 _tokenid) public view returns(bool){
        return _moneyIsReturn[_tokenid];
    }
    
    
    /*
     * function: pourMoney
     * Funzione che mi permette di versare i soldi nel contratto
     * Quanto vogliamo versare deve essere espresso in wei
     */
    function pourMoney(uint amount)  public payable{
        require(amount >= msg.value);
        _depositOf[msg.sender] = _depositOf[msg.sender] + amount ;
       
    }
    
 
   
    /* Il lavoro è stato termintaoto. Quindo devo trasferire l'importo relativo a quell'offerta all'indirizzo del lavoratore*/ 
    function payment(uint32 _tokenid)  external{
      
       
        require(_tokenid <= lastid,"Invalid Token Id");
        //require(_jobs[_tokenid].employer == msg.sender,"You aren't Employer");
        require(_jobs[_tokenid].worker != address(0),"There isn't a worker apply");
        
        uint salary = _jobs[_tokenid].salary;
        address payable addressWorker = _jobs[_tokenid].worker;
        uint lenghtHireJobs = _hiredinjobs[addressWorker].onGoingJobs.length; 
        
        for( uint i = 0 ; i < lenghtHireJobs  ; i++){
            if(_hiredinjobs[addressWorker].onGoingJobs[i] == _tokenid){
                _hiredinjobs[addressWorker].onGoingJobs[i] = _hiredinjobs[addressWorker].onGoingJobs[lenghtHireJobs -1];
                delete _hiredinjobs[addressWorker].onGoingJobs[lenghtHireJobs -1];
                _hiredinjobs[addressWorker].onGoingJobs.length--;
        
            }
        }
     
        addressWorker.transfer(salary);

    }
    
   
     /*
     * function: newJob
     * Funzione che crea una nuova offerta date in input tutte le sue caratteristiche
     */
    function newJob(uint256 _durationDate , string memory _name , string memory _info, uint8 _workhours, uint _salary)  public {
         assert( _depositOf[msg.sender] >= _salary);//, 'insufficient deposited amount');
        _depositOf[msg.sender] = _depositOf[msg.sender] - _salary;
        lastid++;
        address payable  nullAddress;
        //funzione che crea un nuovo token associa un proprietario al token 
        _mint(msg.sender,lastid);
        
        uint daysInseconds = now + _durationDate * 1 days;
        //uint daysInseconds = 1572825600;
        //uint daysInseconds = (now / 1 days + _durationDate) * 1 days;
        //uint daysInseconds = now + ( _durationDate * 1 seconds);

        _jobs[lastid]=jobOffer(daysInseconds,nullAddress, msg.sender, _name , _info, _workhours, _salary);
        _offersBy[msg.sender].jobs.push(lastid);
        _activeOffer[lastid] = true;
        _moneyIsReturn[lastid] = false;
    }
    
    //funzione che assume un lavoratore 
    function hireWorker( address payable _aworker, uint32 _tokenid ) public{
        require(_tokenid <= lastid);
        require(_jobs[_tokenid].worker == address(0));
        require(_jobs[_tokenid].employer == msg.sender);

        //l'offerta non deve essere scaduta
        require(now < ( _jobs[_tokenid].expirationDate));

        // modifier per richiedere che il msg.semder sia il proprietario del token (onlyJobOwner)        
        require(!jobsAssigned[_tokenid], "job already assigned");
        
        jobsAssigned[_tokenid]=true;
        _hiredinjobs[_aworker].onGoingJobs.push( _tokenid );
        _jobs[_tokenid].worker=_aworker; 
          
    }
    


    
    /*Funzione che rende i soldi al datore di lavoro nel caso in cui.
      1. l'offerta scadenza e non ha assunto nessuno
      i soldi della trasazione vengono persi */
      
    function moneyReturnsEemployer(uint32 _tokenid) public{
        // se l'offerta e scaduta e non è stata assegnata 
        //_jobs[_tokenid].worker == address(0 ) check if the address is not set (https://ethereum.stackexchange.com/questions/6756/ways-to-see-if-address-is-empty)
        require(now > ( _jobs[_tokenid].expirationDate));
        require(_moneyIsReturn[_tokenid] == false);
        require(_tokenid<= lastid);
        require(_jobs[_tokenid].employer == msg.sender);
        require(_jobs[_tokenid].worker == address(0));
        // se l'offerta è scaduta rendo il soldi al datore di lavoro
    
        _depositOf[msg.sender] = _depositOf[msg.sender] + _jobs[_tokenid].salary;

        /* Per evitare che la funzione venga richiamata più volte e aumentare così i soldi del _depositOf
            dopo che questa è stata chiamata il campo dell'offerta salary prende un valore nullo in modo che
            nel caso questa fosse di nuovo rivhiamata il soldi preseti in _depositOf non aumentano */
        _moneyIsReturn[_tokenid] = true; 
    }
    
 
}


