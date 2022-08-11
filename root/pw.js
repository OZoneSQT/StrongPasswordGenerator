"use strict";

document.getElementById("lengthChecked").addEventListener("change", generatePW);
document.getElementById("latinChecked").addEventListener("change", generatePW);
document.getElementById("numbersChecked").addEventListener("change", generatePW);
document.getElementById("signsChecked").addEventListener("change", generatePW);
document.getElementById("nordicChecked").addEventListener("change", generatePW);
document.getElementById("cyrillicChecked").addEventListener("change", generatePW);
document.getElementById("greekChecked").addEventListener("change", generatePW);
document.getElementById("greekChecked").addEventListener("change", generatePW);
document.getElementById("armenianChecked").addEventListener("change", generatePW);


function generatePW() {
    var base = "";
    var result = "";
    
    var latinLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    var cyrillicLetters = "БбВвГгДдЕеЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЬьЮюЯя"
    var greekLetters = "ΑαΒβΓγΔδΕεΖζΗηΘθΙιΚκΛλΜμΝνΞξΟοΠπΡρΣσςΤτΥυΦφΧχΨψΩω"
    var numbersLetters = "123456789"
    var signsLetters = "/|()1{}[]?-_+~<>!I;:,^`.$@B%&WM*"
    var armenianLetters = "աբգդեզէըթժիլխծկհձղճմյնշոչպջռսվտրցւփքօֆուև"
    var hangulLetters = "ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㅏㅑㅓㅕㅗㅛㅜㅠㅡㅣ"
    var nordicLetters = "AaÁáBbCcDdÐðEeÉéFfGgHhIiÍíJjKkLlMmNnOoÓóPpRrSsTtUuÚúVvWwXxYyÝýZzÞþÆæÖöZzÄäØøÅå"
    var arabicLetters = "ءي و ه ن م لك ق ف غ ع ظ ط ض ص ش س ز ر ذ د خ ح ج ث ت ب ا"
    
    // input
    var length = document.getElementById('lengthChecked').value
    var latin = document.getElementById('latinChecked')
    var numbers = document.getElementById('numbersChecked')
    var signs = document.getElementById('signsChecked')
    var nordic = document.getElementById('nordicChecked')
    var cyrillic = document.getElementById('cyrillicChecked')
    var greek = document.getElementById('greekChecked')
    var armenian = document.getElementById('armenianChecked')
    var hangul = document.getElementById('hangulChecked')
    var arabic = document.getElementById('arabicChecked')
    
    
    // build source string
    if (latin.checked) { base = base + latinLetters; }
    if (cyrillic.checked) { base = base + cyrillicLetters; }
    if (greek.checked) { base = base + greekLetters; }
    if (numbers.checked) { base = base + numbersLetters; }
    if (signs.checked) { base = base + signs; }
    if (armenian.checked) { base = base + armenianLetters; }
    if (hangul.checked) { base = base + hangulLetters; }
    if (nordic.checked) { base = base + nordicLetters; }
    if (arabic.checked) { base = base + arabicLetters; }
    
    
    // fill result
    for (let i = 0; i < length; i++) {
        var rand = Math.floor(Math.random() * base.length);
        result = result + base.charAt(rand);
    }
       
    // write to html
    document.getElementById("productX").innerHTML = result;
}