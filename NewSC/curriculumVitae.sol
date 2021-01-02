// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <8.0.0;

pragma experimental ABIEncoderV2;

//import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract CurriculumVitae is ERC721{
    
    address systemOwner; /* Indirizzo creatore del contratto */
        
    uint256 lastid;
    
        
    //-------------------- constructor ---------------------------------------------------------

    constructor() ERC721("JobManager","ITM") payable {
        systemOwner = msg.sender;
    }
    
    
    //-------------------- struct ---------------------------------------------------------
    
    struct CV{
        address idAddress;
        string name;
        string surname;
        string gender;
        string dateOfBirth;
        string homeaddress;
        string email;
        uint32 telephoneNumber;
        
    }
    
    /*Carriera del lavoratore con tutti gli id delle offerte per le quali è stato assunto in passato
    */
    struct JobCareer{
        uint256[] idjobCareer;
        string[] nameCareer;            
        string[] categoryCareer;            
        string[] positionCareer;            
        string[] durationCareer;
    }
    
    
      /*
    Lavori che attualmente sta svolgendo un lavoratore 
    */
    struct WorkerJobs {
        uint256[] jobIDHistory;
        string[] nameHistory;            
        string[] categoryHistory;            
        string[] positionHistory;            
        string[] durationHistory;
    }
    
     
     
    /*Dati sulla sua carriera lavorativa che il lavoratore decide di pubblicare
    */
    struct PubliCareer{
        string name;
        string surname;
        string gender;
        string dateOfBirth;
        string homeaddress;
        string email;
        uint32 telephoneNumber;
        uint256[] publicidjob;
        string[] publicname;            
        string[] publiccategory;            
        string[] publicposition;            
        string[] publicduration;
    }
    
     //-------------------- mapping ---------------------------------------------------------
    
    mapping (address => CV ) internal _CVby ; //Curriculum creato da un determinato address

    mapping (uint256 => CV ) internal _CV ; //Curriculum creato da un determinato address

    /*
     * Mapping che dato l'address del lavoratore consente di ottenere i lavori svolti
     */
    mapping (address => JobCareer ) internal _jobsCareer ;

   
    /*
    Mapping che per ogni lavoratore assegno un array degli id dei lavoro in corso
    così un lavoratore può fare più lavori
    */
    mapping(address => WorkerJobs) private _hiredinjobs;


  /*
     * Mapping che dato l'address del lavoratore consente di pubblicare i lavori svolti
     */
    mapping (uint256 => PubliCareer ) internal _publicjobsCareer ;



    //-------------------- modifiers ---------------------------------------------------------

   modifier onlyCVowner(uint256 _tokenCvId) {
        require(msg.sender == ownerOf(_tokenCvId));
        _;
    }
    //-------------------- functions ---------------------------------------------------------

   function createCV(string memory _name,
                        string memory _surname,
                        string memory _gender,
                        string memory _dateOfBirth,
                        string memory _homeaddress,
                        string memory  _email,
                        uint32 _telephoneNumber) public{
    
                lastid++;    
                _mint(msg.sender,lastid);
                
                
                //_CVby[msg.sender]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _telephoneNumber);
                
                _CV[lastid]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _telephoneNumber);
                
    }
    
     function updateAllCV(uint256 _idCV,
                        string memory _name,
                        string memory _surname,
                        string memory _gender,
                        string memory _dateOfBirth,
                        string memory _homeaddress,
                        string memory  _email,
                        uint32 _telephoneNumber) onlyCVowner(_idCV) public{
    
               
                //_CVby[msg.sender]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _telephoneNumber);
                _CV[_idCV]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _telephoneNumber);

                
    }
    

    
    function insertJobCareer(uint256 _tokenID,string memory _name,string memory _category,string memory _position,string memory _duration,address _addressWorker) public{
                _jobsCareer[_addressWorker].idjobCareer.push(_tokenID);
                _jobsCareer[_addressWorker].nameCareer.push(_name);
                _jobsCareer[_addressWorker].categoryCareer.push(_category);
                _jobsCareer[_addressWorker].positionCareer.push(_position);
                _jobsCareer[_addressWorker].durationCareer.push(_duration);
    }
    
    function insertWorkerJob(uint256 _tokenID,string memory _name,string memory _category,string memory _position,string memory _duration,address _addressWorker) public{
        _hiredinjobs[_addressWorker].jobIDHistory.push(_tokenID);
        _hiredinjobs[_addressWorker].nameHistory.push(_name);
        _hiredinjobs[_addressWorker].categoryHistory.push(_category);
        _hiredinjobs[_addressWorker].positionHistory.push(_position);
        _hiredinjobs[_addressWorker].durationHistory.push(_duration);
    }
    

    function deleteElementJobHistory(address addressWorker,uint256 _tokenid) external{
        
        uint lenghtHireJobs = _hiredinjobs[addressWorker].jobIDHistory.length; 
        
        for( uint i = 0 ; i < lenghtHireJobs  ; i++){
            if(_hiredinjobs[addressWorker].jobIDHistory[i] == _tokenid){
                _hiredinjobs[addressWorker].jobIDHistory[i] = _hiredinjobs[addressWorker].jobIDHistory[lenghtHireJobs -1];
                delete _hiredinjobs[addressWorker].jobIDHistory[lenghtHireJobs -1];
                _hiredinjobs[addressWorker].jobIDHistory.pop();
                
                //-----------------------------------------------------------------------------------
               _hiredinjobs[addressWorker].nameHistory[i] = _hiredinjobs[addressWorker].nameHistory[lenghtHireJobs -1];
               _hiredinjobs[addressWorker].categoryHistory[i] = _hiredinjobs[addressWorker].categoryHistory[lenghtHireJobs -1];
               _hiredinjobs[addressWorker].positionHistory[i] = _hiredinjobs[addressWorker].positionHistory[lenghtHireJobs -1];
               _hiredinjobs[addressWorker].durationHistory[i] = _hiredinjobs[addressWorker].durationHistory[lenghtHireJobs -1];

                delete _hiredinjobs[addressWorker].nameHistory[lenghtHireJobs -1];
                delete _hiredinjobs[addressWorker].categoryHistory[lenghtHireJobs -1];
                delete _hiredinjobs[addressWorker].positionHistory[lenghtHireJobs -1];
                delete _hiredinjobs[addressWorker].durationHistory[lenghtHireJobs -1];

                _hiredinjobs[addressWorker].nameHistory.pop();
                _hiredinjobs[addressWorker].categoryHistory.pop();
                _hiredinjobs[addressWorker].positionHistory.pop();
                _hiredinjobs[addressWorker].durationHistory.pop();
            }
        }
    }
    
    
    function setPubbliCV(uint256 _idCV,
                        bool _name,
                        bool _surname,
                        bool _gender,
                        bool _dateOfBirth,
                        bool _homeaddress,
                        bool _email,
                        bool _telephoneNumber,
                        uint256[] memory jobsDoneID) onlyCVowner(_idCV) public{
        
        uint lengthCareer = _jobsCareer[msg.sender].idjobCareer.length;
        uint lengthJDone = jobsDoneID.length;
        delete _publicjobsCareer[_idCV];
        
        
        for(uint i=0; i < lengthJDone; i++){
            if(jobsDoneID[i]<= lengthCareer){
                uint index = jobsDoneID[i] -1;
                _publicjobsCareer[_idCV].publicidjob.push(_jobsCareer[msg.sender].idjobCareer[index]);
                _publicjobsCareer[_idCV].publicname.push(_jobsCareer[msg.sender].nameCareer[index]);
                _publicjobsCareer[_idCV].publiccategory.push(_jobsCareer[msg.sender].categoryCareer[index]);
                _publicjobsCareer[_idCV].publicposition.push(_jobsCareer[msg.sender].positionCareer[index]);
                _publicjobsCareer[_idCV].publicduration.push(_jobsCareer[msg.sender].durationCareer[index]);
            }
        }
        
        if(_name)
            _publicjobsCareer[_idCV].name = _CV[_idCV].name;
        if(_surname)
            _publicjobsCareer[_idCV].surname = _CV[_idCV].surname;
        if(_gender)
            _publicjobsCareer[_idCV].gender = _CV[_idCV].gender;
        if(_dateOfBirth)
            _publicjobsCareer[_idCV].dateOfBirth = _CV[_idCV].dateOfBirth;
        if(_homeaddress)
            _publicjobsCareer[_idCV].homeaddress = _CV[_idCV].homeaddress;
        if(_email)
            _publicjobsCareer[_idCV].email = _CV[_idCV].email;
        if(_telephoneNumber)
            _publicjobsCareer[_idCV].telephoneNumber = _CV[_idCV].telephoneNumber;
    }
    

    
    
    //-------------------- Getters ---------------------------------------------------------

    function getpubliCV(uint256 _tokenId) public view returns (
                                                                string memory _name,
                                                                string memory _surname,
                                                                string memory _gender,
                                                                string memory _dateOfBirth,
                                                                string memory _homeaddress,
                                                                string memory  _email,
                                                                uint32 _telephoneNumber,
                                                                uint256[] memory _idJob,
                                                                string[] memory _nameCareer,
                                                                string[] memory _categoryCareer,
                                                                string[] memory _positionCareer,
                                                                string[] memory _durationCareer){
        
        PubliCareer memory pubCV = _publicjobsCareer[_tokenId];
        
        return (pubCV.name,
                pubCV.surname,
                pubCV.gender,
                pubCV.dateOfBirth,
                pubCV.homeaddress,
                pubCV.email,
                pubCV.telephoneNumber,
                pubCV.publicidjob,
                pubCV.publicname,
                pubCV.publiccategory,
                pubCV.publicposition,
                pubCV.publicduration);
    }
    
    
   /* function getCV(uint256 _tokenId) onlyCVowner(_tokenId) public view returns (
                                                                            string memory _name,
                                                                            string memory _surname,
                                                                            string memory _gender,
                                                                            string memory _dateOfBirth,
                                                                            string memory _homeaddress,
                                                                            string memory  _email,
                                                                            uint32 _telephoneNumber,
                                                                            uint256[] memory _idjobCareer,
                                                                            string[] memory _nameCareer,
                                                                            string[] memory _categoryCareer,
                                                                            string[] memory _positionCareer,
                                                                            string[] memory _durationCareer){
        
        CV memory cv = _CV[_tokenId];
        
        JobCareer memory jc= _jobsCareer[msg.sender]; 
        return(cv.name,cv.surname,cv.gender,cv.dateOfBirth,cv.homeaddress,cv.email,cv.telephoneNumber,jc.idjobCareer,
                jc.nameCareer, jc.categoryCareer,
                jc.positionCareer,
                jc.durationCareer);
    } */
    
    
    function getDataCV(uint256 _tokenId) onlyCVowner(_tokenId) public view returns (
                                                                            string memory _name,
                                                                            string memory _surname,
                                                                            string memory _gender,
                                                                            string memory _dateOfBirth,
                                                                            string memory _homeaddress,
                                                                            string memory  _email,
                                                                            uint32 _telephoneNumber
                                                                            ){
        
        CV memory cv = _CV[_tokenId];
        
        return(cv.name,cv.surname,cv.gender,cv.dateOfBirth,cv.homeaddress,cv.email,cv.telephoneNumber);
    }
    
     function getJobCareer() public view returns(uint256[] memory _idjobCareer,
                                                string[] memory _nameCareer,
                                                string[] memory _categoryCareer,
                                                string[] memory _positionCareer,
                                                string[] memory _durationCareer ){
        return (_jobsCareer[msg.sender].idjobCareer,
                _jobsCareer[msg.sender].nameCareer,
                _jobsCareer[msg.sender].categoryCareer,
                _jobsCareer[msg.sender].positionCareer,
                _jobsCareer[msg.sender].durationCareer);
    }
    
    function getHiredJob() public view returns(uint256[] memory, string[] memory,string[] memory,string[] memory,string[] memory ){
        return (_hiredinjobs[msg.sender].jobIDHistory,
                _hiredinjobs[msg.sender].nameHistory, 
                _hiredinjobs[msg.sender].categoryHistory,
                _hiredinjobs[msg.sender].positionHistory,
                _hiredinjobs[msg.sender].durationHistory);
    }
    

    function getOwnerOf(uint256 _tokenCvId, address _address) public view returns(bool){
        return (ownerOf(_tokenCvId) == _address);
    }

}
