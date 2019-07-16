// Documentation
// https://github.com/ethereum/wiki/wiki/JavaScript-API

//1. Caricare web3 e lanciare la funzione startApp (che lavora come una main)
window.addEventListener('load', function () {

    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof web3 !== 'undefined') {
        // Use Mist/MetaMask's provider
        web3js = new Web3(web3.currentProvider);
    } else {
        console.log('No web3? You should consider trying MetaMask!')
        // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
        web3js = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    }

    // Now you can start your app & access web3 freely:
    startApp()

});

//creo una variabile globale per l'address del contratto
var cAddress;
var myaddress = web3.eth.accounts[0];
var numberOfOffers = 0;
var aJobOffer = {id: 0, expirationDate: 0, worker: "",  employer: "", name: "", info: "" , workhours: 0, salary: 0   };
var newJob = {id:0 , expirationDate: 0,name: "", info: "" ,  workhours: 0, salary: 0   };


document.getElementById("InputnuovaOfferta").style.display="none";
document.getElementById("InputVersamento").style.display="none";
document.getElementById("numberOffers").style.display="none";



var startApp = function () {

    //quando il documento è pronto
    $(document).ready(function () {


        $("#buttonSub").click(function () {
            document.getElementById("numberOffers").style.display="block";
            document.getElementById("InputVersamento").style.display="block";
            document.getElementById("InputnuovaOfferta").style.display="block";

            cAddress = document.getElementById("cAddress").value;
            //console.log(cAddress);
            //Verifico che sia un address valido (è sincrono e non serve callback)
            if (web3.isAddress(cAddress)) {
//                console.log("reading");
                loadContractInfo(cAddress, showNumberOfOffers);
//                console.log("read");
            } else {
                alert('There was an error fetching your accounts.');

            }
            //showSelector();
            viewOffers();
            //viewAddOffer(cAddress);

        });
    });
}

var viewOffers = function (noc) {
    var contentRow = $('#numberOffers');
    contentRow.find(".numberOfworks").text(noc);
    var allOffers = $('#allOffers');

    for (i = 1; i <= noc; i++) {
        loadOffers(i, showOffer);
    }


}


var loadContractInfo = function (address, callback) {
    numberOfOffers = 0;
    $.getJSON("solidity/JobOfferManager.json", function (cABI) {
        const ManagerContract = web3.eth.contract(cABI).at(address);
        ManagerContract.getNumberOfOffers.call(
            (err, res) => {
                if (err != null) {
                    alert('There was an error fetching the contract.');
                } else {
                    numberOfOffers = web3.toDecimal(res);
                    callback(numberOfOffers)

                }
            });
    });

}


var showNumberOfOffers = function (noc) {
    var contentRow = $('#numberOffers');
    contentRow.find(".numberOfworks").text(noc);
    //showSelector(noc)
    viewOffers(noc)
}




//caricamento dalla blockchain dei dati dell'elemento scelto
var loadOffers = function (id, callback) {
    numberOfOffers = 0;
    aJobOffer.id = id;
    $.getJSON("solidity/JobOfferManager.json", function (cABI) {

        const ManagerContract = web3.eth.contract(cABI).at(cAddress);
        ManagerContract.getName.call(id,
            (err, res) => {
                if (err != null) {
                    console.log(err);
                } else {
                    aJobOffer.name = res;
                    ManagerContract.getInfo.call(id,
                        (err, res) => {
                            if (err != null) {
                                console.log(err);
                            } else {
                                aJobOffer.info = res;
                                ManagerContract.getExpirationDate.call(id,
                                    (err, res) => {
                                        if (err != null) {
                                            console.log(err);
                                        } else {
                                            aJobOffer.expirationDate = res;
                                            ManagerContract.getSalary.call(id,
                                                (err, res) => {
                                                    if (err != null) {
                                                        console.log(err);
                                                    } else {
                                                        aJobOffer.salary = res;
                                                        ManagerContract.getAddressEmployer.call(id,
                                                            (err, res) => {
                                                                if (err != null) {
                                                                    console.log(err);
                                                                } else {
                                                                    aJobOffer.employer = res;
                                                                    ManagerContract.getAmountHours.call(id,
                                                                        (err, res) => {
                                                                            if (err != null) {
                                                                                console.log(err);
                                                                            } else {
                                                                                aJobOffer.workhours = res;
                                                                                callback(aJobOffer);
                                                                            }
                                                                        });
                                                                }
                                                            });
                                                    }
                                                });
                                        }
                                    });

                            }
                        });
                }
            });
    });
}


