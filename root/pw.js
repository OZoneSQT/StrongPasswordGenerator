"use strict";

function generatePW() {
    var base = "";
    var result = "";
    
    var latinLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    var cyrillicLetters = "БбВвГгДдЕеЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЬьЮюЯя"
    var greekLetters = "ΑαΒβΓγΔδΕεΖζΗηΘθΙιΚκΛλΜμΝνΞξΟοΠπΡρΣσςΤτΥυΦφΧχΨψΩω"
    var numbersLetters = "1234567890"
    var signsLetters = "/|()1{}[]?-_+~<>!I;:,^`.$@B%&WM*"
    var armenianLetters = "աբգդեզէըթժիլխծկհձղճմյնշոչպջռսվտրցւփքօֆուև"
    var hangulLetters = "ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㅏㅑㅓㅕㅗㅛㅜㅠㅡㅣ"
    var nordicLetters = "AaÁáBbCcDdÐðEeÉéFfGgHhIiÍíJjKkLlMmNnOoÓóPpRrSsTtUuÚúVvWwXxYyÝýZzÞþÆæÖöZzÄäØøÅå"
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
    if (arabic.checked) { base = base + arabicLetters; }
    if (latin.checked) { base = base + latinLetters; }
    if (signs.checked) { base = base + signsLetters; }
    if (greek.checked) { base = base + greekLetters; }
    if (numbers.checked) { base = base + numbersLetters; }
    if (armenian.checked) { base = base + armenianLetters; }
    if (hangul.checked) { base = base + hangulLetters; }
    if (numbers.checked) { base = base + numbersLetters; }
    if (nordic.checked) { base = base + nordicLetters; }
    if (cyrillic.checked) { base = base + cyrillicLetters; }
    if (numbers.checked) { base = base + numbersLetters; }
    if (georgian.checked) { base = base + georgianLetters; }
    if (ethiopian.checked) { base = base + ethiopianLetters; }
    if (thaana.checked) { base = base + thaanaLetters; }
    if (hanzi.checked) { base = base + hanziLetters; }
    if (numbers.checked) { base = base + numbersLetters; }
    if (signs.checked) { base = base + signsLetters; }
    if (numbers.checked) { base = base + numbersLetters; }
    if (signs.checked) { base = base + signsLetters; }
    if (numbers.checked) { base = base + numbersLetters; }
    
    
    // fill result
    for (let i = 0; i < length; i++) {
        var rand = Math.floor(Math.random() * base.length);
        result = result + base.charAt(rand);
    }
       
    // write to html
    document.getElementById("productX").innerHTML = result;
}