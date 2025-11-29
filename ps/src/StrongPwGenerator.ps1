# Strong Password Generator - PowerShell with WPF UI
[CmdletBinding()]
param(
    [System.Collections.IDictionary]$CharacterCheckBoxes,
    [int]$PwLength,
    [switch]$PlainText,
    [string]$CustomUnicodeCharacters
)
#################################################################
#                         Configuration                         #
#################################################################

# Theme variables
$BackgroundColor        = "#2D2D2D"
$TitleBarColor          = "#853993"
$OuterBoxColor          = "#3B3B3B"
$SelectedColor          = "#4D4D4D"
$ButtonColor            = "#4D4D4D"
$HoverColor             = "#5A5A5A"
$WindowButtonHoverColor = "#682574"
$TextColor              = "#CCCCCC"
$ButtonTextColor        = "#CCCCCC"
$BorderBrushColor       = "#636363"
$CornerRadius           = "6"
$BorderThickness        = "1"
$TitleFontWeight        = "Bold"
$IconPath               = "$PSScriptRoot/seahawk.png"

#################################################################
#                    Password Generation Logic                  #
#################################################################
Import-Module (Join-Path $PSScriptRoot 'StrongPwGenerator.Core.psm1') -Force

$headlessMode = $PSBoundParameters.ContainsKey('PwLength') -and $PSBoundParameters.ContainsKey('CharacterCheckBoxes')

