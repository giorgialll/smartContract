// SPDX-License-Identifier: MIT
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <8.0.0;

//pragma experimental ABIEncoderV2;

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

import "./JobManager.sol";

contract DOCManager is ERC721{
    address sc_cv; 
    address payable sc_JobManager; // indirizzo del contratto che rappresenta un offerta di lavoro
    address payable systemOwner; //indirizzo del creatore del contratto

    uint256 lastid;

    
    enum enumContractState{ACTIVE, DEACTIVATED}
    
    enumContractState constractState;

    enum enumState{DRAFT, PUBLISHED}
    
    
    //-------------------- struct ---------------------------------------------------------

    struct DOCList {
            uint256[] DOClist;
    }

    
    // Struttura dati rappresentante un'offerta di lavoro
    struct DOC {
        address employer;                   // datore di lavoro
        string siteAddress;                 // indirizzo del luogo di lavoro
        uint16 duration;                    // numero giorni lavorativi
        string director;
        string personnelManager;            // responsabile del personale
        string firstAidOfficier;            // informazioni sull' offerta di lavoro
        uint16 numberOfWorkers;             // numero di lavoratori
        
        uint16 holidays;                    //giorni festivi o ferie
        string dpi;
        uint16 weeklyRest;                  // riposo settimanale
        string rights;                      // diritti dei lavoratori
        enumState state;

    }
    struct JobList {
            uint256[] jobIDlist;                //lista dei lavori che sono stati creati
            address[] numTotalWorkers;          //lavoratori assunti per ciascun DOC
        }
        
        
     //-------------------- mapping ---------------------------------------------------------

    mapping (uint256 => JobList ) internal _jobsOf ;    
    
    mapping (address => DOCList ) internal _DOCby ;// Documenti creati da un determinato address


    mapping (uint256 => DOC ) internal _DOC ;


    //-------------------- modifiers ---------------------------------------------------------

   /* modifier onlyActive{
        require(constractState == enumContractState.ACTIVE, "this smart contract is deactivated!!!");
        _;
    }*/


    modifier onlyDOCowner(uint256 _tokenDOCId) {
        require(msg.sender == ownerOf(_tokenDOCId));
        _;
    }

    modifier onlySystemOwner {
        require(msg.sender == systemOwner);
        _;
    }
    
    
    //-------------------- constructor ---------------------------------------------------------

    constructor() ERC721("JobManager","ITM") payable  {
        systemOwner = msg.sender;
    }


    //-------------------- functions ---------------------------------------------------------

    /*
     * function: setJobOfferAddress
     * Imposta l' indirizzo SC JobOfferManager
     **/
    function setJobManagerAddress(address payable job_addressContract) onlySystemOwner public {
        sc_JobManager = job_addressContract;
    }
    
    function setCVAddress(address payable cv_addressContract) onlySystemOwner public {
        sc_cv = cv_addressContract;
    }


    function createDOC(string memory _siteAddress,
                        uint16 _duration,
                        string memory _director,
                        string memory _personnelManager,
                        string memory _firstAidOfficier,
                        uint16 _numberOfWorkers,
                        uint16 _holidays,
                        string memory _dpi,
                        uint16 _weeklyRest,
                        string memory _rights) public returns(uint256 docID){
                            
        lastid++;    
        docID=lastid;
        _mint(msg.sender,docID);
       _DOCby[msg.sender].DOClist.push(docID);
       
       _DOC[docID]=DOC(
                        msg.sender,
                        _siteAddress,
                        _duration,
                        _director,
                        _personnelManager,
                        _firstAidOfficier,
                        _numberOfWorkers,
                        _holidays,
                        _dpi,
                        _weeklyRest,
                        _rights,
                        enumState.PUBLISHED
                    );
        return docID;
    }


    
    function editDOC(  uint256 _DOCid,
                        string memory _siteAddress,
                        uint16 _duration,
                        string memory _director,
                        string memory _personnelManager,
                        string memory _firstAidOfficier,
                        uint16 _numberOfWorkers,
                        uint16 _holidays,
                        string memory _dpi,
                        uint16 _weeklyRest,
                        string memory _rights) public{
        
        require(_DOCid <= lastid);
        
         _DOC[_DOCid]=DOC(
            msg.sender,
            _siteAddress,
            _duration,
            _director,
            _personnelManager,
            _firstAidOfficier,
            _numberOfWorkers,
            _holidays,
            _dpi,
            _weeklyRest,
            _rights,
            enumState.PUBLISHED
        );
    
    }

    
    
    
    
   /* function depositETH(uint _valueDeposit) public{
        JobManager jm = JobManager(sc_JobManager);
        jm.pourMoney(_valueDeposit);
    }
    */
   
   
  
    
    function addJobToDOC(uint256 _DOCid, string memory _name,
                        string memory _category,           
                        string memory _position,            
                        uint _salary,        
                        uint256 _expirationDays,
                        uint32 _workdays) onlyDOCowner(_DOCid) public returns(uint256 jobID){
        require(_DOCid <= lastid);
        JobManager jm = JobManager(sc_JobManager);
        jobID = jm.createJob(msg.sender, _DOCid, _name, _category, _position, _salary, _expirationDays, _workdays);
        _jobsOf[_DOCid].jobIDlist.push(jobID);
        return(jobID);
    }
    
     function hireWorker(uint256 _DOCid, uint256 _jobid, address payable _aworker, uint256 _tokenidCV) onlyDOCowner(_DOCid) public{
        require(_DOCid <= lastid);
        require( _jobsOf[_DOCid].numTotalWorkers.length < _DOC[_DOCid].numberOfWorkers);
        CurriculumVitae cv = CurriculumVitae(sc_cv);
        require (cv.getOwnerOf(_tokenidCV,_aworker) == true);

        _jobsOf[_DOCid].numTotalWorkers.push(_aworker);
         JobManager jm = JobManager(sc_JobManager);
         jm.hire(_aworker,  _jobid,_tokenidCV);
    }
    
    //-------------------- Getters ---------------------------------------------------------

  /* CI SONO TROPPE VARIABILI IN OUTPUT: DA PROBLEMI
  function getDOC(uint256 _DOCid) public view returns (string memory _siteAddress,
                                                        uint16 _duration,
                                                        string memory _director,
                                                        string memory _personnelManager,
                                                        string memory _firstAidOfficier,
                                                        uint16 _numberOfWorkers,
                                                         uint16 _holidays,
                                                        string memory _dpi,
                                                        uint16 _weeklyRest,
                                                        string memory _rights){
                                                        
        DOC memory d = _DOC[_DOCid];

        return(d.siteAddress, 
               d.duration, 
               d.director, 
               d.personnelManager,  
               d.firstAidOfficier,  
               d.numberOfWorkers,
               d.holidays,  
               d.dpi,
               d.weeklyRest,
               d.rights);
    }*/
    
    function getDOCsiteAddress(uint256 _DOCid) public view returns (string memory _siteAddress){
        return(_DOC[_DOCid].siteAddress);
    }
    
    function getDOCduration(uint256 _DOCid) public view returns (uint16 _duration){
        return(_DOC[_DOCid].duration);
    }
    
    function getDOCdirector(uint256 _DOCid) public view returns (string memory _director){
        return(_DOC[_DOCid].director);
    }
    function getDOCpersonnelManager(uint256 _DOCid) public view returns (string memory _personnelManager){
        return( _DOC[_DOCid].personnelManager);
    }
    
    function getDOCfirstAidOfficier(uint256 _DOCid) public view returns (string memory _firstAidOfficier){
        return( _DOC[_DOCid].firstAidOfficier);
    }
    
    function getDOCnumberOfWorkers(uint256 _DOCid) public view returns (uint16 _numberOfWorkers){
        return(_DOC[_DOCid].numberOfWorkers);
    }
    
    function getDOCholidays(uint256 _DOCid) public view returns (uint16 _holidays){
        return(_DOC[_DOCid].holidays);
    }
    
    function getDOCdpi(uint256 _DOCid) public view returns (string memory _dpi){
        return(_DOC[_DOCid].dpi);
    }
    
    function getDOCweeklyRest(uint256 _DOCid) public view returns (uint16 _weeklyRest){
        return(_DOC[_DOCid].weeklyRest);
    }
    
    function getDOCrights(uint256 _DOCid) public view returns (string memory _rights){
        return(_DOC[_DOCid].rights);
    }
    
    
      function getDOCemployer(uint256 _DOCid) public view returns (address _employer){
        return(_DOC[_DOCid].employer);
    }
    
    
    
    //______________________________________________________________________________________________________________________
    
    function getJobManagerAddress() public view returns(address payable offer_address ) {
        return sc_JobManager;
    }
    
    function getIsSetJobManagerAddress() public view returns(bool answer) {
        if(sc_JobManager==address(0)) answer = false;
        else answer = true;
        return answer;
    }
    
    function getApplicantOf(uint32 _idOffer) public view returns(address[] memory _addressApplicant, uint256[] memory _idCV){
        JobManager jm = JobManager(sc_JobManager);
        return(jm.getApplicants(_idOffer));
        
    }   
    
    
    function getJobsOf(uint256 _OPSid) public view returns (uint256[] memory joblist){
        return _jobsOf[_OPSid].jobIDlist;
    }
    
    function getRemoteTxOrigin() public view returns(address){
        JobManager jm = JobManager(sc_JobManager);
        return jm.getTxOrigin();
    }
    

    function getLenJobsOf(uint256 _OPSid) public view returns (uint256 length){
        return _jobsOf[_OPSid].jobIDlist.length;
    }
    
   
    function getOPSListBy(address _employer) public view returns (uint256[] memory){
        return _DOCby[_employer].DOClist;
    }
    
    
     /** Funzione che restituisce il numero dei DOC creati **/
     function getNumberDOC() public view returns(uint256 numberOfCompositions){
            return(lastid);
     }
     
     function getNameDOC(uint256 _DOCid) public view returns (string memory siteAddress){
        return (_DOC[_DOCid].siteAddress);   
    }
    
    function getNumWorkersAssumed(uint256 _DOCid) public view returns (uint256 _workersAssumed){
        return (_jobsOf[_DOCid].numTotalWorkers.length);   
    }
    
     
    
    //____________AGGIUNTE________________________
      function getDeposit() public view returns(uint256){
        JobManager jm = JobManager(sc_JobManager);
        return jm.getDepositJ(msg.sender);
    }

}
