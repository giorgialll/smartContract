/*
THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS ECLIPSE
PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR DISTRIBUTION OF
THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE OF THIS AGREEMENT.
*/
function WriteCookie() {
    console.log("ENTRA LOGIN");
    let Web3 = require('web3');
    let url = new Web3.providers.HttpProvider('https://ropsten.infura.io/v3/8c9b9cb6f13549ffaf9bcca88ab1a99b');
    let web3 = new Web3(url);


    if( document.myform.address.value == "" ) {
        alert("Enter some value!");
        return;
    }

    if( document.myform.password.value == "" ) {
        alert("Enter some value!");
        return;
    }


    if(web3.isAddress(document.myform.address.value) == true){
        cookievalue1 = escape(document.myform.address.value) + ";";
        console.log(cookievalue1)
        cookievalue2 = escape(document.myform.password.value) + ";";
        console.log(cookievalue2)

        document.cookie = "address=" + cookievalue1 ;
        document.cookie =  "password=" + cookievalue2;
        console.log(web3.isAddress(document.myform.address.value) )
        //let url = "http://localhost:8080/User.html";
        let url = "User.html";

        window.open (url,"_self");


    }
    else{ alert("Address non valido")}



}