//visualizzazione dati dell'elemento scelto
var showOffer = function (aCompositionOffer) {
    var compositionTemplate = $('#compositionTemplate');
    var compositionRow = $('#compositionRow');
    $("#panel-title").html(aCompositionOffer.name);
    $("#composition-info").html(aCompositionOffer.info);
    $("#composition-ID").html(aCompositionOffer.id);
    compositionTemplate.find(".composition-workhours").text(aCompositionOffer.workhours);
    compositionTemplate.find(".composition-salary").text(aCompositionOffer.salary);
    compositionTemplate.find(".composition-expirationDate").text(aCompositionOffer.expirationDate);
    compositionTemplate.find(".composition-employer").text(aCompositionOffer.employer);




    //Se è scaduta disattivo il pulsante per candidarsi
   /* if (aCompositionOffer.published) {
        compositionTemplate.find('.btn-vote').val(aCompositionOffer.id);
    } else {
        compositionTemplate.find('.btn-vote').toggleClass("active disabled");
    }

    compositionTemplate.find(".composition-votes").text(aCompositionOffer.votes);
    compositionTemplate.find('.composition-votes').attr("id", "composition-votes-" + aComposition.id); */
    compositionRow.html(compositionTemplate.html());
    // Se voglio vederle aggiunte devo usare la class row e usare append
    //compositionRow.append(compositionTemplate.html());
}


//VOTO

//pulsante di voto
$(document).ready(function () {
    $('#compositionRow').on('click', '.btn-vote', function () {
        console.log(this.value);
        var id = this.value;
        voteComposition(id, refreshVotes);
    });
});


//chiamata al contratto per votare (non funziona su firefox)
var voteComposition = function (id, callback) {

    $.getJSON("solidity/JobOfferManager.json", function (cABI) {
        console.log(cAddress);

        const ManagerContract = web3.eth.contract(cABI).at(cAddress);
        ManagerContract.vote(id, {from: myaddress},
            (err, res) => {
                if (err != null) {
                    console.log(err);
                } else {
                    console.log(res);
                    ManagerContract.getVotes.call(id,
                        (err, res) => {
                            if (err != null) {
                                console.log(err);
                            } else {
                                callback(id, res)
                            }
                        });
                }
            });
    });
}

//aggiorna l'elemento del voto
var refreshVotes = function (id, votes) {
    $("#composition-votes-" + id).text(votes);
}





var pourEth = function ( ) {


    try {
        $.getJSON("solidity/JobOfferManager.json", function (cABI) {

            const myfunction = web3.eth.contract(cABI).at(cAddress);

            myfunction.pourMoney.sendTransaction( document.getElementById("pourEth").value , { from: myaddress, gas: 4000000 }, function (error, result) {
                if (!error) {
                    console.log(result);
                } else {
                    console.log(error);
                }
            })
        });
    } catch (err) {
        document.getElementById("xvalue").innerHTML = err;
    }

}



$(document).ready(function () {
    $("#ButtonVersamento").click(function () {
        pourEth();
    });

});


var addOffer = function ( ) {


    try {
        $.getJSON("solidity/JobOfferManager.json", function (cABI) {

            const myfunction = web3.eth.contract(cABI).at(cAddress);

            myfunction.newJob.sendTransaction( document.getElementById("datascadenza").value,
                                               document.getElementById("nome").value,
                                               document.getElementById("informazioni").value,
                                               document.getElementById("oreLavorative").value,
                                               document.getElementById("salary").value,{ from: myaddress, gas: 4000000 }, function (error, result) {
                if (!error) {
                    console.log(result);
                } else {
                    console.log(error);
                }
            })
        });
    } catch (err) {
        document.getElementById("xvalue").innerHTML = err;
    }
}

$(document).ready(function () {
    $("#buttonAddOffer").click(function () {
        addOffer();
    });

});



