// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.7.0;

//pragma experimental ABIEncoderV2;

//import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

import "./DocManagerAdapted.sol"; //importare solo l'intefaccia

import "./curriculumVitae.sol";

contract JobManager is ERC721{
    address sc_DOCManager;
    
    address systemOwner; /* Indirizzo creatore del contratto */
    uint256 lastid; // token numero di offerte create
    
    enum enumContractState{ACTIVE, DEACTIVATED}  
    
    enumContractState constractState;
    
    enum enumState {VACANT,ASSIGNED}

    address sc_cv;


   
    //-------------------- constructor ---------------------------------------------------------

    constructor() ERC721("JobManager","ITM") payable public {
        systemOwner = msg.sender;
    }
    
    
    //-------------------- struct ---------------------------------------------------------

    /*
    Lavori che attualmente sta svolgendo un lavoratore 
    */
    struct WorkerJobs {
        uint256[] jobHistory;
    }
    
    
    /*Carriera del lavoratore con tutti gli id delle offerte per le quali è stato assunto in passato
    */
   /* struct JobCareer{
        uint256[] jobCareer;
    }*/
    
    
    /*
    Array delle offerte di lavoro
    */
    struct JobList {
        uint256[] jobList;
    }
    
    /*
    Candidati alle offerte lavorative
    */
    struct Applicants {
        address[] applicants;
    }
    
    // Struttura dati rappresentante un'offerta di lavoro

    struct Job {
        uint256 DOCid;
        string name;
        string category;            // informazioni sull' offerta di lavoro
        string position;            // informazioni sull' offerta di lavoro
        string duration;
        enumState state;
        uint salary;         // quantità da pagare espressa in wei
        uint32 workdays;        // numero ore di lavoro
        address  payable  hiredWorker;         //indirizzo del lavoratore
        address employer;       //indirizzo del datore di lavoro
        uint256 expirationDate;   //data di scadenza  (in giorni)
    }

   //Offerte a cui il lavoratore ha chiesto di aggiungere le ore di lavoro
    struct RequestHours{
        uint256[] idOffer;
        uint[] numberHours;
        
    }
    
     //-------------------- mapping ---------------------------------------------------------
    /*
    Mapping che dato un datore di lavoro associo l'array degli id delle offerte create
    */
    mapping(address => JobList) internal _offersBy;



     /*
    Mapping che per ogni lavoratore assegno un array degli id dei lavoro in corso
    così un lavoratore può fare più lavori
    */
    //mapping(address => WorkerJobs) private _hiredinjobs;


    /* 
    Mapping che dato l'id dell'offerta otteniamo quali sono le sue caratteristiche
    */
    mapping(uint256 => Job) private _jobs;


      /*
    Mapping che data l'id dell'offerta di lavoro (scaduta) indica se il denaro è già stato reso al datore di lavoro oppure no
    */
    mapping(uint256 => bool) public _moneyIsReturn;
    
    
    /*
    Mapping che dato un datore di lavoro associo quanti soldi ha nel contratto
    */
    mapping(address => uint256) internal _depositOf;


    /* SC EMPLOYMENT
    Mappig che dato l'id dell'offerta di lavoro associa quali sono i candidati 
    */
    mapping(uint256 => Applicants) private _applicants;


  
    /* 
    Mapping che data l'offerta ci dice se è scaduta o no
    */
    mapping( uint256 => bool) public _activeOffer; // OK sostituito con enumerazione


    /* Mappig che dato l'id dell'offerta associo la richiesta da parte del lavoratore con il nuemero
     di ore da far aggiungere a quelle svolte
     Le ore sono espresse in minuti in modo da considerare anche il quarto d'ora ecc**/
    mapping (uint256 => uint ) internal _requestHours ;
    
    mapping (address => RequestHours ) internal _requestHoursForEmployer ;
    
    /* Mapping necessario per tenere traccia delle ore di lavoro svolte da ciascun lavoratore
       prende il token dell'offerta e vengono assegnate le ore svolte al lavoratore 
    */
    mapping(uint256 => uint) public _workhours; 
    
    /*
     * Mapping che dato l'address del lavoratore consente di ottenere i lavori svolti
     */
    //mapping (address => JobCareer ) internal _jobsCareer ;


    //-------------------- modifiers ---------------------------------------------------------

  /*  modifier onlyActive{
        require(constractState == enumContractState.ACTIVE, "this smart contract is deactivated!!!");
        _;
    }

    modifier onlyJobCreator(uint256 _tokenID){
        require(ownerOf(_tokenID)==msg.sender || getApproved(_tokenID)==msg.sender, "you are not the Job Owner");
        _;
    }*/
    
    modifier onlySystemOwner{
        require(systemOwner==msg.sender, "you are not the system Owner");
        _;
    }
    
    modifier onlyDOCowner(uint256 _tokenOPSId) {
        DOCManager doc = DOCManager(sc_DOCManager);
        address constructionCompany = doc.ownerOf(_tokenOPSId); 
        require(constructionCompany  == msg.sender|| msg.sender==sc_DOCManager, "you are not the Construction Company which owns this OPS");                //Richiede che la funzione che richiama questo modificatore sia esseguita solo dal datore di lavoro
        _;
    }




    //-------------------- functions ---------------------------------------------------------

    receive() external payable { }

    /*
     *
     * funzione di fallback che è necessaria per catturare gli ether che vengono trasferiti al contratto
     */
    fallback()  external payable {
        //La funzione viene eseguita anche se il chiamante intendeva chiamare una funzione che non è disponibile.
        require(msg.data.length == 0);
        //preleva il valore che ho depositato e lo assegna
        _depositOf[msg.sender] += msg.value;
    }
    
       
    /*
     * function: pourMoney
     * Funzione che mi permette di versare i soldi nel contratto
     * Quanto vogliamo versare deve essere espresso in wei
     */
    function pourMoney(uint amount)  public payable{
        require(amount >= msg.value, "Deposit eth in the contract");
        _depositOf[msg.sender] = _depositOf[msg.sender] + amount ;
       
    }
    
    
    /*
     * function: newJob
     * Funzione che crea una nuova offerta date in input tutte le sue caratteristiche
     */

//    function createJob(uint256 _OPSid) onlyOPSowner(_OPSid) public returns(uint256 jobID) {

    function createJob(uint256 _OPSid,
                        string memory _name,
                        string memory _category,           
                        string memory _position,            
                        string memory _duration,
                        uint _salary,        
                        uint256 _expirationDays,
                        uint32 _workdays) onlyDOCowner(_OPSid) public{
        
        
        assert( _depositOf[msg.sender] >= _salary);
        _depositOf[msg.sender] = _depositOf[msg.sender] - _salary;
        lastid++;
        //funzione che crea un nuovo token associa un proprietario al token 
        _mint(msg.sender,lastid);
        
        uint daysInseconds = now + _expirationDays * 1 days;
   
         _jobs[lastid]=Job(
            _OPSid,
            _name,
            _category,
            _position,
            _duration,
            enumState.VACANT,
            _salary,
            _workdays,
            address(0),
            msg.sender,
            daysInseconds);
        _offersBy[msg.sender].jobList.push(lastid);

        _activeOffer[lastid] = true;
        _moneyIsReturn[lastid] = false;        
    }
    
    
     function remoteCreateJob(address _employer,
                       uint256 _OPSid,
                        string memory _name,
                        string memory _category,           
                        string memory _position,            
                        string memory _duration,
                        uint _salary,        
                        uint256 _expirationDays,
                        uint32 _workdays) public  returns(uint256 jobID) {
         assert( _depositOf[_employer] >= _salary);//, 'insufficient deposited amount');
   

        _depositOf[_employer] = _depositOf[_employer] - _salary;
        lastid++;
        //funzione che crea un nuovo token associa un proprietario al token 
        _mint(_employer,lastid);
        
        uint daysInseconds = now + _expirationDays * 1 days;
   
        _jobs[lastid]=Job(
            _OPSid,
            _name,
            _category,
            _position,
            _duration,
            enumState.VACANT,
            _salary,
            _workdays,
            address(0),
            _employer,
            daysInseconds);        
        
       _offersBy[_employer].jobList.push(lastid);

        _activeOffer[lastid] = true;
        _moneyIsReturn[lastid] = false;
        return lastid;
    }
    
    
    

    
     //Funzione che permette al lavoratore di candidarsi a una offerta
    function application(uint256 _tokenID) public{
        require(_tokenID <= lastid);
        require(now <= _jobs[_tokenID].expirationDate);
        require(_jobs[_tokenID].state==enumState.VACANT);
        
        for(uint i=0 ; i<_applicants[_tokenID].applicants.length ; i++ ){
            require(_applicants[_tokenID].applicants[i] != msg.sender);
        }
        _applicants[_tokenID].applicants.push(msg.sender);

    }
    
     /*
      * Funzione che consente al lavoratore di ritirare la propria candidatura
      */
    function withdrawCandidacy(uint256 _tokenID) public{
        require(_tokenID <= lastid);
        require(now <= _jobs[_tokenID].expirationDate);
        require(_jobs[_tokenID].state==enumState.VACANT);

       
        uint arrayLength = _applicants[_tokenID].applicants.length;
        
        for(uint i = 0; i <arrayLength; i ++){
            if(_applicants[_tokenID].applicants[i] == msg.sender){
                _applicants[_tokenID].applicants[i] = _applicants[_tokenID].applicants[arrayLength-1];
                delete _applicants[_tokenID].applicants[arrayLength-1];
                _applicants[_tokenID].applicants.pop();
            }
        }
    }
    
    
    /* 
     *Funzione che consente di assumenre un lavoratore
    */
    //    function hire( address payable _aworker, uint256 _tokenid ) onlyOPSowner(_jobs[_tokenid].OPSid) public{
    function hire( address payable _aworker, uint256 _tokenid ) onlyDOCowner(_jobs[_tokenid].DOCid) public{
        require(_tokenid <= lastid);
        //require(_jobs[_tokenid].worker == address(0));
        //require(_jobs[_tokenid].employer == msg.sender);

        //l'offerta non deve essere scaduta
        require(now < ( _jobs[_tokenid].expirationDate));
        require(_jobs[_tokenid].state == enumState.VACANT, "job already assigned");
        
        _jobs[_tokenid].hiredWorker=_aworker;
        _jobs[_tokenid].state=enumState.ASSIGNED;
        
        CurriculumVitae cv = CurriculumVitae(sc_cv);
        cv.insertWorkerJob(_tokenid,_aworker);
        
        //_hiredinjobs[_aworker].jobHistory.push(_tokenid);
    }
    
    
        
    /* Funzione che consente al lavoratore di richiedere di aggiungere le ore di lavoro */
    function requestAdditionalHours(uint256 _tokenid, uint8 _numberOfHours) public {
        require(_tokenid <= lastid);

        require( _jobs[_tokenid].hiredWorker == msg.sender);

        _requestHours[_tokenid] += _numberOfHours;
        
        uint arrayLength = _requestHoursForEmployer[_jobs[_tokenid].employer].idOffer.length;
        bool flag = false;
        
        for(uint i = 0; i <arrayLength; i ++){
            if(_requestHoursForEmployer[_jobs[_tokenid].employer].idOffer[i] == _tokenid){
                flag = true;
                _requestHoursForEmployer[_jobs[_tokenid].employer].numberHours[i] = _requestHours[_tokenid] ;
            }
        }
        if(flag == false){
            _requestHoursForEmployer[_jobs[_tokenid].employer].idOffer.push(_tokenid);
            _requestHoursForEmployer[_jobs[_tokenid].employer].numberHours.push(_requestHours[_tokenid]);

        }
    }
    

    
    
     /* 
      * Funzione che esegue il pagamente al lavoratore nel momento in cui il lavoro è stato termintaoto. 
      */ 
    function payment(uint256 _tokenid)  internal{
      
       
        require(_tokenid <= lastid,"Invalid Token Id");
        //require(_jobs[_tokenid].employer == msg.sender,"You aren't Employer");
        require(_jobs[_tokenid].state != enumState.VACANT,"There isn't a worker apply");

        
        uint salary = _jobs[_tokenid].salary;
        address payable addressWorker = _jobs[_tokenid].hiredWorker;
        /*uint lenghtHireJobs = _hiredinjobs[addressWorker].jobHistory.length; 
        
        for( uint i = 0 ; i < lenghtHireJobs  ; i++){
            if(_hiredinjobs[addressWorker].jobHistory[i] == _tokenid){
                _hiredinjobs[addressWorker].jobHistory[i] = _hiredinjobs[addressWorker].jobHistory[lenghtHireJobs -1];
                delete _hiredinjobs[addressWorker].jobHistory[lenghtHireJobs -1];
                _hiredinjobs[addressWorker].jobHistory.pop();
            }
        }*/
        
        CurriculumVitae cv = CurriculumVitae(sc_cv);
        cv.deleteElementJobHistory(addressWorker,_tokenid);

    
        addressWorker.transfer(salary);
    }
    
         /* 
     *Funzione che mi permette di aggiornare le ore di un lavoratore
     */
    function addWorkdays(uint256 _tokenID, uint32 _numberOfHours) public onlyDOCowner(_jobs[_tokenID].DOCid)   {

        require(_tokenID <= lastid);
        require(_jobs[_tokenID].state == enumState.ASSIGNED);
        
        _workhours[_tokenID] += _numberOfHours; 
        _requestHours[_tokenID] = 0;
        
      uint arrayLength = _requestHoursForEmployer[msg.sender].idOffer.length;
        
        for(uint i = 0; i <arrayLength; i ++){
            if(_requestHoursForEmployer[msg.sender].idOffer[i] == _tokenID){
                _requestHoursForEmployer[msg.sender].idOffer[i] = _requestHoursForEmployer[msg.sender].idOffer[arrayLength-1];
                _requestHoursForEmployer[msg.sender].numberHours[i] = _requestHoursForEmployer[msg.sender].numberHours[arrayLength-1];
               delete _requestHoursForEmployer[msg.sender].idOffer[arrayLength-1];
               delete _requestHoursForEmployer[msg.sender].numberHours[arrayLength-1];
                _requestHoursForEmployer[msg.sender].idOffer.pop();
                _requestHoursForEmployer[msg.sender].numberHours.pop();

            }
        }
        
        
        if(_workhours[_tokenID] >= _jobs[_tokenID].workdays){
            jobCompleted(_tokenID);        
        }
    }
    
    
    /*
     * Funzione che viene eseguita quando il lavoro è stato completato e cioè sono state raggiunte le ore lavorative accordate
    */
    function jobCompleted(uint256 _tokenID) public onlyDOCowner(_jobs[_tokenID].DOCid){

        require(_tokenID <= lastid);

        // Richiede che siano state raggiunte le ore di lavoro 
        uint ore = _jobs[_tokenID].workdays;
        require(_workhours[_tokenID] >= ore );
        
       uint arrayLength = _applicants[_tokenID].applicants.length;
        
        for(uint i = 0; i <arrayLength; i ++){
            if(_applicants[_tokenID].applicants[i] == msg.sender){
                _applicants[_tokenID].applicants[i] = _applicants[_tokenID].applicants[arrayLength-1];
                delete _applicants[_tokenID].applicants[arrayLength-1];
                _applicants[_tokenID].applicants.pop();
            }
        }
        
        address payable addressWorker = _jobs[_tokenID].hiredWorker;
        
        
        CurriculumVitae cv = CurriculumVitae(sc_cv);
        cv.insertJobCareer(_tokenID,addressWorker);

        //_jobsCareer[addressWorker].jobCareer.push(_tokenID);

        //i soldi vengono versati al lavoratore 
        payment(_tokenID);
   }
   
   
   
     /*Funzione che rende i soldi al datore di lavoro nel caso in cui.
      1. l'offerta scadenza e non ha assunto nessuno
      i soldi della trasazione vengono persi */
    
    function moneyReturnsEemployer(uint256 _tokenID) public onlyDOCowner(_jobs[_tokenID].DOCid) {
        // se l'offerta e scaduta e non è stata assegnata 
        //_jobs[_tokenid].worker == address(0 ) check if the address is not set (https://ethereum.stackexchange.com/questions/6756/ways-to-see-if-address-is-empty)
        require(now > ( _jobs[_tokenID].expirationDate));
        require(_moneyIsReturn[_tokenID] == false);
        require(_tokenID<= lastid);
        require(_jobs[_tokenID].employer == msg.sender);
        require(_jobs[_tokenID].state == enumState.VACANT);
        // se l'offerta è scaduta rendo il soldi al datore di lavoro
    
        _depositOf[msg.sender] = _depositOf[msg.sender] + _jobs[_tokenID].salary;

        _moneyIsReturn[_tokenID] = true; 
    }


    function setDOCManager(address _docManager) onlySystemOwner public {
      sc_DOCManager = _docManager;  
      
    } 
    
    function setCV(address _curriculumvitae) onlySystemOwner public {
        sc_cv = _curriculumvitae;  
    } 
    
    
    //-------------------- Getters ---------------------------------------------------------


    function getOPSowner(uint256 _tokenOPSId) public view returns(address) {
        //OPSManager ops = OPSManager(sc_OPSManager);
        //address constructionCompany = ops.ownerOf(_tokenOPSId); 
       // return constructionCompany;
        
    }
    
    
    function getTxOrigin() public view returns(address) {
        return tx.origin;
    }
    
     /** Funzione che restituisce il numero delle offerte **/
     function getNumberOfOffers() public view returns(uint256 numberOfCompositions){
            return(lastid);
     }



    function getWorker(uint32  _tokenID) public view returns(address payable  worker) {
         return(_jobs[_tokenID].hiredWorker);
    }

    function getActiveOffers() public view returns(uint[] memory) {
        uint[] memory arrayOffersActive = new uint[](lastid);
        for(uint32 i=0 ; i < lastid ; i++){ //https://solidity.readthedocs.io/en/v0.4.24/types.html
            if( _jobs[i].state == enumState.VACANT) {
                arrayOffersActive[i] = i; //assegno l'indice del'offerta attiva
            }
        }
        return arrayOffersActive;
    }
    
    function getApplicants(uint32  _tokenID) public view returns(address[] memory) {
         return(_applicants[_tokenID].applicants);
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
    function getOffersBy(address _employer) public view returns(uint256[] memory jobOffers) {
        return _offersBy[_employer].jobList;
    }


    /* Funzione che restituisce l'array dei lavori che sta svolgendo un lavoratore */
   /* function getWorkerJobs(address _worker) public view returns(uint256[] memory ){
        return _hiredinjobs[_worker].jobHistory;

    }*/


    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }


    
    function approveOPS() public {
        setApprovalForAll(sc_DOCManager, true);
    }
    
    /*
     * function: getAmountHours
     * Restituisce ore di lavoro associate all'offerta di lavoro indicata dal token in input. 
     */ 
    function getAmountHours(uint256 _tokenID) public view returns(uint) {
        return _jobs[_tokenID].workdays; 
    }
    
      /*
     * function: getArrayActiveOffer
     * funzione che restituisce l'array di tutte le offerte attive che non sono ancora state assegnate 
     */
    function getArrayActiveOffer() public view returns(uint[]memory) {
        uint[] memory arrayOffersActive = new uint[](lastid);
        for(uint32 i=0 ; i < lastid ; i++){ //https://solidity.readthedocs.io/en/v0.4.24/types.html
            if( now <= ( _jobs[i].expirationDate) && _jobs[i].hiredWorker != address(0) ){
                arrayOffersActive[i] = i; //assegno l'indice del'offerta attiva 
            }
        }
        return arrayOffersActive;
    }
    
}


