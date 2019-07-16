pragma solidity ^0.5.0;

import "./ERC721.sol";
import "./Deposit.sol";


contract Employment is ERC721{
    address owner; //indirizzo del creatore del contratto
    address payable sc_JobOfferManager; // indirizzo del contratto che rappresenta un offerta di lavoro


    constructor() payable public {
        owner = msg.sender;
    }

    //Candidature dei lavoratori
    struct Applicant{
        address[] applicant;
    }
    // Mapping necessario per tenere traccia delle ore di lavoro svolte da ciascun lavoratore
    // prende il token dell'offerta e vengono assegnate le ore svolte al lavoratore
    mapping(uint32 => uint8) public workhours;

    /** Mappig che dato l'id dell'offerta di lavoro associa quali sono i candidati **/
    mapping (uint32=> Applicant ) internal _applicantsOf ;


    /*
     * modifier: onlyEmployer
     * Modificatore per permettere l'esecuzione di certe funzioni solo al datore di lavoro.
     */
    modifier onlyEmployer(uint32 _tokenId) {
        JobOfferManager app = JobOfferManager(sc_JobOfferManager);
        address employer = app.ownerOf(_tokenId); /* app è una varibile del tipo di contratot JobOfferManager, quindi possiamoottenere l'indirizzo
                                                            del datore di lavoro usando il metodo */

        require(msg.sender == employer);                //Richiede che la funzione che richiama questo modificatore sia esseguita solo dal datore di lavoro
        _;
    }
    /*
     * function: setJobOfferAddress
     * Imposta l' indirizzo SC JobOfferManager
     **/
    function setJobOfferAddress(address payable offer_address) public {
        sc_JobOfferManager = offer_address;
    }

   //In input ho il token riferito all'offerta di lavoro
   function jobCompleted(uint32 _tokenIDOffer) public{
        JobOfferManager app = JobOfferManager(sc_JobOfferManager);
        // Richiede che siano state raggiunte le ore di lavoro
        require(workhours[_tokenIDOffer] == app.getAmountHours(_tokenIDOffer));
        //i soldi vengono versati al lavoratore
        app.payment(_tokenIDOffer);


   }
   /* Funzione che mi permette di aggiornare le ore di un lavoratore
   Verificare se l'offerta ha un lavoratore assegnato
   */
    function addWorkdays(uint32 _tokenIDOffer, uint8 numberOfHours) onlyEmployer(_tokenIDOffer) public {
        JobOfferManager offer = JobOfferManager(sc_JobOfferManager);
        require(ownerOf(_tokenIDOffer) == msg.sender);
        //l'offerta di lavoro non deve essere scaduta
        require(offer.getAddressWorker(_tokenIDOffer) !=  address(0));

        workhours[_tokenIDOffer] += numberOfHours; //incremento il numero di ore svolte dal lavoratore


    }

    // Funzione che permette di visualizzare le offerte attive quelle che ancora non sono state assegnate

    function getActiveOffer() public view returns(uint[] memory ){
        JobOfferManager offer = JobOfferManager(sc_JobOfferManager);
        return offer.getArrayActiveOffer();

    }

    //Funzione che permette al datore di lavoro di visualizzare la carriera di un lavoratore

    function showHistoryWorker(address payable worker) public view returns(uint[] memory){

    }


    //Funzione che permette al lavoratore di candidarsi a una offerta
    function workerApplies(uint32 _tokenIDOffer, address candidateWorker) public{
        JobOfferManager offer = JobOfferManager(sc_JobOfferManager);

        //l'offerta non deve essere scaduta
        require(offer.getisActiveOffer(_tokenIDOffer) != false);
        require(offer.getAddressWorker(_tokenIDOffer) !=  address(0));

        _applicantsOf[_tokenIDOffer].applicant.push(candidateWorker);

    }

    //Il lavoratore ritira la candidatura relativa a un'offerta
    function withdrawCandidacy(uint32 _tokenIDOffer, address candidateWorker) public{

        //l'offerta di lavoro non deve essere assegnata a nessuno per ritirarla
        JobOfferManager offer = JobOfferManager(sc_JobOfferManager);
        require(offer.getisActiveOffer(_tokenIDOffer) != false);
        // la può ritirare se nessuno è ancora stato assunto
        require(offer.getAddressWorker(_tokenIDOffer) !=  address(0));
        //può ritirarsi solo se non è stato assunto
        require(offer.getAddressWorker(_tokenIDOffer) !=  candidateWorker);


        uint arrayLength = _applicantsOf[_tokenIDOffer].applicant.length;

        for(uint i = 0; i <arrayLength; i ++){
            if(_applicantsOf[_tokenIDOffer].applicant[i] == candidateWorker){
                delete _applicantsOf[_tokenIDOffer].applicant[i];
                _applicantsOf[_tokenIDOffer].applicant.length -- ;
            }
        }
    }


}