pragma solidity ^0.5.0;

import "./ERC721.sol";

//Fissare MAX id


contract JobOfferManager is ERC721{
    
    address owner; /* Indirizzo creatore del contratto */
    //address _worker; /* Indirizzo del contratto che rappresenta un lavoratore */
    
    uint32 lastid; // token

    
    // Struttura dati rappresentante un'offerta di lavoro
    struct jobOffer {
        uint256 expirationDate;   //data di scadenza  (in giorni)
        address  payable  worker;         //indirizzo del lavoratore
        address employer;       //indirizzo del datore di lavoro
        string name;            // nome offerta di lavoro
        string info;            // informazioni sull' offerta di lavoro
        uint8 workhours;        // numero ore di lavoro
        uint256 salary;         // quantità da pagare espressa in wei
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
    
    
    /* 
    Mapping che data la scadenza dell'offerta ci dice se è scaduta o no
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
    

    
    constructor() payable public {
        owner = msg.sender;
    }
    

    /*
     * 
     * funzione di fallback che è necessaria per catturare gli ether che vengono trasferiti al contratto
     */
    function() payable external { 
        //La funzione viene eseguita anche se il chiamante intendeva chiamare una funzione che non è disponibile. 
        require(msg.data.length == 0); 
        //_balanceOf[msg.sender] += msg.value; 
        //preleva il valore che ho depositato e lo assegna
        _depositOf[msg.sender] += msg.value; 
    }
    
    
    
    /** Getters */

      /*
     * function: getAmountHours
     * Restituisce ore di lavoro associate all'offerta di lavoro indicata dal token in input. 
     */ 
    function getAmountHours(uint32 _tokenID) public view returns(uint8) {
        return _jobs[_tokenID].workhours; 
    }
    
    
    //--------------------------
    
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
        uint256 totalSalary) 
        {
        return (
            //_jobs contiene le caratteristiche di un oggerta dato un token
            _jobs[token].worker,
            _jobs[token].employer,
            _jobs[token].name, 
            _jobs[token].info, 
            _jobs[token].workhours, 
            _jobs[token].salary
            ); 
    }

    
    
    /*function getBalance() public view returns(uint) {
        return _balanceOf[msg.sender];
    }*/
    
     /*
     * function: getDepositedAmount
     * Restituisce il saldo del datore di lavoro sul contratto.
     */
     function getDepositedAmount() public view returns(uint) {
        return _depositOf[msg.sender];
    }
    
    /*
     * function: getOffersBy
     * funzione che mostra le offerte create da un address
     */
    function getOffersBy(address _employer) public view returns(uint32[] memory jobOffers) {
        return _offersBy[_employer].jobs;
    }
    
    /*
     * function: pourMoney
     * Funzione che mi permette di versare i soldi nel contratto
     */
    function pourMoney(uint256 amount)  public payable{
        //Perchè uguale?
        require(_depositOf[msg.sender] == amount);
        _depositOf[msg.sender] = _depositOf[msg.sender] + amount ;
       
    }
    
    /* Il lavoro è stato termintaoto. Quindo devo trasferire l'importo relativo a quell'offerta all'indirizzo del lavoratore*/ 
    function payment(uint32 _tokenid)  public payable{
        //verifico che i soldi nel contratto siano maggiori o uguali rispetto a quelli da versare al lavoratore 
        //veridico se èpossibile effettuare il trasferiemento
        require(_depositOf[msg.sender] >= _jobs[_tokenid].salary);
        //address worker = _jobs[_tokenid].worker;
        //trasferisco i soldi all'indirizzo del lavoraotre 
        //worker.transfer.gas(400000)(_jobs[_tokenid].salary); 
        
        _jobs[_tokenid].worker.transfer(_jobs[_tokenid].salary); 

    }
    
     /*
     * function: newJob
     * Funzione che crea una nuova offerta date in input tutte le sue caratteristiche
     */
    function newJob(uint256 _durationDate , string memory _name , string memory _info, uint8 _workhours, uint256 _salary)  public {
        assert( _depositOf[msg.sender] >= _salary);//, 'insufficient deposited amount');
        _depositOf[msg.sender] = _depositOf[msg.sender] - _salary;
        lastid++;
        address payable  nullAddress;
        //funzione che crea un nuovo token associa un proprietario al token 
        _mint(msg.sender,lastid);
        _jobs[lastid]=jobOffer(_durationDate+(now*1 days),nullAddress, msg.sender, _name , _info, _workhours, _salary);
        _offersBy[msg.sender].jobs.push(lastid);
        
    
    }
    
    //funzione che assume un lavoratore 
    function hireWorker( address payable _aworker, uint32 _tokenid ) public {
        //l'offerta non deve essere scaduta
        require(_activeOffer[_tokenid] == false , "offer expired");
        // modifier per richiedere che il msg.semder sia il proprietario del token (onlyJobOwner)        
        require(ownerOf(_tokenid)==msg.sender , "you are not the employer");
        require(!jobsAssigned[_tokenid], "job already assigned");
        
        jobsAssigned[_tokenid]=true;
        _hiredinjobs[_aworker].onGoingJobs.push( _tokenid );
        _jobs[_tokenid].worker=_aworker; 
          
    }
    
    // funzione che mi dice se l'offerta è scaduta oppure no 
    function offerExpired(uint32 _tokenid) public  returns(bool) {
        
        
        if (now >= _jobs[_tokenid].expirationDate * 1 days) {
            _activeOffer[_tokenid] = true;
            return true;
        }else
        {
            _activeOffer[_tokenid] = false;
            return false;
        }

    }
    
    /*Funzione che rende i soldi al datore di lavoro nel caso in cui.
      1. l'offerta scadenza e non ha assunto nessuno
      i soldi della trasazione vengono persi */
      
    function moneyReturnsEemployer(uint32 _tokenid) public{
        // se l'offerta e scaduta e non è stata assegnata 
        //_jobs[_tokenid].worker == address(0 ) check if the address is not set (https://ethereum.stackexchange.com/questions/6756/ways-to-see-if-address-is-empty)
        if(_activeOffer[_tokenid] && _jobs[_tokenid].worker == address(0)){
            // se l'offerta è scaduta rendo il soldi al datore di lavoro

            _depositOf[msg.sender] = _depositOf[msg.sender] + _jobs[_tokenid].salary;

        }
    }
    
    
}

