
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
        [bool]$IncludeHanzi = $false
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

    if ($Length -lt 1) {
        throw "Length must be greater than 0."
    }

    # Build base string
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

    if ($base.Length -eq 0) {
        return @{
            Password    = "Error: Please select at least one character set"
            Combinations = 0
        }
    }

    # Generate password
    $result = ""
    $last = ""

    for ($i = 0; $i -lt $Length; $i++) {
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
    $combinations = [Math]::Pow($base.Length, $Length)

    return @{
        Password    = $result
        Combinations = $combinations
    }
}

Export-ModuleMember -Function Get-ShuffledString, Test-CharInString, New-StrongPassword
