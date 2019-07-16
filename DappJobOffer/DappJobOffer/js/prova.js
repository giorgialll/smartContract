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

//2. definisco la funzione startApp

var startApp = function () {

    //quando il documento è pronto
    $(document).ready(function () {


        $("#buttonSub").click(function () {
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

        });
    });
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
                viewAddOffer(address);
            });
    });

}


var showNumberOfOffers = function (noc) {
    var contentRow = $('#numberOfcontentRow');
    contentRow.find(".numberOfworks").text(noc);

}



var setvalue = function (address) {


        try {
// contract Abi defines all the variables,constants and functions of the smart contract. replace with your own abi


            $.getJSON("solidity/prova.json", function (cABI) {

                //var contractaddress = '0xc80cae7c51f27bc25b3862d072d56fa84965f5c1';

                const myfunction = web3.eth.contract(cABI).at(address);

                myfunction.set.sendTransaction(document.getElementById("nomeofferta").value, { from: myaddress, gas: 4000000 }, function (error, result) {
                    if (!error) {
                        console.log(result);
                    } else {
                        console.log(error);
                    }
                })

                compositionRow.html(compositionTemplate.html());

            });


//contract address. please change the address to your own
//instan
//call the set function of our SimpleStorage contract

        } catch (err) {
            document.getElementById("xvalue").innerHTML = err;
        }

}


var viewAddOffer = function (cAddress) {

    $(document).ready(function () {
        $("#Button1").click(function () {
            setvalue(cAddress);
        });

    });


}











