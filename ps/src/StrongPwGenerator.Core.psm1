
$script:RandomNumberGenerator = [System.Security.Cryptography.RandomNumberGenerator]::Create()

$module = $MyInvocation.MyCommand.Module
if ($module) {
    $module.OnRemove = {
        if ($script:RandomNumberGenerator) {
            $script:RandomNumberGenerator.Dispose()
            $script:RandomNumberGenerator = $null
        }
    }
}

function Get-CryptoRandomInt {
    param([int]$MaxExclusive)

    if ($MaxExclusive -le 0) {
        throw "MaxExclusive must be greater than 0."
    }

    $buffer = New-Object byte[] 4
    $maxValue = [uint32]$MaxExclusive
    $upperBound = [uint32]::MaxValue - ([uint32]::MaxValue % $maxValue)

    do {
        $script:RandomNumberGenerator.GetBytes($buffer)
        $value = [System.BitConverter]::ToUInt32($buffer, 0)
    } while ($value -ge $upperBound)

    return [int]($value % $maxValue)
}

function Get-CryptoRandomInRange {
    param(
        [int]$MinInclusive,
        [int]$MaxExclusive
    )

    if ($MaxExclusive -le $MinInclusive) {
        throw "MaxExclusive must be greater than MinInclusive."
    }

    return $MinInclusive + (Get-CryptoRandomInt -MaxExclusive ($MaxExclusive - $MinInclusive))
}

function Get-CryptoRandomChar {
    param([string]$CharSet)

    if ([string]::IsNullOrEmpty($CharSet)) {
        throw "Character set must not be empty."
    }

    $index = Get-CryptoRandomInt -MaxExclusive $CharSet.Length
    return $CharSet[$index]
}

function Get-ShuffledString {
    param([string]$InputString)

    $chars = $InputString.ToCharArray()
    $n = $chars.Length

    for ($i = $n - 1; $i -gt 0; $i--) {
        $j = Get-CryptoRandomInt -MaxExclusive ($i + 1)
        $temp = $chars[$i]
        $chars[$i] = $chars[$j]
        $chars[$j] = $temp
    }

    return -join $chars
}

function Test-CharInString {
    param(
        [string]$TestString,
        [string]$CharSet
    )

    foreach ($char in $TestString.ToCharArray()) {
        if ($CharSet.Contains($char)) {
            return $true
        }
    }
    return $false
}

