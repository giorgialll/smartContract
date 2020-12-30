// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.7.0;

//pragma experimental ABIEncoderV2;

//import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract CurriculumVitae is ERC721{
    
    address systemOwner; /* Indirizzo creatore del contratto */
        
    uint256 lastid;
    
        
    //-------------------- constructor ---------------------------------------------------------

    constructor() ERC721("JobManager","ITM") payable public {
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
        uint256[] jobCareer;
    }
    
    
      /*
    Lavori che attualmente sta svolgendo un lavoratore 
    */
    struct WorkerJobs {
        uint256[] jobHistory;
    }
    
     
    
     //-------------------- mapping ---------------------------------------------------------
    
    mapping (address => CV ) internal _CVby ; //Curriculum creato da un determinato address

    /*
     * Mapping che dato l'address del lavoratore consente di ottenere i lavori svolti
     */
    mapping (address => JobCareer ) internal _jobsCareer ;

   
    /*
    Mapping che per ogni lavoratore assegno un array degli id dei lavoro in corso
    così un lavoratore può fare più lavori
    */
    mapping(address => WorkerJobs) private _hiredinjobs;



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
                
                _CVby[msg.sender]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _telephoneNumber);
                
    }
    
     function updateAllCV(string memory _name,
                        string memory _surname,
                        string memory _gender,
                        string memory _dateOfBirth,
                        string memory _homeaddress,
                        string memory  _email,
                        uint32 _telephoneNumber) public{
    
               
                _CVby[msg.sender]= CV(msg.sender, _name, _surname, _gender, _dateOfBirth, _homeaddress, _email, _telephoneNumber);
                
    }
    
    
    function updateName(string memory _name) public{
                _CVby[msg.sender].name =_name;
                
    }
    
    function updateSurname(string memory _surname) public{
                _CVby[msg.sender].surname =_surname;
                
    }
    
    function insertJobCareer(uint256 _tokenID, address _addressWorker) public{
                _jobsCareer[_addressWorker].jobCareer.push(_tokenID);
    }
    
    function insertWorkerJob(uint256 _tokenID, address _addressWorker) public{
        _hiredinjobs[_addressWorker].jobHistory.push(_tokenID);
    }
    
    function deleteElementJobHistory(address addressWorker,uint256 _tokenid) public{
        
        uint lenghtHireJobs = _hiredinjobs[addressWorker].jobHistory.length; 
        
        for( uint i = 0 ; i < lenghtHireJobs  ; i++){
            if(_hiredinjobs[addressWorker].jobHistory[i] == _tokenid){
                _hiredinjobs[addressWorker].jobHistory[i] = _hiredinjobs[addressWorker].jobHistory[lenghtHireJobs -1];
                delete _hiredinjobs[addressWorker].jobHistory[lenghtHireJobs -1];
                _hiredinjobs[addressWorker].jobHistory.pop();
            }
        }
    }
    
    //-------------------- Getters ---------------------------------------------------------

    
    function getCV(address _idAddress) public view returns (
        string memory _name,
                        string memory _surname,
                        string memory _gender,
                        string memory _dateOfBirth,
                        string memory _homeaddress,
                        string memory  _email,
                        uint32 _telephoneNumber){
        
        CV memory cv = _CVby[_idAddress];
        
        return(cv.name,cv.surname,cv.gender,cv.dateOfBirth,cv.homeaddress,cv.email,cv.telephoneNumber);
    } 
    
     function getJobCareer() public view returns(uint256[] memory ){
        return _jobsCareer[msg.sender].jobCareer;
    }
    
    function getHiredJob() public view returns(uint256[] memory ){
        return _hiredinjobs[msg.sender].jobHistory;
    }

}