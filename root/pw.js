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
    var allUnicode = document.getElementById('allUnicodeChecked')
    var emoji = document.getElementById('emojiChecked')
    var symbols = document.getElementById('symbolChecked')
    var dingbats = document.getElementById('dingbatChecked')
    
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
    // Emoji / Symbols / Dingbats ranges (use per-character sampling rather than building a huge base)
    var isPrintable = function(cp) {
        if (cp >= 0x0000 && cp <= 0x001F) return false
        if (cp >= 0x007F && cp <= 0x009F) return false
        if (cp >= 0xD800 && cp <= 0xDFFF) return false
        if (cp >= 0xFDD0 && cp <= 0xFDEF) return false
        if ((cp & 0xFFFF) === 0xFFFE || (cp & 0xFFFF) === 0xFFFF) return false
        if (cp >= 0xFE00 && cp <= 0xFE0F) return false
        return true
    }

    var emojiRanges = [ [0x1F300,0x1F5FF], [0x1F600,0x1F64F], [0x1F900,0x1F9FF] ]
    var symbolRanges = [ [0x2600,0x26FF] ]
    var dingbatRanges = [ [0x2700,0x27BF] ]

    var combinedRanges = []
    if (emoji && emoji.checked) { combinedRanges = combinedRanges.concat(emojiRanges) }
    if (symbols && symbols.checked) { combinedRanges = combinedRanges.concat(symbolRanges) }
    if (dingbats && dingbats.checked) { combinedRanges = combinedRanges.concat(dingbatRanges) }

    // If we have any combined ranges, we'll sample per-character from them (mixed with base if base exists)
    var useRangeSampling = (combinedRanges.length > 0)
    
    // If All Unicode selected, generate by selecting codepoints from ranges (avoid building huge pool)
    if (allUnicode && allUnicode.checked) {
        // list of ranges (start, end) - simplified to a representative set per blocks list
        var ranges = [
            [0x0020,0x007E],
            [0x00A0,0x00FF],
            [0x0100,0x017F],
            [0x0180,0x024F],
            [0x0250,0x02AF],
            [0x02B0,0x02FF],
            [0x0300,0x036F],
            [0x0370,0x03FF],
            [0x0400,0x04FF],
            [0x0500,0x052F],
            [0x0530,0x058F],
            [0x0600,0x06FF],
            [0x0700,0x074F],
            [0x0780,0x07BF],
            [0x0900,0x097F],
            [0x0980,0x09FF],
            [0x0A00,0x0A7F],
            [0x0A80,0x0AFF],
            [0x0B00,0x0B7F],
            [0x0B80,0x0BFF],
            [0x0C00,0x0C7F],
            [0x0C80,0x0CFF],
            [0x0D00,0x0D7F],
            [0x0E00,0x0E7F],
            [0x0F00,0x0FFF],
            [0x1000,0x109F],
            [0x1100,0x11FF],
            [0x1200,0x137F],
            [0x13A0,0x13FF],
            [0x1400,0x167F],
            [0x1780,0x17FF],
            [0x1800,0x18AF],
            [0x1B00,0x1B7F],
            [0x1C00,0x1C4F],
            [0x1D00,0x1D7F],
            [0x1E00,0x1EFF],
            [0x1F00,0x1FFF],
            [0x1F600,0x1F64F],
            [0x2000,0x206F],
            [0x2100,0x214F],
            [0x2190,0x21FF],
            [0x2200,0x22FF],
            [0x2300,0x23FF],
            [0x2500,0x257F],
            [0x25A0,0x25FF],
            [0x2600,0x26FF],
            [0x2700,0x27BF],
            [0x2E80,0x2EFF],
            [0x3000,0x303F],
            [0x3040,0x309F],
            [0x30A0,0x30FF],
            [0x3130,0x318F],
            [0x3400,0x4DBF],
            [0x4E00,0x9FFF]
        ]

        function isPrintable(cp) {
            if (cp >= 0x0000 && cp <= 0x001F) return false
            if (cp >= 0x007F && cp <= 0x009F) return false
            if (cp >= 0xD800 && cp <= 0xDFFF) return false
            if (cp >= 0xFDD0 && cp <= 0xFDEF) return false
            if ((cp & 0xFFFF) === 0xFFFE || (cp & 0xFFFF) === 0xFFFF) return false
            if (cp >= 0xFE00 && cp <= 0xFE0F) return false
            return true
        }

        // pick characters per length (All-Unicode existing path)
        for (let i = 0; i < length; i++) {
            let attempts = 0
            let ch = '?'
            while (attempts < 50) {
                let r = ranges[Math.floor(Math.random() * ranges.length)]
                let cp = Math.floor(Math.random() * (r[1] - r[0] + 1)) + r[0]
                if (isPrintable(cp)) { ch = String.fromCodePoint(cp); break }
                attempts++
            }
            result += ch
        }

        // shuffle and write
        document.getElementById("productX").innerHTML = result.shuffle()
        document.getElementById("combinations").innerHTML = "Possible combinations: > 1.7976931348623157e+308"
        return
    }
      
    // If we selected emoji/symbol/dingbats ranges, perform per-character range sampling (mixed with base)
    if (useRangeSampling) {
        for (let i = 0; i < length; i++) {
            // choose between base characters and ranges; if base is empty, always choose ranges
            let pickFromBase = false
            if (base.length > 0) {
                // 50/50 split between base and ranges for mixing
                pickFromBase = (Math.random() < 0.5)
            }

            if (pickFromBase) {
                // select from base string
                let rand = Math.floor(Math.random() * base.length)
                result += base.charAt(rand)
            } else {
                // sample a codepoint from combinedRanges
                let ch = '?'
                let attempts = 0
                while (attempts < 50) {
                    let r = combinedRanges[Math.floor(Math.random() * combinedRanges.length)]
                    let cp = Math.floor(Math.random() * (r[1] - r[0] + 1)) + r[0]
                    if (isPrintable(cp)) { ch = String.fromCodePoint(cp); break }
                    attempts++
                }
                result += ch
            }
        }
    } else {
        // avoid repeating the last character when using purely base string
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

    var combinations = Math.pow(base.length, length);
    
    document.getElementById("combinations").innerHTML = ( "Possible combinations: " + combinations );
}