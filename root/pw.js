"use strict";

String.prototype.replaceAt = function(index, replacement) {
	if (index >= this.length) {
		return this.valueOf();
	}
	return this.substring(0, index) + replacement + this.substring(index + 1);
}

// Modified Fisher-Yates Shuffle algorithm
String.prototype.shuffle = function () {
    var a = this.split(""),
        n = a.length;

    for(var i = n - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
    }
    return a.join("");
}

function generatePW() {
    var base = "";
    var result = "";
    
    var latinLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    var cyrillicLetters = "БбВвГгДдЕеЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЬьЮюЯя"
    var greekLetters = "ΑαΒβΓγΔδΕεΖζΗηΘθΙιΚκΛλΜμΝνΞξΟοΠπΡρΣσςΤτΥυΦφΧχΨψΩω"
    var numbersLetters = "1234567890"
    var signsLetters = "/|()1{}[]?-_+~!I;:,^.$@%&*"
    var armenianLetters = "աբգդեզէըթժիլխծկհձղճմյնշոչպջռսվտրցւփքօֆուև"
    var hangulLetters = "ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㅏㅑㅓㅕㅗㅛㅜㅠㅡㅣ"
    var nordicLetters = "ÁáÐðÉéÍíÓóÚúÝýÞþÆæÖöZzÄäØøÅå"
    var arabicLetters = "ءي و ه ن م لك ق ف غ ع ظ ط ض ص ش س ز ر ذ د خ ح ج ث ت ب ا"
    var georgianLetters = "აბგდევზთიკლმნოპჟრსტუფქღყშჩცძწჭხჯჰ"
    var ethiopianLetters = "ሀለሐመሠረሰቀበተኀነአከወዐዘየደገጠጸፀፈጰፐ"
    var thaanaLetters = "ހށނރބޅކއވމފދތލގސޑޒޓޔޕޖޗޘޙޚޛޜޝޞޟޠޡޢޣޤޥަ	ީ	ު	ޫ	ެ	ޭ	ޮ	ޯޱ"
    var hanziLetters = "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖ ゙ ゛゜ゝゞゟ"
    
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
    var georgian = document.getElementById('georgianChecked')
    var ethiopian = document.getElementById('ethiopianChecked')
    var thaana = document.getElementById('thaanaChecked')
    var hanzi = document.getElementById('hanziChecked')
    
    // build source string
    if (latin.checked) { base = base + latinLetters; }
    if (cyrillic.checked) { base = base + cyrillicLetters; }
    if (greek.checked) { base = base + greekLetters; }
    if (numbers.checked) { base = base + numbersLetters + numbersLetters + numbersLetters; }
    if (signs.checked) { base = base + signsLetters + signsLetters; }
    if (armenian.checked) { base = base + armenianLetters; }
    if (hangul.checked) { base = base + hangulLetters; }
    if (nordic.checked) { base = base + nordicLetters; }
    if (arabic.checked) { base = base + arabicLetters; }
    if (georgian.checked) { base = base + georgianLetters; }
    if (ethiopian.checked) { base = base + ethiopianLetters; }
    if (thaana.checked) { base = base + thaanaLetters; }
    if (hanzi.checked) { base = base + hanziLetters; }
      
    // avoid repeating the last character
    var last;

    for (let i = 0; i < length; i++) {
        var rand = Math.floor(Math.random() * base.length);

        if ( last == base.charAt(rand) ) {
            rand = Math.floor(Math.random() * base.length);
        }

        if ( last == base.charAt(rand).toLowerCase() ) {
            rand = Math.floor(Math.random() * base.length);
        }
        
        if ( last == base.charAt(rand).toUpperCase() ) {
            rand = Math.floor(Math.random() * base.length);
        }
    
        last = base.charAt(rand);
        // can be equal to the last character, but the probability is low
        result = result + base.charAt(rand);
    } 
    
    // ensure that sequenses are included
    if (cyrillic.checked) { result.replaceAt((Math.random() * result.length), cyrillicLetters.charAt(Math.random() * cyrillicLetters.length)); }
    if (greek.checked) { result.replaceAt((Math.random() * result.length), greekLetters.charAt(Math.random() * greekLetters.length)); }
    if (armenian.checked) { result.replaceAt((Math.random() * result.length), armenianLetters.charAt(Math.random() * armenianLetters.length)); }
    if (hangul.checked) { result.replaceAt((Math.random() * result.length), hangulLetters.charAt(Math.random() * hangulLetters.length)); }
    if (nordic.checked) { result.replaceAt((Math.random() * result.length), nordicLetters.charAt(Math.random() * nordicLetters.length)); }
    if (arabic.checked) { result.replaceAt((Math.random() * result.length), arabicLetters.charAt(Math.random() * arabicLetters.length)); }   
    if (georgian.checked) { result.replaceAt((Math.random() * result.length), georgianLetters.charAt(Math.random() * georgianLetters.length)); }
    if (ethiopian.checked) { result.replaceAt((Math.random() * result.length), ethiopianLetters.charAt(Math.random() * ethiopianLetters.length)); }
    if (thaana.checked) { result.replaceAt((Math.random() * result.length), thaanaLetters.charAt(Math.random() * thaanaLetters.length)); }
    if (hanzi.checked) { result.replaceAt((Math.random() * result.length), hanziLetters.charAt(Math.random() * hanziLetters.length)); }
    if (latin.checked) {
        result.replaceAt((Math.random() * result.length), latinLetters.charAt(Math.random() * latinLetters.length).toLowerCase());
        result.replaceAt((Math.random() * result.length), latinLetters.charAt(Math.random() * latinLetters.length).toUpperCase());
    }
    if (numbers.checked) {
        result.replaceAt((Math.random() * result.length), numbersLetters.charAt(Math.random() * numbersLetters.length));
        result.replaceAt((Math.random() * result.length), numbersLetters.charAt(Math.random() * numbersLetters.length));
        result.replaceAt((Math.random() * result.length), numbersLetters.charAt(Math.random() * numbersLetters.length));
    }
    if (signs.checked) {
        result.replaceAt((Math.random() * result.length), signsLetters.charAt(Math.random() * signsLetters.length));
        result.replaceAt((Math.random() * result.length), signsLetters.charAt(Math.random() * signsLetters.length));
    }

    // check if selectet sequenses is representated
    if (cyrillic.checked) { 
        var check = 0; 
        for (let i = 0; i > result.length; i++) {
            if (cyrillicLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        } 
    }
    if (greek.checked) {  
        var check = 0;       
        for (let i = 0; i > result.length; i++) {
            if (greekLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        } 
    }
    if (armenian.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (armenianLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        }
    }
    if (hangul.checked) { 
        var check = 0;        
        for (let i = 0; i > result.length; i++) {
            if (hangulLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        }
    }
    if (nordic.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (nordicLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        }
    }
    if (arabic.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (arabicLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        }
    }
    if (georgian.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (georgianLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        } 
    }
    if (ethiopian.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (ethiopianLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        } 
    }
    if (thaana.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (thaanaLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        } 
    }
    if (hanzi.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (hanziLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        }
    }
    if (latin.checked) { 
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (latinLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        } 
    }       
    if (numbers.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (numbersLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        }
    }
    if (signs.checked) {  
        var check = 0;
        for (let i = 0; i > result.length; i++) {
            if (signsLetter.includes.includes(result.charAt(i))) {
                i = result.length + 1;
                check++;
            } 
            if (check == 0) { generatePW(); }
        }
    }
    
    // is upper
    var upperCheck = 0;
    for (let i = 0; i > result.length; i++) {
        if (result.charAt(i) == result.charAt(i).toUpperCase()) {
            i = result.length + 1;
            upperCheck++;
        } 
       if (upperCheck == 0) { generatePW(); }
    }
    
    // is upper
    var lowerCheck = 0;
    for (let i = 0; i > result.length; i++) {
        if (result.charAt(i) == result.charAt(i).toLowerCase()) {
            i = result.length + 1;
            lowerCheck++;
        } 
        if (lowerCheck == 0) { generatePW(); }
    }    

    // check length
    if (result.length != length) { generatePW(); }    
   
    // write to html
    document.getElementById("productX").innerHTML = result.shuffle(); 
}