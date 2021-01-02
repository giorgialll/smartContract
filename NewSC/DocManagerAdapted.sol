// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <=8.0.0;

//pragma experimental ABIEncoderV2;

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

import "./JobManagerMix.sol";

contract DOCManager is ERC721{

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
            uint256[] jobIDlist;
        }
        
        
     //-------------------- mapping ---------------------------------------------------------

    mapping (uint256 => JobList ) internal _jobsOf ;    
    
    mapping (address => DOCList ) internal _DOCby ;// Documenti creati da un determinato address


    mapping (uint256 => DOC ) internal _DOC ;


    //-------------------- modifiers ---------------------------------------------------------

    modifier onlyActive{
        require(constractState == enumContractState.ACTIVE, "this smart contract is deactivated!!!");
        _;
    }


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
        setDOC(lastid,_siteAddress,_duration,_director,_personnelManager,_firstAidOfficier,_numberOfWorkers,_holidays,_dpi,_weeklyRest,_rights);
        return docID;
    }


    function setDOC(uint256 _DOCid,
                    string memory _siteAddress,
                    uint16 _duration,
                    string memory _director,
                    string memory _personnelManager,
                    string memory _firstAidOfficier,
                    uint16 _numberOfWorkers,
                    uint16 _holidays,
                    string memory _dpi,
                    uint16 _weeklyRest,
                    string memory _rights) onlyDOCowner(_DOCid)  internal {
        
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
    
    
    function edit_DOC(  uint256 _DOCid,
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
                        string memory _duration,
                        uint _salary,        
                        uint256 _expirationDays,
                        uint32 _workdays) onlyDOCowner(_DOCid) public returns(uint256 jobID){
        require(_jobsOf[_DOCid].jobIDlist.length<_DOC[_DOCid].numberOfWorkers, "You already reached the number Of Workers");        
        require(_DOCid <= lastid);
        JobManager jm = JobManager(sc_JobManager);
        jobID = jm.remoteCreateJob(msg.sender, _DOCid, _name, _category, _position, _duration, _salary, _expirationDays, _workdays);
        _jobsOf[_DOCid].jobIDlist.push(jobID);
        return(jobID);
    }
    
     function hireWorker(uint256 _DOCid, uint256 _jobid, address payable _aworker) onlyDOCowner(_DOCid) public{
        require(_DOCid <= lastid);

         JobManager jm = JobManager(sc_JobManager);
         jm.hireWorker(_aworker,  _jobid);
    }
    
    //-------------------- Getters ---------------------------------------------------------

   /*function getDOC(uint256 _DOCid) public view returns (string memory _siteAddress,
                                                        uint16 _duration,
                                                        string memory _director,
                                                        string memory _personnelManager,
                                                        string memory _firstAidOfficier,
                                                        uint16 _numberOfWorkers,
                                                         uint16 _holidays,
                                                        string memory _dpi,
                                                        uint16 _weeklyRest,
                                                        string memory _rights){
        return(_DOC[_DOCid].siteAddress, 
               _DOC[_DOCid].duration, 
               _DOC[_DOCid].director, 
               _DOC[_DOCid].personnelManager,  
               _DOC[_DOCid].firstAidOfficier,  
               _DOC[_DOCid].numberOfWorkers,
               _DOC[_DOCid].holidays,  
               _DOC[_DOCid].dpi,
               _DOC[_DOCid].weeklyRest,
               _DOC[_DOCid].rights);
    }
    */
    
    function getNameDOC(uint256 _DOCid) public view returns (string memory siteAddress){
        return (_DOC[_DOCid].siteAddress);   
    }
    
    function getRemoteTxOrigin() public view returns(address){
        JobManager jm = JobManager(sc_JobManager);
        return jm.getTxOrigin();
    }
    
    
    function getJobsOf(uint256 _OPSid) public view returns (uint256[] memory joblist){
        return _jobsOf[_OPSid].jobIDlist;
    }
    
    function getLenJobsOf(uint256 _OPSid) public view returns (uint256 length){
        return _jobsOf[_OPSid].jobIDlist.length;
    }
    
    function getJobManagerAddress() public view returns(address payable offer_address ) {
        return sc_JobManager;
    }

    function getIsSetJobManagerAddress() public view returns(bool answer) {
        if(sc_JobManager==address(0)) answer = false;
        else answer = true;
        return answer;
    }

    /*function getApplicantOf(uint32 _idOffer) public view returns(address[] memory ){
        JobManager jm = JobManager(sc_JobManager);
        return(jm.getApplicants(_idOffer));
        
    }*/

    function getOPSListBy(address _employer) public view returns (uint256[] memory){
        return _DOCby[_employer].DOClist;
    }
    
    
     /** Funzione che restituisce il numero dei DOC creati **/
     function getNumberDOC() public view returns(uint256 numberOfCompositions){
            return(lastid);
     }

}