if ($headlessMode) {
    if ($PwLength -lt 12 -or $PwLength -gt 256) {
        throw "PwLength must be between 12 and 256."
    }

    $length = [int]$PwLength

    $defaultFlags = @{
        IncludeLatin     = $true
        IncludeNumbers   = $true
        IncludeSigns     = $true
        IncludeNordic    = $false
        IncludeCyrillic  = $false
        IncludeGreek     = $false
        IncludeArmenian  = $false
        IncludeHangul    = $false
        IncludeArabic    = $false
        IncludeGeorgian  = $false
        IncludeEthiopian = $false
        IncludeThaana    = $false
        IncludeHanzi     = $false
        IncludeCustom    = $false
        IncludeAllUnicode = $false
        IncludeEmoji     = $false
        IncludeSymbols   = $false
        IncludeDingbats  = $false
    }

    $customCharacters = $null

    if ($CharacterCheckBoxes) {
        $normalizationMap = @{
            "latin"           = "IncludeLatin"
            "latincheck"      = "IncludeLatin"
            "includelatin"    = "IncludeLatin"
            "letters"         = "IncludeLatin"
            "numbers"         = "IncludeNumbers"
            "numberscheck"    = "IncludeNumbers"
            "includenumbers"  = "IncludeNumbers"
            "digits"          = "IncludeNumbers"
            "signs"           = "IncludeSigns"
            "signscheck"      = "IncludeSigns"
            "includesigns"    = "IncludeSigns"
            "nordic"          = "IncludeNordic"
            "nordiccheck"     = "IncludeNordic"
            "includenordic"   = "IncludeNordic"
            "cyrillic"        = "IncludeCyrillic"
            "cyrilliccheck"   = "IncludeCyrillic"
            "includecyrillic" = "IncludeCyrillic"
            "greek"           = "IncludeGreek"
            "greekcheck"      = "IncludeGreek"
            "includegreek"    = "IncludeGreek"
            "armenian"        = "IncludeArmenian"
            "armeniancheck"   = "IncludeArmenian"
            "includearmenian" = "IncludeArmenian"
            "hangul"          = "IncludeHangul"
            "hangulcheck"     = "IncludeHangul"
            "includehangul"   = "IncludeHangul"
            "arabic"          = "IncludeArabic"
            "arabiccheck"     = "IncludeArabic"
            "includearabic"   = "IncludeArabic"
            "georgian"        = "IncludeGeorgian"
            "georgiancheck"   = "IncludeGeorgian"
            "includegeorgian" = "IncludeGeorgian"
            "ethiopian"       = "IncludeEthiopian"
            "ethiopiancheck"  = "IncludeEthiopian"
            "includeethiopian"= "IncludeEthiopian"
            "thaana"          = "IncludeThaana"
            "thaanacheck"     = "IncludeThaana"
            "includethaana"   = "IncludeThaana"
            "hanzi"           = "IncludeHanzi"
            "hanzicheck"      = "IncludeHanzi"
            "includehanzi"    = "IncludeHanzi"
            "custom"          = "IncludeCustom"
            "customcheck"     = "IncludeCustom"
            "includecustom"   = "IncludeCustom"
            "customunicode"   = "IncludeCustom"
            "unicode"         = "IncludeCustom"
            "includeunicode"  = "IncludeCustom"
            "allunicode"      = "IncludeAllUnicode"
            "completeunicode" = "IncludeAllUnicode"
            "unicodeall"      = "IncludeAllUnicode"
            "emoji"           = "IncludeEmoji"
            "emojicheck"      = "IncludeEmoji"
            "includeemoji"    = "IncludeEmoji"
            "symbols"         = "IncludeSymbols"
            "symbolcheck"     = "IncludeSymbols"
            "includesymbols"  = "IncludeSymbols"
            "dingbats"        = "IncludeDingbats"
            "dingbatscheck"   = "IncludeDingbats"
            "includedingbats" = "IncludeDingbats"
        }

        foreach ($entry in $CharacterCheckBoxes.GetEnumerator()) {
            if (-not $entry.Key) { continue }
            $normalized = ($entry.Key.ToString().ToLowerInvariant() -replace '[^a-z]', '')

            if ($entry.Value -is [string]) {
                if ($normalized -in @('customunicodecharacters','customcharacters','unicodecharacters','unicodechars','customchars')) {
                    if (-not [string]::IsNullOrEmpty($entry.Value)) {
                        $customCharacters = $entry.Value
                    }
                    continue
                }
            }
            if (-not $normalized) { continue }
            if ($normalizationMap.ContainsKey($normalized)) {
                $target = $normalizationMap[$normalized]
                $defaultFlags[$target] = [bool]$entry.Value
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('CustomUnicodeCharacters') -and -not [string]::IsNullOrEmpty($CustomUnicodeCharacters)) {
        $customCharacters = $CustomUnicodeCharacters
    }

    # Also allow explicit boolean params for unicode ranges
    if ($PSBoundParameters.ContainsKey('IncludeEmoji') -and $PSBoundParameters['IncludeEmoji']) {
        $defaultFlags['IncludeEmoji'] = $true
    }
    if ($PSBoundParameters.ContainsKey('IncludeSymbols') -and $PSBoundParameters['IncludeSymbols']) {
        $defaultFlags['IncludeSymbols'] = $true
    }
    if ($PSBoundParameters.ContainsKey('IncludeDingbats') -and $PSBoundParameters['IncludeDingbats']) {
        $defaultFlags['IncludeDingbats'] = $true
    }
    if ($PSBoundParameters.ContainsKey('IncludeAllUnicode') -and $PSBoundParameters['IncludeAllUnicode']) {
        $defaultFlags['IncludeAllUnicode'] = $true
    }

    if ($customCharacters -and -not $defaultFlags['IncludeCustom']) {
        $defaultFlags['IncludeCustom'] = $true
    }

    if ($defaultFlags['IncludeCustom'] -and [string]::IsNullOrWhiteSpace($customCharacters)) {
        throw "CustomUnicodeCharacters must be provided when IncludeCustom is enabled."
    }

    if (-not ($defaultFlags.GetEnumerator() | Where-Object { $_.Value })) {
        throw "At least one character set must be enabled via CharacterCheckBoxes."
    }

    $generationParams = @{
        Length = $length
    }
    foreach ($kvp in $defaultFlags.GetEnumerator()) {
        $generationParams[$kvp.Key] = $kvp.Value
    }

    if ($defaultFlags['IncludeCustom'] -and $customCharacters) {
        $generationParams['CustomCharacters'] = $customCharacters
    }

    # Headless pre-generation warning: if required minimums exceed length, warn and continue best-effort
    if ($generationParams['IncludeLatin']) { $reqLatin = 4 } else { $reqLatin = 0 }
    if ($generationParams['IncludeNumbers']) { $reqNums = 3 } else { $reqNums = 0 }
    if ($generationParams['IncludeSigns']) { $reqSigns = 2 } else { $reqSigns = 0 }
    $sumReq = $reqLatin + $reqNums + $reqSigns
    if ($sumReq -gt $generationParams['Length']) {
        Write-Warning "Requested minimum characters ($sumReq) exceed length $($generationParams['Length']). Generator will perform best-effort placement."
    }

    $passwordResult = New-StrongPassword @generationParams

    if (-not $passwordResult -or -not $passwordResult.Password) {
        throw "Password generation failed."
    }

    if ($passwordResult.Password -like 'Error:*') {
        throw $passwordResult.Password
    }

    $securePassword = ConvertTo-SecureString -String $passwordResult.Password -AsPlainText -Force

    if ($PlainText) {
        return [pscustomobject]@{
            Password       = $passwordResult.Password
            SecurePassword = $securePassword
            Combinations   = $passwordResult.Combinations
        }
    }

    return $securePassword
}
#################################################################
#                       Design Elements                         #
#################################################################

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

#################################################################
#                       User Interface                          #
#################################################################
$xamlPath = Join-Path $PSScriptRoot 'StrongPwGenerator.xaml'
if (-not (Test-Path $xamlPath)) {
    throw "XAML file not found: $xamlPath"
}

$xamlContent = Get-Content -LiteralPath $xamlPath -Raw -Encoding UTF8

$reader = New-Object System.Xml.XmlTextReader ([System.IO.StringReader]::new($xamlContent))
try {
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    $errMsg = $_.Exception.Message
    Write-Error "XAML load failed: $errMsg"

    # Try to extract line numbers from the message and show nearby XAML lines to help debugging
    $startLine = $null; $endLine = $null
    if ($errMsg -match "on line (\d+) position (\d+)") { $startLine = [int]$matches[1] }
    if ($errMsg -match "Line (\d+), position (\d+)") { $endLine = [int]$matches[1] }

    $xamlLines = $xamlContent -split "`n"
    if ($startLine) {
        $from = [Math]::Max(1, $startLine - 6)
        $to = [Math]::Min($xamlLines.Count, $startLine + 6)
        Write-Error "Context around start tag line $startLine (1-based):"
        for ($i = $from; $i -le $to; $i++) {
            $prefix = if ($i -eq $startLine) { '>>' } else { '  ' }
            Write-Error ("{0} {1,4}: {2}" -f $prefix, $i, $xamlLines[$i-1])
        }
    }
    if ($endLine) {
        $from = [Math]::Max(1, $endLine - 6)
        $to = [Math]::Min($xamlLines.Count, $endLine + 6)
        Write-Error "Context around end tag line $endLine (1-based):"
        for ($i = $from; $i -le $to; $i++) {
            $prefix = if ($i -eq $endLine) { '>>' } else { '  ' }
            Write-Error ("{0} {1,4}: {2}" -f $prefix, $i, $xamlLines[$i-1])
        }
    }

    Write-Error "Aborting due to XAML parse error. Please inspect the lines shown above."
    return
}

function Set-SolidColorBrushResource {
    param(
        [Parameter(Mandatory)]
        [object]$Key,
        [string]$ColorString
    )

    if (-not $ColorString) { return }
    try {
        $color = [System.Windows.Media.ColorConverter]::ConvertFromString($ColorString)
    } catch {
        return
    }

    if ($window.Resources.Contains($Key)) {
        $existing = $window.Resources[$Key]
        if ($existing -is [System.Windows.Media.SolidColorBrush]) {
            if ($existing.IsFrozen) {
                $clone = $existing.Clone()
                $clone.Color = $color
                $window.Resources[$Key] = $clone
            } else {
                $existing.Color = $color
            }
            return
        }
    }

    $brush = New-Object System.Windows.Media.SolidColorBrush($color)
    if ($window.Resources.Contains($Key)) {
        $window.Resources[$Key] = $brush
    } else {
        $window.Resources.Add($Key, $brush)
    }
}

Set-SolidColorBrushResource -Key 'ScrollBarThumbBrush' -ColorString $ButtonColor
Set-SolidColorBrushResource -Key 'ScrollBarThumbHoverBrush' -ColorString $HoverColor
Set-SolidColorBrushResource -Key 'ScrollBarTrackBrush' -ColorString $OuterBoxColor
Set-SolidColorBrushResource -Key 'WindowButtonHoverBrush' -ColorString $WindowButtonHoverColor
Set-SolidColorBrushResource -Key 'TextBrush' -ColorString $TextColor
Set-SolidColorBrushResource -Key 'ButtonTextBrush' -ColorString $ButtonTextColor
Set-SolidColorBrushResource -Key 'BorderBrush' -ColorString $BorderBrushColor
Set-SolidColorBrushResource -Key 'BackgroundBrush' -ColorString $BackgroundColor
Set-SolidColorBrushResource -Key 'ButtonBrush' -ColorString $ButtonColor
Set-SolidColorBrushResource -Key 'HoverBrush' -ColorString $HoverColor
Set-SolidColorBrushResource -Key 'OuterBoxBrush' -ColorString $OuterBoxColor
Set-SolidColorBrushResource -Key 'SelectedBrush' -ColorString $SelectedColor
Set-SolidColorBrushResource -Key 'TitleBarBrush' -ColorString $TitleBarColor
Set-SolidColorBrushResource -Key ([System.Windows.SystemColors]::HighlightBrushKey) -ColorString $HoverColor
Set-SolidColorBrushResource -Key ([System.Windows.SystemColors]::ControlBrushKey) -ColorString $BackgroundColor

if ($window.Resources.Contains('CornerRadiusValue')) {
    try {
        $window.Resources['CornerRadiusValue'] = [System.Windows.CornerRadius]::new([double]$CornerRadius)
    } catch {}
}

if ($window.Resources.Contains('BorderThicknessValue')) {
    try {
        $thickness = [System.Windows.Thickness]::new([double]$BorderThickness)
        $window.Resources['BorderThicknessValue'] = $thickness
    } catch {}
}

if ($window.Resources.Contains('TitleFontWeightValue')) {
    $fontWeight = $null
    $bindingFlags = [System.Reflection.BindingFlags]::Public -bor [System.Reflection.BindingFlags]::Static
    $fontProperty = [System.Windows.FontWeights].GetProperty($TitleFontWeight, $bindingFlags)
    if ($fontProperty) {
        $fontWeight = $fontProperty.GetValue($null, $null)
    }
    if (-not $fontWeight) {
        $fontWeight = [System.Windows.FontWeights]::Normal
    }
    $window.Resources['TitleFontWeightValue'] = $fontWeight
}

# Bind controls (use FindName first, fallback to LogicalTreeHelper if needed)
function Get-ControlByName {
    param(
        [System.Windows.DependencyObject]$Root,
        [string]$Name
    )
    $ctrl = $null
    try { $ctrl = $Root.FindName($Name) } catch {}
    if (-not $ctrl) {
        try { $ctrl = [System.Windows.LogicalTreeHelper]::FindLogicalNode($Root, $Name) } catch {}
    }
    return $ctrl
}

$appIcon = Get-ControlByName -Root $window -Name "AppIcon"
$closeBtn = Get-ControlByName -Root $window -Name "CloseButton"
$minBtn = Get-ControlByName -Root $window -Name "MinimizeButton"
$maxBtn = Get-ControlByName -Root $window -Name "MaximizeButton"
$titleBar = Get-ControlByName -Root $window -Name "TitleBar"
$lengthSelector = Get-ControlByName -Root $window -Name "LengthSelector"
$passwordOutput = Get-ControlByName -Root $window -Name "PasswordOutput"
$combinationsText = Get-ControlByName -Root $window -Name "CombinationsText"
$generateButton = Get-ControlByName -Root $window -Name "GenerateButton"
$copyButton = Get-ControlByName -Root $window -Name "CopyButton"
$latinCheck = Get-ControlByName -Root $window -Name "LatinCheck"
$numbersCheck = Get-ControlByName -Root $window -Name "NumbersCheck"
$signsCheck = Get-ControlByName -Root $window -Name "SignsCheck"
$nordicCheck = Get-ControlByName -Root $window -Name "NordicCheck"
$greekCheck = Get-ControlByName -Root $window -Name "GreekCheck"
$cyrillicCheck = Get-ControlByName -Root $window -Name "CyrillicCheck"
$armenianCheck = Get-ControlByName -Root $window -Name "ArmenianCheck"
$hangulCheck = Get-ControlByName -Root $window -Name "HangulCheck"
$arabicCheck = Get-ControlByName -Root $window -Name "ArabicCheck"
$georgianCheck = Get-ControlByName -Root $window -Name "GeorgianCheck"
$ethiopianCheck = Get-ControlByName -Root $window -Name "EthiopianCheck"
$thaanaCheck = Get-ControlByName -Root $window -Name "ThaanaCheck"
$hanziCheck = Get-ControlByName -Root $window -Name "HanziCheck"
$null = $null
$emojiCheck = Get-ControlByName -Root $window -Name "EmojiCheck"
$symbolCheck = Get-ControlByName -Root $window -Name "SymbolCheck"
$dingbatCheck = Get-ControlByName -Root $window -Name "DingbatCheck"
$allUnicodeCheck = Get-ControlByName -Root $window -Name "AllUnicodeCheck"
$statusText = Get-ControlByName -Root $window -Name "StatusText"

$uiCharacterCheckBoxes = @(
    $latinCheck,
    $numbersCheck,
    $signsCheck,
    $nordicCheck,
    $greekCheck,
    $cyrillicCheck,
    $armenianCheck,
    $hangulCheck,
    $arabicCheck,
    $georgianCheck,
    $ethiopianCheck,
    $thaanaCheck,
    $hanziCheck,
    $emojiCheck,
    $symbolCheck,
    $dingbatCheck,
    $allUnicodeCheck
) | Where-Object { $_ }

$evaluateGenerationState = {
    $hasCharSet = $false
    foreach ($cb in $uiCharacterCheckBoxes) {
        if ($cb.IsChecked) {
            $hasCharSet = $true
            break
        }
    }

    # Custom unicode input removed from UI; keep values valid for headless callers
    $customSelected = $false
    $customValid = $true
    $customValue = ''

    $lengthValid = $false
    $lengthValue = $null
    if ($lengthSelector -and $lengthSelector.SelectedItem) {
        $lengthValue = [int]$lengthSelector.SelectedItem
        $lengthValid = ($lengthValue -ge 12 -and $lengthValue -le 256)
    }

    [pscustomobject]@{
        HasCharSet  = $hasCharSet
        LengthValid = $lengthValid
        LengthValue = $lengthValue
        CustomValid = $customValid
        IncludeCustom = $customSelected
        CustomCharacters = $customValue
        CanGenerate = ($hasCharSet -and $lengthValid -and $customValid)
    }
}

$updateGenerateState = {
    param($sender, $e)

    $state = & $evaluateGenerationState

    if ($generateButton) { $generateButton.IsEnabled = $state.CanGenerate }

    if ($statusText) {
        if (-not $state.CustomValid) {
            $statusText.Text = "Enter at least one custom character."
        } elseif (-not $state.HasCharSet) {
            $statusText.Text = "Select at least one character set."
        } elseif (-not $state.LengthValid) {
            $statusText.Text = "Choose a length between 12 and 256 characters."
        } else {
            $statusText.Text = ""
        }
    }

    return $state
}

# Populate length selector
if ($lengthSelector -ne $null) {
    for ($i = 12; $i -le 256; $i++) { $lengthSelector.Items.Add($i) | Out-Null }
    $lengthSelector.SelectedItem = 32
    $lengthSelector.Add_SelectionChanged($updateGenerateState)
} else {
    Write-Warning "LengthSelector control not found in XAML."
}

foreach ($cb in $uiCharacterCheckBoxes) {
    $cb.Add_Checked($updateGenerateState)
    $cb.Add_Unchecked($updateGenerateState)
}

# Custom Unicode textbox removed from UI wiring (headless still supported)

& $updateGenerateState $null $null | Out-Null

# Load icon
if (Test-Path $IconPath) {
    try {
        $imageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object Uri($IconPath))
        if ($appIcon) { $appIcon.Source = $imageSource }
    } catch {}
}

# Window controls
if ($titleBar) { $titleBar.Add_MouseLeftButtonDown({ $window.DragMove() }) }
if ($closeBtn) { $closeBtn.Add_Click({ $window.Close() }) }
if ($minBtn) { $minBtn.Add_Click({ $window.WindowState = 'Minimized' }) }
if ($maxBtn) {
    $maxBtn.Add_Click({
        if ($window.WindowState -eq 'Maximized') {
            $window.WindowState = 'Normal'
            if ($maxBtn) { $maxBtn.Content = "□" }
        } else {
            $window.WindowState = 'Maximized'
            if ($maxBtn) { $maxBtn.Content = "❐" }
        }
    })
}

# Generate password
$generatePassword = {
    try {
        $state = & $evaluateGenerationState
        if (-not $state.CanGenerate) {
            if ($statusText -and $statusText.Text) {
                [System.Windows.MessageBox]::Show($statusText.Text, "Cannot Generate", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
            }
            return
        }

        $len = $state.LengthValue

        $includeLatin = [bool]($latinCheck -and $latinCheck.IsChecked)
        $includeNumbers = [bool]($numbersCheck -and $numbersCheck.IsChecked)
        $includeSigns = [bool]($signsCheck -and $signsCheck.IsChecked)
        $includeNordic = [bool]($nordicCheck -and $nordicCheck.IsChecked)
        $includeCyrillic = [bool]($cyrillicCheck -and $cyrillicCheck.IsChecked)
        $includeGreek = [bool]($greekCheck -and $greekCheck.IsChecked)
        $includeArmenian = [bool]($armenianCheck -and $armenianCheck.IsChecked)
        $includeHangul = [bool]($hangulCheck -and $hangulCheck.IsChecked)
        $includeArabic = [bool]($arabicCheck -and $arabicCheck.IsChecked)
        $includeGeorgian = [bool]($georgianCheck -and $georgianCheck.IsChecked)
        $includeEthiopian = [bool]($ethiopianCheck -and $ethiopianCheck.IsChecked)
        $includeThaana = [bool]($thaanaCheck -and $thaanaCheck.IsChecked)
        $includeHanzi = [bool]($hanziCheck -and $hanziCheck.IsChecked)
        $includeCustom = [bool]$state.IncludeCustom
        $includeAllUnicode = [bool]($allUnicodeCheck -and $allUnicodeCheck.IsChecked)

        $generatorParams = @{
            Length           = $len
            IncludeLatin     = $includeLatin
            IncludeNumbers   = $includeNumbers
            IncludeSigns     = $includeSigns
            IncludeNordic    = $includeNordic
            IncludeCyrillic  = $includeCyrillic
            IncludeGreek     = $includeGreek
            IncludeArmenian  = $includeArmenian
            IncludeHangul    = $includeHangul
            IncludeArabic    = $includeArabic
            IncludeGeorgian  = $includeGeorgian
            IncludeEthiopian = $includeEthiopian
            IncludeThaana    = $includeThaana
            IncludeHanzi     = $includeHanzi
            IncludeCustom    = $includeCustom
            IncludeAllUnicode = $includeAllUnicode
            IncludeEmoji     = [bool]($emojiCheck -and $emojiCheck.IsChecked)
            IncludeSymbols   = [bool]($symbolCheck -and $symbolCheck.IsChecked)
            IncludeDingbats  = [bool]($dingbatCheck -and $dingbatCheck.IsChecked)
        }

        # UI-level validation: if minimum required characters exceed selected length, warn and offer choices
        if ($includeLatin) { $reqLatin = 4 } else { $reqLatin = 0 }
        if ($includeNumbers) { $reqNums = 3 } else { $reqNums = 0 }
        if ($includeSigns) { $reqSigns = 2 } else { $reqSigns = 0 }
        $sumReq = $reqLatin + $reqNums + $reqSigns
        if ($sumReq -gt $len) {
            $msg = "The selected length $len may be too small to include the generator's minimum required characters ($sumReq total: 2 uppercase, 2 lowercase, 3 numbers, 2 signs).`n`nChoose 'Yes' to increase length to $sumReq, 'No' to proceed (best-effort), or 'Cancel' to abort."
            $res = [System.Windows.MessageBox]::Show($msg, "Length Warning", [System.Windows.MessageBoxButton]::YesNoCancel, [System.Windows.MessageBoxImage]::Warning)
            if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
                # Increase selector and re-evaluate
                if ($lengthSelector) { $lengthSelector.SelectedItem = $sumReq }
                return
            } elseif ($res -eq [System.Windows.MessageBoxResult]::Cancel) {
                return
            }
            # if No, continue with best-effort
        }

        if ($includeCustom) {
            $generatorParams['CustomCharacters'] = $state.CustomCharacters
        }

        $result = New-StrongPassword @generatorParams

        if ($passwordOutput) { $passwordOutput.Text = $result.Password }

        if ($combinationsText) {
            if ($result.Combinations -ge [double]::MaxValue) {
                $combinationsText.Text = "Possible combinations: > 1.7976931348623157e+308"
            } else {
                $combinationsText.Text = "Possible combinations: $($result.Combinations.ToString('E2'))"
            }
        }
    } catch {
        Write-Warning "Failed to generate password: $($_.Exception.Message)"
    }
}

$copyPassword = {
    if ($passwordOutput -and $passwordOutput.Text) {
        [System.Windows.Clipboard]::SetText($passwordOutput.Text)
        [System.Windows.MessageBox]::Show("Password copied to clipboard!", "Copied", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
    } else {
        if ($statusText) { $statusText.Text = "Generate a password before copying." }
    }
}

# Routed commands & keyboard shortcuts
$generateCommand = New-Object System.Windows.Input.RoutedUICommand("Generate Password", "GenerateCommand", [System.Windows.Window])
$copyCommand = [System.Windows.Input.ApplicationCommands]::Copy

$generateExecute = { param($sender,$e) & $generatePassword; $e.Handled = $true }
$generateCanExecute = {
    param($sender,$e)
    $state = & $evaluateGenerationState
    $e.CanExecute = $state.CanGenerate
    $e.Handled = $true
}

$copyExecute = { param($sender,$e) & $copyPassword; $e.Handled = $true }
$copyCanExecute = {
    param($sender,$e)
    $canCopy = ($passwordOutput -and -not [string]::IsNullOrWhiteSpace($passwordOutput.Text))
    $e.CanExecute = $canCopy
    $e.Handled = $true
}

$null = $window.CommandBindings.Add((New-Object System.Windows.Input.CommandBinding($generateCommand, $generateExecute, $generateCanExecute)))
$null = $window.InputBindings.Add((New-Object System.Windows.Input.KeyBinding($generateCommand, (New-Object System.Windows.Input.KeyGesture([System.Windows.Input.Key]::G, [System.Windows.Input.ModifierKeys]::Control)))))

$null = $window.CommandBindings.Add((New-Object System.Windows.Input.CommandBinding($copyCommand, $copyExecute, $copyCanExecute)))
$null = $window.InputBindings.Add((New-Object System.Windows.Input.KeyBinding($copyCommand, (New-Object System.Windows.Input.KeyGesture([System.Windows.Input.Key]::C, [System.Windows.Input.ModifierKeys]::Control)))))

if ($generateButton) { $generateButton.Command = $generateCommand }
if ($copyButton) { $copyButton.Command = $copyCommand }

& $generatePassword
$window.ShowDialog() | Out-Null