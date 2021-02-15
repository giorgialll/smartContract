/*
THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS ECLIPSE
PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR DISTRIBUTION OF
THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE OF THIS AGREEMENT.
*/
let account = "";

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