function New-StrongPassword {
    param(
        [int]$Length = 32,
        [bool]$IncludeLatin = $true,
        [bool]$IncludeNumbers = $true,
        [bool]$IncludeSigns = $true,
        [bool]$IncludeNordic = $false,
        [bool]$IncludeCyrillic = $false,
        [bool]$IncludeGreek = $false,
        [bool]$IncludeArmenian = $false,
        [bool]$IncludeHangul = $false,
        [bool]$IncludeArabic = $false,
        [bool]$IncludeGeorgian = $false,
        [bool]$IncludeEthiopian = $false,
        [bool]$IncludeThaana = $false,
        [bool]$IncludeHanzi = $false,
            [bool]$IncludeCustom = $false,
            [string]$CustomCharacters = '',
            [bool]$IncludeAllUnicode = $false,
            [bool]$IncludeEmoji = $false,
            [bool]$IncludeSymbols = $false,
            [bool]$IncludeDingbats = $false
    )

    # Character sets
    $latinLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    $cyrillicLetters = [char[]]@(0x0411,0x0431,0x0412,0x0432,0x0413,0x0433,0x0414,0x0434,0x0415,0x0435,0x0416,0x0436,0x0417,0x0437,0x0418,0x0438,0x0419,0x0439,0x041A,0x043A,0x041B,0x043B,0x041C,0x043C,0x041D,0x043D,0x041E,0x043E,0x041F,0x043F,0x0420,0x0440,0x0421,0x0441,0x0422,0x0442,0x0423,0x0443,0x0424,0x0444,0x0425,0x0445,0x0426,0x0446,0x0427,0x0447,0x0428,0x0448,0x0429,0x0449,0x042C,0x044C,0x042E,0x044E,0x042F,0x044F) -join ''
    $greekLetters = [char[]]@(0x0391,0x03B1,0x0392,0x03B2,0x0393,0x03B3,0x0394,0x03B4,0x0395,0x03B5,0x0396,0x03B6,0x0397,0x03B7,0x0398,0x03B8,0x0399,0x03B9,0x039A,0x03BA,0x039B,0x03BB,0x039C,0x03BC,0x039D,0x03BD,0x039E,0x03BE,0x039F,0x03BF,0x03A0,0x03C0,0x03A1,0x03C1,0x03A3,0x03C3,0x03C2,0x03A4,0x03C4,0x03A5,0x03C5,0x03A6,0x03C6,0x03A7,0x03C7,0x03A8,0x03C8,0x03A9,0x03C9) -join ''
    $numbersLetters = "1234567890"
    $signsLetters = "/|()1{}[]?-_+~!I;:,^.`$@%&*"
    $armenianLetters = [char[]]@(0x0561,0x0562,0x0563,0x0564,0x0565,0x0566,0x0567,0x0568,0x0569,0x056A,0x056B,0x056C,0x056D,0x056E,0x056F,0x0570,0x0571,0x0572,0x0573,0x0574,0x0575,0x0576,0x0577,0x0578,0x0579,0x057A,0x057B,0x057C,0x057D,0x057E,0x057F,0x0580,0x0581,0x0582,0x0583,0x0584,0x0585,0x0586,0x0578,0x0582,0x0587) -join ''
    $hangulLetters = [char[]]@(0x3131,0x3134,0x3137,0x3139,0x3141,0x3142,0x3145,0x3147,0x3148,0x314A,0x314B,0x314C,0x314D,0x314E,0x314F,0x3151,0x3153,0x3155,0x3157,0x315B,0x315C,0x3160,0x3161,0x3163) -join ''
    $nordicLetters = [char[]]@(0x00C1,0x00E1,0x00D0,0x00F0,0x00C9,0x00E9,0x00CD,0x00ED,0x00D3,0x00F3,0x00DA,0x00FA,0x00DD,0x00FD,0x00DE,0x00FE,0x00C6,0x00E6,0x00D6,0x00F6,0x005A,0x007A,0x00C4,0x00E4,0x00D8,0x00F8,0x00C5,0x00E5) -join ''
    $arabicLetters = [char[]]@(0x0621,0x064A,0x0020,0x0648,0x0020,0x0647,0x0020,0x0646,0x0020,0x0645,0x0020,0x0644,0x0643,0x0020,0x0642,0x0020,0x0641,0x0020,0x063A,0x0020,0x0639,0x0020,0x0638,0x0020,0x0637,0x0020,0x0636,0x0020,0x0635,0x0020,0x0634,0x0020,0x0633,0x0020,0x0632,0x0020,0x0631,0x0020,0x0630,0x0020,0x062F,0x0020,0x062E,0x0020,0x062D,0x0020,0x062C,0x0020,0x062B,0x0020,0x062A,0x0020,0x0628,0x0020,0x0627) -join ''
    $georgianLetters = [char[]]@(0x10D0,0x10D1,0x10D2,0x10D3,0x10D4,0x10D5,0x10D6,0x10D7,0x10D8,0x10D9,0x10DA,0x10DB,0x10DC,0x10DD,0x10DE,0x10DF,0x10E0,0x10E1,0x10E2,0x10E3,0x10E4,0x10E5,0x10E6,0x10E7,0x10E8,0x10E9,0x10EA,0x10EB,0x10EC,0x10ED,0x10EE,0x10EF,0x10F0) -join ''
    $ethiopianLetters = [char[]]@(0x1200,0x1208,0x1210,0x1218,0x1220,0x1228,0x1230,0x1240,0x1260,0x1270,0x1280,0x1290,0x12A0,0x12A8,0x12C8,0x12D0,0x12E8,0x12F0,0x1308,0x1320,0x1338,0x1340,0x1348,0x1368,0x1370) -join ''
    $thaanaLetters = [char[]]@(0x0780,0x0781,0x0782,0x0783,0x0784,0x0785,0x0786,0x0787,0x0788,0x0789,0x078A,0x078B,0x078C,0x078D,0x078E,0x078F,0x0790,0x0791,0x0792,0x0793,0x0794,0x0795,0x0796,0x0797,0x0798,0x0799,0x079A,0x079B,0x079C,0x079D,0x079E,0x079F,0x07A0,0x07A1,0x07A2,0x07A3,0x07A4,0x07A5,0x07A6,0x0020,0x07A9,0x0020,0x07AA,0x0020,0x07AB,0x0020,0x07AC,0x0020,0x07AD,0x0020,0x07AE,0x0020,0x07AF,0x07B1) -join ''
    $hanziLetters = [char[]]@(0x3041,0x3042,0x3043,0x3044,0x3045,0x3046,0x3047,0x3048,0x3049,0x304A,0x304B,0x304C,0x304D,0x304E,0x304F,0x3050,0x3051,0x3052,0x3053,0x3054,0x3055,0x3056,0x3057,0x3058,0x3059,0x305A,0x305B,0x305C,0x305D,0x305E,0x305F,0x3060,0x3061,0x3062,0x3063,0x3064,0x3065,0x3066,0x3067,0x3068,0x3069,0x306A,0x306B,0x306C,0x306D,0x306E,0x306F,0x3070,0x3071,0x3072,0x3073,0x3074,0x3075,0x3076,0x3077,0x3078,0x3079,0x307A,0x307B,0x307C,0x307D,0x307E,0x307F,0x3080,0x3081,0x3082,0x3083,0x3084,0x3085,0x3086,0x3087,0x3088,0x3089,0x308A,0x308B,0x308C,0x308D,0x308E,0x308F,0x3090,0x3091,0x3092,0x3093,0x3094,0x3095,0x3096,0x0020,0x3099,0x0020,0x309B,0x309C,0x309D,0x309E,0x309F) -join ''

    # Helper: build string for ranges (use ConvertFromUtf32 to handle >0xFFFF)
    function Get-StringFromRanges {
        param(
            [array]$Ranges # array of @{Start=int; End=int}
        )
        $sb = New-Object System.Text.StringBuilder
        foreach ($r in $Ranges) {
            for ($cp = $r.Start; $cp -le $r.End; $cp++) {
                try {
                    [void]$sb.Append([System.Char]::ConvertFromUtf32($cp))
                } catch { }
            }
        }
        return $sb.ToString()
    }

    # Unicode ranges for optional sets
    $emojiRanges = @(
        @{ Start = 0x1F300; End = 0x1F5FF } , # Misc Symbols and Pictographs
        @{ Start = 0x1F600; End = 0x1F64F } , # Emoticons
        @{ Start = 0x1F900; End = 0x1F9FF }   # Supplemental Symbols and Pictographs
    )
    $symbolRanges = @(
        @{ Start = 0x2600; End = 0x26FF } , # Misc Symbols
        @{ Start = 0x2700; End = 0x27BF }   # Dingbats block overlaps but keep separate option
    )
    $dingbatRanges = @(
        @{ Start = 0x2700; End = 0x27BF }
    )

    if ($Length -lt 1) {
        throw "Length must be greater than 0."
    }

    # Build base string (unless we're using range generation for full Unicode)
    $base = ""
    if ($IncludeLatin) { $base += $latinLetters }
    if ($IncludeCyrillic) { $base += $cyrillicLetters }
    if ($IncludeGreek) { $base += $greekLetters }
    if ($IncludeNumbers) { $base += $numbersLetters * 3 }
    if ($IncludeSigns) { $base += $signsLetters * 2 }
    if ($IncludeArmenian) { $base += $armenianLetters }
    if ($IncludeHangul) { $base += $hangulLetters }
    if ($IncludeNordic) { $base += $nordicLetters }
    if ($IncludeArabic) { $base += $arabicLetters }
    if ($IncludeGeorgian) { $base += $georgianLetters }
    if ($IncludeEthiopian) { $base += $ethiopianLetters }
    if ($IncludeThaana) { $base += $thaanaLetters }
    if ($IncludeHanzi) { $base += $hanziLetters }
    if ($IncludeCustom) {
        if ([string]::IsNullOrWhiteSpace($CustomCharacters)) {
            throw "CustomCharacters must contain at least one character when IncludeCustom is enabled."
        }
        $base += $CustomCharacters
    }
    # Option: include the complete set of Unicode blocks as requested
    $useRangeGeneration = $false
    if ($IncludeAllUnicode) {
        $useRangeGeneration = $true
        # Complete Unicode ranges covering commonly used blocks (start..end inclusive)
        $completeRanges = @(
            @{ Start = 0x0000; End = 0x007F }, # Basic Latin
            @{ Start = 0x0080; End = 0x00FF }, # Latin-1 Supplement
            @{ Start = 0x0100; End = 0x017F }, # Latin Extended-A
            @{ Start = 0x0180; End = 0x024F }, # Latin Extended-B
            @{ Start = 0x0250; End = 0x02AF }, # IPA Extensions
            @{ Start = 0x02B0; End = 0x02FF }, # Spacing Modifier Letters
            @{ Start = 0x0300; End = 0x036F }, # Combining Diacritical Marks
            @{ Start = 0x0370; End = 0x03FF }, # Greek and Coptic
            @{ Start = 0x0400; End = 0x04FF }, # Cyrillic
            @{ Start = 0x0500; End = 0x052F }, # Cyrillic Supplement
            @{ Start = 0x0530; End = 0x058F }, # Armenian
            @{ Start = 0x0590; End = 0x05FF }, # Hebrew
            @{ Start = 0x0600; End = 0x06FF }, # Arabic
            @{ Start = 0x0700; End = 0x074F }, # Syriac
            @{ Start = 0x0750; End = 0x077F }, # Arabic Supplement
            @{ Start = 0x0780; End = 0x07BF }, # Thaana
            @{ Start = 0x07C0; End = 0x07FF }, # NKo
            @{ Start = 0x0800; End = 0x083F }, # Samaritan
            @{ Start = 0x0840; End = 0x085F }, # Mandaic
            @{ Start = 0x0860; End = 0x086F }, # Syriac Supplement
            @{ Start = 0x0870; End = 0x089F }, # Arabic Extended-B
            @{ Start = 0x08A0; End = 0x08FF }, # Arabic Extended-A
            @{ Start = 0x0900; End = 0x097F }, # Devanagari
            @{ Start = 0x0980; End = 0x09FF }, # Bengali
            @{ Start = 0x0A00; End = 0x0A7F }, # Gurmukhi
            @{ Start = 0x0A80; End = 0x0AFF }, # Gujarati
            @{ Start = 0x0B00; End = 0x0B7F }, # Oriya
            @{ Start = 0x0B80; End = 0x0BFF }, # Tamil
            @{ Start = 0x0C00; End = 0x0C7F }, # Telugu
            @{ Start = 0x0C80; End = 0x0CFF }, # Kannada
            @{ Start = 0x0D00; End = 0x0D7F }, # Malayalam
            @{ Start = 0x0D80; End = 0x0DFF }, # Sinhala
            @{ Start = 0x0E00; End = 0x0E7F }, # Thai
            @{ Start = 0x0E80; End = 0x0EFF }, # Lao
            @{ Start = 0x0F00; End = 0x0FFF }, # Tibetan
            @{ Start = 0x1000; End = 0x109F }, # Myanmar
            @{ Start = 0x10A0; End = 0x10FF }, # Georgian
            @{ Start = 0x1100; End = 0x11FF }, # Hangul Jamo
            @{ Start = 0x1200; End = 0x137F }, # Ethiopic
            @{ Start = 0x1380; End = 0x139F }, # Ethiopic Supplement / Cherokee overlap
            @{ Start = 0x13A0; End = 0x13FF }, # Cherokee
            @{ Start = 0x1400; End = 0x167F }, # Unified Canadian Aboriginal Syllabics
            @{ Start = 0x1680; End = 0x169F }, # Ogham
            @{ Start = 0x16A0; End = 0x16FF }, # Runic
            @{ Start = 0x1700; End = 0x171F }, # Tagalog
            @{ Start = 0x1720; End = 0x173F }, # Hanunoo
            @{ Start = 0x1740; End = 0x175F }, # Buhid
            @{ Start = 0x1760; End = 0x177F }, # Tagbanwa
            @{ Start = 0x1780; End = 0x17FF }, # Khmer
            @{ Start = 0x1800; End = 0x18AF }, # Mongolian
            @{ Start = 0x18B0; End = 0x18FF }, # Unified Canadian Aboriginal Syllabics Extended
            @{ Start = 0x1900; End = 0x194F }, # Limbu
            @{ Start = 0x1950; End = 0x197F }, # Tai Le
            @{ Start = 0x1980; End = 0x19DF }, # New Tai Lue
            @{ Start = 0x19E0; End = 0x19FF }, # Khmer Symbols
            @{ Start = 0x1A00; End = 0x1A1F }, # Buginese
            @{ Start = 0x1A20; End = 0x1AAF }, # Tai Tham
            @{ Start = 0x1AB0; End = 0x1AFF }, # Combining Diacritical Marks Extended
            @{ Start = 0x1B00; End = 0x1B7F }, # Balinese
            @{ Start = 0x1B80; End = 0x1BBF }, # Sundanese
            @{ Start = 0x1BC0; End = 0x1BFF }, # Batak
            @{ Start = 0x1C00; End = 0x1C4F }, # Lepcha
            @{ Start = 0x1C50; End = 0x1C7F }, # Ol Chiki
            @{ Start = 0x1C80; End = 0x1C8F }, # Cyrillic Extended-C
            @{ Start = 0x1C90; End = 0x1CBF }, # Georgian Extended
            @{ Start = 0x1CC0; End = 0x1CCF }, # Sundanese Supplement
            @{ Start = 0x1CD0; End = 0x1CFF }, # Vedic Extensions
            @{ Start = 0x1D00; End = 0x1D7F }, # Phonetic Extensions
            @{ Start = 0x1D80; End = 0x1DBF }, # Phonetic Extensions Supplement
            @{ Start = 0x1DC0; End = 0x1DFF }, # Combining Diacritical Marks Supplement
            @{ Start = 0x1E00; End = 0x1EFF }, # Latin Extended Additional
            @{ Start = 0x1F00; End = 0x1FFF }, # Greek Extended + General Punctuation
            @{ Start = 0x1F300; End = 0x1F5FF }, # Misc Symbols and Pictographs (emoji block)
            @{ Start = 0x1F600; End = 0x1F64F }, # Emoticons (emoji)
            @{ Start = 0x1F900; End = 0x1F9FF }, # Supplemental Symbols and Pictographs (emoji)
            @{ Start = 0x2000; End = 0x206F }, # General Punctuation
            @{ Start = 0x2070; End = 0x209F }, # Superscripts and Subscripts
            @{ Start = 0x20A0; End = 0x20CF }, # Currency Symbols
            @{ Start = 0x20D0; End = 0x20FF }, # Combining Diacritical Marks for Symbols
            @{ Start = 0x2100; End = 0x214F }, # Letterlike Symbols
            @{ Start = 0x2150; End = 0x218F }, # Number Forms
            @{ Start = 0x2190; End = 0x21FF }, # Arrows
            @{ Start = 0x2200; End = 0x22FF }, # Mathematical Operators
            @{ Start = 0x2300; End = 0x23FF }, # Misc Technical
            @{ Start = 0x2400; End = 0x243F }, # Control Pictures
            @{ Start = 0x2440; End = 0x245F }, # OCR
            @{ Start = 0x2460; End = 0x24FF }, # Enclosed Alphanumerics
            @{ Start = 0x2500; End = 0x257F }, # Box Drawing
            @{ Start = 0x2580; End = 0x259F }, # Block Elements
            @{ Start = 0x25A0; End = 0x25FF }, # Geometric Shapes
            @{ Start = 0x2600; End = 0x26FF }, # Misc Symbols
            @{ Start = 0x2700; End = 0x27BF }, # Dingbats
            @{ Start = 0x27C0; End = 0x27EF }, # Misc Math-A
            @{ Start = 0x27F0; End = 0x27FF }, # Supplemental Arrows-A
            @{ Start = 0x2800; End = 0x28FF }, # Braille Patterns
            @{ Start = 0x2900; End = 0x297F }, # Supplemental Arrows-B
            @{ Start = 0x2980; End = 0x29FF }, # Misc Math-B
            @{ Start = 0x2A00; End = 0x2AFF }, # Supplemental Math Operators
            @{ Start = 0x2B00; End = 0x2BFF }, # Misc Symbols and Arrows
            @{ Start = 0x2C00; End = 0x2C5F }, # Glagolitic
            @{ Start = 0x2C60; End = 0x2C7F }, # Latin Extended-C
            @{ Start = 0x2C80; End = 0x2CFF }, # Coptic
            @{ Start = 0x2D00; End = 0x2D2F }, # Georgian Supplement
            @{ Start = 0x2D30; End = 0x2D7F }, # Tifinagh
            @{ Start = 0x2D80; End = 0x2DDF }, # Ethiopic Extended
            @{ Start = 0x2DE0; End = 0x2DFF }, # Cyrillic Extended-A
            @{ Start = 0x2E00; End = 0x2E7F }, # Supplemental Punctuation
            @{ Start = 0x2E80; End = 0x2EFF }, # CJK Radicals Supplement
            @{ Start = 0x2F00; End = 0x2FDF }, # Kangxi Radicals
            @{ Start = 0x3000; End = 0x303F }, # CJK Symbols and Punctuation
            @{ Start = 0x3040; End = 0x309F }, # Hiragana
            @{ Start = 0x30A0; End = 0x30FF }, # Katakana
            @{ Start = 0x3100; End = 0x312F }, # Bopomofo
            @{ Start = 0x3130; End = 0x318F }, # Hangul Compatibility Jamo
            @{ Start = 0x3190; End = 0x319F }, # Kanbun
            @{ Start = 0x31A0; End = 0x31BF }, # Bopomofo Extended
            @{ Start = 0x31C0; End = 0x31EF }, # CJK Strokes
            @{ Start = 0x31F0; End = 0x31FF }, # Katakana Phonetic Extensions
            @{ Start = 0x3200; End = 0x32FF }, # Enclosed CJK Letters and Months
            @{ Start = 0x3300; End = 0x33FF }, # CJK Compatibility
            @{ Start = 0x3400; End = 0x4DBF }, # CJK Unified Ideographs Extension A
            @{ Start = 0x4DC0; End = 0x4DFF }, # Yijing Hexagram Symbols
            @{ Start = 0x4E00; End = 0x9FFF }, # CJK Unified Ideographs
            @{ Start = 0xA000; End = 0xA48F }, # Yi Syllables
            @{ Start = 0xA490; End = 0xA4CF }, # Yi Radicals
            @{ Start = 0xA4D0; End = 0xA4FF }, # Lisu
            @{ Start = 0xA500; End = 0xA63F }, # Vai
            @{ Start = 0xA640; End = 0xA69F }, # Cyrillic Extended-B
            @{ Start = 0xA6A0; End = 0xA6FF }, # Bamum
            @{ Start = 0xA700; End = 0xA71F }, # Modifier Tone Letters
            @{ Start = 0xA720; End = 0xA7FF }, # Latin Extended-D
            @{ Start = 0xA800; End = 0xA82F }, # Syloti Nagri
            @{ Start = 0xA830; End = 0xA83F }, # Common Indic Number Forms
            @{ Start = 0xA840; End = 0xA87F }, # Phags-pa
            @{ Start = 0xA880; End = 0xA8DF }, # Saurashtra
            @{ Start = 0xA8E0; End = 0xA8FF }, # Devanagari Extended
            @{ Start = 0xA900; End = 0xA92F }, # Kayah Li
            @{ Start = 0xA930; End = 0xA95F }, # Rejang
            @{ Start = 0xA960; End = 0xA97F }, # Hangul Jamo Extended-A
            @{ Start = 0xA980; End = 0xA9DF }, # Javanese
            @{ Start = 0xA9E0; End = 0xA9FF }, # Myanmar Extended-B
            @{ Start = 0xAA00; End = 0xAA5F }, # Cham
            @{ Start = 0xAA60; End = 0xAA7F }, # Myanmar Extended-A
            @{ Start = 0xAA80; End = 0xAADF }, # Tai Viet
            @{ Start = 0xAAE0; End = 0xAAFF }, # Meetei Mayek Extensions
            @{ Start = 0xAB00; End = 0xAB2F }, # Ethiopic Extended-A
            @{ Start = 0xAB30; End = 0xAB6F }, # Latin Extended-E
            @{ Start = 0xAB70; End = 0xABBF }, # Cherokee Supplement
            @{ Start = 0xABC0; End = 0xABFF }, # Meetei Mayek
            @{ Start = 0xAC00; End = 0xD7AF }, # Hangul Syllables
            @{ Start = 0xD7B0; End = 0xD7FF }, # Hangul Jamo Extended-B
            @{ Start = 0xD800; End = 0xDB7F }, # High Surrogates
            @{ Start = 0xDB80; End = 0xDBFF }, # High Private Use Surrogates
            @{ Start = 0xDC00; End = 0xDFFF }, # Low Surrogates
            @{ Start = 0xE000; End = 0xF8FF }, # Private Use Area
            @{ Start = 0xF900; End = 0xFAFF }, # CJK Compatibility Ideographs
            @{ Start = 0xFB00; End = 0xFB4F }, # Alphabetic Presentation Forms
            @{ Start = 0xFB50; End = 0xFDFF }, # Arabic Presentation Forms-A
            @{ Start = 0xFE00; End = 0xFE0F }, # Variation Selectors
            @{ Start = 0xFE10; End = 0xFE1F }, # Vertical Forms
            @{ Start = 0xFE20; End = 0xFE2F }, # Combining Half Marks
            @{ Start = 0xFE30; End = 0xFE4F }, # CJK Compatibility Forms
            @{ Start = 0xFE50; End = 0xFE6F }, # Small Form Variants
            @{ Start = 0xFE70; End = 0xFEFF }, # Arabic Presentation Forms-B
            @{ Start = 0xFF00; End = 0xFFEF }, # Halfwidth and Fullwidth Forms
            @{ Start = 0xFFF0; End = 0xFFFF }  # Specials
        )

        # do not build the full $base string for performance; we'll select codepoints from ranges at generation time
    }
    if ($IncludeEmoji) { $base += (Get-StringFromRanges -Ranges $emojiRanges) }
    if ($IncludeSymbols) { $base += (Get-StringFromRanges -Ranges $symbolRanges) }
    if ($IncludeDingbats) { $base += (Get-StringFromRanges -Ranges $dingbatRanges) }

    # If IncludeAllUnicode is enabled we will use range-based generation instead of a single large base string

    if (-not $useRangeGeneration -and $base.Length -eq 0) {
        return @{
            Password    = "Error: Please select at least one character set"
            Combinations = 0
        }
    }

    # Helper: determine if a codepoint is printable/allowed
    function Is-PrintableCodePoint {
        param([int]$cp)
        # Exclude C0 and C1 controls
        if ($cp -ge 0x0000 -and $cp -le 0x001F) { return $false }
        if ($cp -ge 0x007F -and $cp -le 0x009F) { return $false }
        # Exclude surrogates
        if ($cp -ge 0xD800 -and $cp -le 0xDFFF) { return $false }
        # Exclude non-characters in FDD0..FDEF
        if ($cp -ge 0xFDD0 -and $cp -le 0xFDEF) { return $false }
        # Exclude variation selectors (not printable)
        if ($cp -ge 0xFE00 -and $cp -le 0xFE0F) { return $false }
        # Exclude characters where low 16 bits are 0xFFFE/0xFFFF (non-characters at end of plane)
        if (($cp -band 0xFFFF) -eq 0xFFFE -or ($cp -band 0xFFFF) -eq 0xFFFF) { return $false }
        return $true
    }

    # Generate password
    $result = ""
    $last = ""

    for ($i = 0; $i -lt $Length; $i++) {
        if ($useRangeGeneration) {
            # pick a random range, then random codepoint from it; retry until printable
            $tries = 0
            do {
                $rIdx = Get-CryptoRandomInt -MaxExclusive $completeRanges.Count
                $r = $completeRanges[$rIdx]
                $cp = Get-CryptoRandomInRange -MinInclusive $r.Start -MaxExclusive ($r.End + 1)
                $tries++
            } while (-not (Is-PrintableCodePoint -cp $cp) -and $tries -lt 50)

            if (-not (Is-PrintableCodePoint -cp $cp)) {
                # fallback: pick a BMP printable codepoint from Basic Latin
                $cp = Get-CryptoRandomInRange -MinInclusive 0x0020 -MaxExclusive 0x007E
            }
            try {
                $char = [System.Char]::ConvertFromUtf32($cp)
            } catch {
                $char = '?' # fallback
            }

            # Avoid repeating last character (best-effort)
            $attempts = 0
            while (($char -eq $last -or $char.ToLower() -eq $last -or $char.ToUpper() -eq $last) -and $attempts -lt 3) {
                $rIdx = Get-CryptoRandomInt -MaxExclusive $completeRanges.Count
                $r = $completeRanges[$rIdx]
                $cp = Get-CryptoRandomInRange -MinInclusive $r.Start -MaxExclusive ($r.End + 1)
                if (Is-PrintableCodePoint -cp $cp) {
                    $char = [System.Char]::ConvertFromUtf32($cp)
                }
                $attempts++
            }
            $last = $char
            $result += $char
        } else {
            $rand = Get-CryptoRandomInt -MaxExclusive $base.Length
            $char = $base[$rand]

            # Avoid repeating the last character
            $attempts = 0
            while (($char -eq $last -or
                    $char.ToString().ToLower() -eq $last -or
                    $char.ToString().ToUpper() -eq $last) -and
                    $attempts -lt 3) {
                $rand = Get-CryptoRandomInt -MaxExclusive $base.Length
                $char = $base[$rand]
                $attempts++
            }

            $last = $char
            $result += $char
        }
    }

    # Ensure selected character sets are represented
    $resultChars = $result.ToCharArray()

    if ($IncludeCyrillic -and -not (Test-CharInString -TestString $result -CharSet $cyrillicLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $cyrillicLetters
    }
    if ($IncludeGreek -and -not (Test-CharInString -TestString $result -CharSet $greekLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $greekLetters
    }
    if ($IncludeArmenian -and -not (Test-CharInString -TestString $result -CharSet $armenianLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $armenianLetters
    }
    if ($IncludeHangul -and -not (Test-CharInString -TestString $result -CharSet $hangulLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $hangulLetters
    }
    if ($IncludeNordic -and -not (Test-CharInString -TestString $result -CharSet $nordicLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $nordicLetters
    }
    if ($IncludeArabic -and -not (Test-CharInString -TestString $result -CharSet $arabicLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $arabicLetters
    }
    if ($IncludeGeorgian -and -not (Test-CharInString -TestString $result -CharSet $georgianLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $georgianLetters
    }
    if ($IncludeEthiopian -and -not (Test-CharInString -TestString $result -CharSet $ethiopianLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $ethiopianLetters
    }
    if ($IncludeThaana -and -not (Test-CharInString -TestString $result -CharSet $thaanaLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $thaanaLetters
    }
    if ($IncludeHanzi -and -not (Test-CharInString -TestString $result -CharSet $hanziLetters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $hanziLetters
    }
    if ($IncludeCustom -and -not (Test-CharInString -TestString $result -CharSet $CustomCharacters)) {
        $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
        $resultChars[$pos] = Get-CryptoRandomChar -CharSet $CustomCharacters
    }
    if ($IncludeLatin) {
        if (-not ($result -cmatch '[a-z]')) {
            $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
            $resultChars[$pos] = [char](Get-CryptoRandomInRange -MinInclusive 97 -MaxExclusive 123)
        }
        if (-not ($result -cmatch '[A-Z]')) {
            $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
            $resultChars[$pos] = [char](Get-CryptoRandomInRange -MinInclusive 65 -MaxExclusive 91)
        }
    }
    if ($IncludeNumbers -and -not (Test-CharInString -TestString $result -CharSet $numbersLetters)) {
        for ($i = 0; $i -lt 3; $i++) {
            $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
            $resultChars[$pos] = Get-CryptoRandomChar -CharSet $numbersLetters
        }
    }
    if ($IncludeSigns -and -not (Test-CharInString -TestString $result -CharSet $signsLetters)) {
        for ($i = 0; $i -lt 2; $i++) {
            $pos = Get-CryptoRandomInt -MaxExclusive $result.Length
            $resultChars[$pos] = Get-CryptoRandomChar -CharSet $signsLetters
        }
    }

    $result = -join $resultChars
    $result = Get-ShuffledString -InputString $result

    # Compute possible combinations taking into account range-based generation
    function Get-PrintableCountInRange {
        param(
            [int]$Start,
            [int]$End
        )
        if ($End -lt $Start) { return 0 }
        $count = [int]($End - $Start + 1)

        # Helper to subtract overlap with an excluded interval
        $subtractOverlap = {
            param($a,$b,$x,$y)
            $lo = [Math]::Max($a,$x)
            $hi = [Math]::Min($b,$y)
            if ($hi -ge $lo) { return [int]($hi - $lo + 1) } else { return 0 }
        }

        # Excluded ranges
        $count -= & $subtractOverlap $Start $End 0x0000 0x001F    # C0 controls
        $count -= & $subtractOverlap $Start $End 0x007F 0x009F    # C1 controls
        $count -= & $subtractOverlap $Start $End 0xD800 0xDFFF    # Surrogates
        $count -= & $subtractOverlap $Start $End 0xFDD0 0xFDEF    # Non-characters FDD0..FDEF
        $count -= & $subtractOverlap $Start $End 0xFE00 0xFE0F    # Variation selectors

        # Subtract plane-end non-characters (U+??FFFE and U+??FFFF for planes 0..16)
        for ($plane = 0; $plane -le 0x10; $plane++) {
            $nc1 = ($plane -band 0xFFFFFFFF) * 0x10000 + 0xFFFE
            $nc2 = ($plane -band 0xFFFFFFFF) * 0x10000 + 0xFFFF
            if ($nc1 -ge $Start -and $nc1 -le $End) { $count-- }
            if ($nc2 -ge $Start -and $nc2 -le $End) { $count-- }
        }

        if ($count -lt 0) { $count = 0 }
        return $count
    }

    if ($useRangeGeneration) {
        $totalPrintable = 0
        foreach ($r in $completeRanges) {
            $totalPrintable += Get-PrintableCountInRange -Start $r.Start -End $r.End
        }
    } else {
        $totalPrintable = $base.Length
    }

    # Use logarithms to detect overflow beyond double max (~1.7976931348623157e+308)
    if ($totalPrintable -le 0) {
        $combinations = 0
    } else {
        $log10Total = [Math]::Log10([double]$totalPrintable)
        $log10Comb = $log10Total * $Length
        # Double.MaxValue ~= 1.7976931348623157e+308 -> log10 ~= 308.25471555991675
        if ($log10Comb -gt 308.25471555991675) {
            $combinations = [double]::MaxValue
        } else {
            $combinations = [Math]::Pow([double]$totalPrintable, $Length)
        }
    }

    return @{
        Password    = $result
        Combinations = $combinations
    }
}

Export-ModuleMember -Function Get-ShuffledString, Test-CharInString, New-StrongPassword
