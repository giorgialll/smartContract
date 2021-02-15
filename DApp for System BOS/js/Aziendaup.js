/*

Autore: Giorgia Lallai

Università degli studi di Cagliari

Concesso in licenza a norma dell'EUPL

*/

let account = "";
let pk="";

let viewAddress = async function (){
    document.getElementById("addressAcc").innerText = document.getElementById("addressAcc").innerText +" "+ account +"";
}

async function ReadCookie() {
    let array =[];
    var allcookies = document.cookie;
    // Get all the cookies pairs in an array
    cookiearray = allcookies.split(';');

    // Now take key value pair out of this array
    for(var i=0; i<cookiearray.length; i++) {
        array[i] = cookiearray[i].split('=')[1];

    }
    account = array[0];
    await viewAddress();


}
ReadCookie();



function deleteAllCookies() {
    var cookies = document.cookie.split(";");
    console.log("DELETE COOCKIES")

    for (var i = 0; i < cookies.length; i++) {
        var cookie = cookies[i];
        var eqPos = cookie.indexOf("=");
        var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
        document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT";
    }
}

