// SPDX-License-Identifier: MIT
// SPDX-License-Identifier: GPL-3.0

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
        string qualification;
        
    }
    
    /*Carriera del lavoratore con tutti gli id delle offerte per le quali è stato assunto in passato
    */
    struct JobCareer{
        uint256[] idjobCareer;
        string[] nameCareer;            
        string[] categoryCareer;            
        string[] positionCareer;            
    }
    
    
      /*
    Lavori che attualmente sta svolgendo un lavoratore 
    */
    struct CurrentJob{
        uint256[] jobIDCurrent;
        string[] nameCurrent;            
        string[] categoryCurrent;            
        string[] positionCurrent;            
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
        string qualification;
        uint256[] publicidjob;
        string[] publicname;            
        string[] publiccategory;            
        string[] publicposition;            
    }
    
    struct CVList {
            uint256[] CVlist;
    }

    
     //-------------------- mapping ---------------------------------------------------------
    

    mapping (uint256 => CV ) internal _CV ; 
    
    mapping (address => CVList ) internal _CVby ; //Curriculum creato da un determinato address


    /*
     * Mapping che dato l'address del lavoratore consente di ottenere i lavori svolti
     */
    mapping (address => JobCareer ) internal _jobsCareer ;

   
    /*
    Mapping che per ogni lavoratore assegno un array degli id dei lavoro in corso
    così un lavoratore può fare più lavori
    */
    mapping(address => CurrentJob) private _currentJobs;


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
                        string memory _qualification) public{
    
                lastid++;    
                _mint(msg.sender,lastid);
                
                _CVby[msg.sender].CVlist.push(lastid);

                
                _CV[lastid]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _qualification);
                
    }
    
     function updateAllCV(uint256 _idCV,
                        string memory _name,
                        string memory _surname,
                        string memory _gender,
                        string memory _dateOfBirth,
                        string memory _homeaddress,
                        string memory  _email,
                        string memory _qualification) onlyCVowner(_idCV) public{
    
               
                //_CVby[msg.sender]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _telephoneNumber);
                _CV[_idCV]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _qualification);

                
    }
    

    
    function insertJobCareer(uint256 _tokenID,string memory _name,string memory _category,string memory _position,address _addressWorker) public{
                _jobsCareer[_addressWorker].idjobCareer.push(_tokenID);
                _jobsCareer[_addressWorker].nameCareer.push(_name);
                _jobsCareer[_addressWorker].categoryCareer.push(_category);
                _jobsCareer[_addressWorker].positionCareer.push(_position);
    }
    
    function insertWorkerJob(uint256 _tokenID,string memory _name,string memory _category,string memory _position,address _addressWorker) public{
        _currentJobs[_addressWorker].jobIDCurrent.push(_tokenID);
        _currentJobs[_addressWorker].nameCurrent.push(_name);
        _currentJobs[_addressWorker].categoryCurrent.push(_category);
        _currentJobs[_addressWorker].positionCurrent.push(_position);
    }
    

    function deletefinisJobCurrent(address addressWorker,uint256 _tokenid) external{
        
        uint lenghtHireJobs = _currentJobs[addressWorker].jobIDCurrent.length; 
        
        for( uint i = 0 ; i < lenghtHireJobs  ; i++){
            if(_currentJobs[addressWorker].jobIDCurrent[i] == _tokenid){
                _currentJobs[addressWorker].jobIDCurrent[i] = _currentJobs[addressWorker].jobIDCurrent[lenghtHireJobs -1];
                delete _currentJobs[addressWorker].jobIDCurrent[lenghtHireJobs -1];
                _currentJobs[addressWorker].jobIDCurrent.pop();
                
                //-----------------------------------------------------------------------------------
               _currentJobs[addressWorker].nameCurrent[i] = _currentJobs[addressWorker].nameCurrent[lenghtHireJobs -1];
               _currentJobs[addressWorker].categoryCurrent[i] = _currentJobs[addressWorker].categoryCurrent[lenghtHireJobs -1];
               _currentJobs[addressWorker].positionCurrent[i] = _currentJobs[addressWorker].positionCurrent[lenghtHireJobs -1];

                delete _currentJobs[addressWorker].nameCurrent[lenghtHireJobs -1];
                delete _currentJobs[addressWorker].categoryCurrent[lenghtHireJobs -1];
                delete _currentJobs[addressWorker].positionCurrent[lenghtHireJobs -1];

                _currentJobs[addressWorker].nameCurrent.pop();
                _currentJobs[addressWorker].categoryCurrent.pop();
                _currentJobs[addressWorker].positionCurrent.pop();
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
                        bool _qualification,
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
        if(_qualification)
            _publicjobsCareer[_idCV].qualification = _CV[_idCV].qualification;
    }
    

    
    
    //-------------------- Getters ---------------------------------------------------------

    function getpubliCV(uint256 _tokenId) public view returns (
                                                                string memory _name,
                                                                string memory _surname,
                                                                string memory _gender,
                                                                string memory _dateOfBirth,
                                                                string memory _homeaddress,
                                                                string memory  _email,
                                                                string memory  _qualification,
                                                                uint256[] memory _idJob,
                                                                string[] memory _nameCareer,
                                                                string[] memory _categoryCareer,
                                                                string[] memory _positionCareer){
        
        PubliCareer memory pubCV = _publicjobsCareer[_tokenId];
        
        
       return (pubCV.name,
                pubCV.surname,
                pubCV.gender,
                pubCV.dateOfBirth,
                pubCV.homeaddress,
                pubCV.email,
                pubCV.qualification,
                pubCV.publicidjob,
                pubCV.publicname,
                pubCV.publiccategory,
                pubCV.publicposition);
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
                                                                            string memory  _qualification
                                                                            ){
        
        CV memory cv = _CV[_tokenId];
        
        return(cv.name,cv.surname,cv.gender,cv.dateOfBirth,cv.homeaddress,cv.email,cv.qualification);
    }
    
     function getJobCareer() public view returns(uint256[] memory _idjobCareer,
                                                string[] memory _nameCareer,
                                                string[] memory _categoryCareer,
                                                string[] memory _positionCareer){
        return (_jobsCareer[msg.sender].idjobCareer,
                _jobsCareer[msg.sender].nameCareer,
                _jobsCareer[msg.sender].categoryCareer,
                _jobsCareer[msg.sender].positionCareer);
    }
    
    function getCurrentJob() public view returns(uint256[] memory _idjobCareer,
                                                string[] memory _nameCareer,
                                                string[] memory _categoryCareer,
                                                string[] memory _positionCareer){
        return (_currentJobs[msg.sender].jobIDCurrent,
                _currentJobs[msg.sender].nameCurrent, 
                _currentJobs[msg.sender].categoryCurrent,
                _currentJobs[msg.sender].positionCurrent);
    }
    

    function getOwnerOf(uint256 _tokenCvId, address _address) public view returns(bool){
        return (ownerOf(_tokenCvId) == _address);
    }
    
    function getTotalCV() public view returns(uint256){
        return lastid;
    }
    
    function getAddress(uint256 _tokenId) public view returns(address){
         return _CV[_tokenId].idAddress;
    }
    
    function getCVby() public view returns(uint256[] memory _CVlist){
         return _CVby[msg.sender].CVlist;
    }
    

}
