#!/usr/bin/pwsh


        ##############################################################
        ##                                                          ##
        ##  logwert.ps1                            version. 1.2     ##
        ##                                                          ##
        ##  This is a smal help script                              ##
        ##  It evaluates robocopy logs and summarizes them          ##
        ##                                                          ##
        ##  @parameter: [path-log1] [path-log2] [path-log3] ...     ##
        ##                                                          ##
        ##  @author:  Martin.Huber@stbaro.bayern.de                 ##
        ##                                                          ##
        ##############################################################





###################################  Einstellungen  ####################################################

# b (=Bytes), k (=Kilobytes), m (=Megabytes), g (=Gigabytes) und t (=Terabytes)
[String]$Global:Log_Copy_Size_Einheit = "g"


################################### Hilfsvariablen NICHT editieren #######################################

[Double]$Global:zLog_Copy_errors = 0
[Double]$Global:zLog_Copy_Size = 0
[Double]$Global:zLog_Copy_real_Size = 0
[Double]$Global:zLog_Copy_item = 0
[Double]$Global:zLog_Copy_real_item = 0

###################################  Functionen  ##########################################################

function Log_Start ([String]$sLogpath){
 If(Test-Path $sLogpath) {                #test if file exists
 $tmp = ""
 $tmp = Get-Content $sLogpath             #copy file into list
 $tmp | ForEach-Object { Log_Main $_ }    #process each line
 }
} # start processing

function Log_Main ([String]$sLine){
# separate Set character
$sLine = $sLine.replace("`"", "#")
$sLine = $sLine.replace(",", "#")
$sLine = $sLine.replace("Insgesamt:", "")

if($sLine -match "[0-z]") {


 ### rule out anomalies

 while(" ".Equals($sLine.Substring(0,1))) {$sLine = $sLine.Substring(1, $sLine.Length - 1)}
 #Remove when String Begins with Lehrzeichen
 while("#".Equals($sLine.Substring(0,1))) {$sLine = $sLine.Substring(1, $sLine.Length - 1)}
 #If string begins with delimiter remove
 while(" ".Equals($sLine.Substring($sLine.Length - 1,1))) {$sLine = $sLine.Substring(0, $sLine.Length - 1)}
 #If String Ends with Lehrzeichen Remove String
 while("#".Equals($sLine.Substring($sLine.Length - 1,1))) {$sLine = $sLine.Substring(0, $sLine.Length - 1)}
 #Remove if string ends with delimiters
 while($sLine.IndexOf("##") -gt -1 ) {$sLine = $sLine.Replace("##", "#")}
 #Remove several following delimiters in a row
 while($sLine.IndexOf("  ") -gt -1 ) {$sLine = $sLine.Replace("  ", " ")}
 #Remove several following characters in a row
 $sLine.Split("#") | ForEach-Object { WichCase $_ }
 }
} #Line by line evaluation

function WichCase ([String]$sToken) {

if($sToken -match "[0-z]") {

 while(" ".Equals($sToken.Substring(0,1))) {$sToken = $sToken.Substring(1, $sToken.Length - 1)}
 #remove blank before rating
 while(" ".Equals($sToken.Substring($sToken.Length - 1,1))) {$sToken = $sToken.Substring(0, $sToken.Length - 1)}
 #remove blank avter rating

 $aToken = $sToken.Split(" ")

 # Count_Copy_errors
 If(("Fehler".Equals($aToken[1])) -and ($aToken[0] -notmatch "[a-z]")) {
  [Double]$Global:zLog_Copy_errors = [Double]$Global:zLog_Copy_errors + $aToken[0]
  }

 # Count_Items
 If(("von".Equals($aToken[1])) -and ("Dateien".Equals($aToken[3])) -and ($aToken[0] -notmatch "[a-z]") -and  ($aToken[2] -notmatch "[a-z]")) {
  [Double]$Global:zLog_Copy_item += $aToken[2]
  [Double]$Global:zLog_Copy_real_item += $aToken[0]
  }
 }

 # Count_Size
 If(("von".Equals($aToken[2])) -and ("kopiert".Equals($aToken[5])) -and ($aToken[0] -notmatch "[a-z]") -and  ($aToken[3] -notmatch "[a-z]") ){# -and ($aToken[1] -match "[b,k,m,g,t]") -and ($aToken[4] -match "[b,k,m,g,t]")) {
  [Double]$Global:zLog_Copy_Size += (Calc_Byte_Sice $aToken[3] $aToken[4] b)
  [Double]$Global:zLog_Copy_real_Size += (Calc_Byte_Sice $aToken[0] $aToken[1] b)
 }
} #Transfer of the line; evaluation; storage in global variables

function Calc_Byte_Sice ([Double]$Wert, [String]$EinheitEingabe, [String]$EinheitAusgabe ) {

#Calc_Byte_Sice:  [value] [unit outpute] [unit input]
# If you enter something other than KB,MB,GB,TB for unit, it is calculated with bytes.

#fertieren the different size specifications (conversion unit= 1024)
# b (=Bytes), k (=Kilobytes), m (=Megabytes), g (=Gigabytes) und t (=Terabytes)

 If("".Equals("$Wert") -and "0".Equals("$Wert")) {return 0} else {

  $EinheitEingabe = ($EinheitEingabe.substring(0,1)).replace("K","k")
  $EinheitEingabe = ($EinheitEingabe.substring(0,1)).replace("M","m")
  $EinheitEingabe = ($EinheitEingabe.substring(0,1)).replace("G","g")
  $EinheitEingabe = ($EinheitEingabe.substring(0,1)).replace("T","t")

  $EinheitAusgabe = ($EinheitAusgabe.substring(0,1)).replace("K","k")
  $EinheitAusgabe = ($EinheitAusgabe.substring(0,1)).replace("M","m")
  $EinheitAusgabe = ($EinheitAusgabe.substring(0,1)).replace("G","g")
  $EinheitAusgabe = ($EinheitAusgabe.substring(0,1)).replace("T","t")

  # Catching size information that does not exist/that are not handled
  If ( -not ("b".Equals("$EinheitAusgabe") -or "k".Equals("$EinheitAusgabe") -or "m".Equals("$EinheitAusgabe") -or "g".Equals("$EinheitAusgabe") -or "t".Equals("$EinheitAusgabe"))) {$EinheitAusgabe = "else"}
  If ( -not ("b".Equals("$EinheitEingabe") -or "k".Equals("$EinheitEingabe") -or "m".Equals("$EinheitEingabe") -or "g".Equals("$EinheitEingabe") -or "t".Equals("$EinheitEingabe"))) {$EinheitEingabe = "else"}

  switch("$EinheitEingabe") {

  "k" { $Wert = $Wert * 1024 }

  "m" {$Wert = $Wert * 1048576}

  "g" {$Wert = $Wert * 1073741824}

  "t" {$Wert = $Wert * 1099511627776}

  "else" {$Wert = 0 }

  }

  switch("$EinheitAusgabe") {

  "b" {$Wert = [math]::round($Wert, 0)}

  "k" {$Wert = $Wert / 1024}

  "m" {$Wert = $Wert / 1048576}

  "g" {$Wert = $Wert / 1073741824}

  "t" {$Wert = $Wert / 1099511627776}

  "else" {$Wert = 0 }

  }
  return $Wert
 }
} #[value] [unit outpute] [unit input]

##########################################################################################################

#for each param do start(param)
$args | ForEach-Object { Log_Start $_ }

[String]$sLog_Copy_errors = "$Global:zLog_Copy_errors"
[String]$sLog_Copy_Size = [math]::round((Calc_Byte_Sice $Global:zLog_Copy_Size b $Global:Log_Copy_Size_Einheit), 2)
[String]$sLog_Copy_real_Size = [math]::round((Calc_Byte_Sice $Global:zLog_Copy_real_Size b $Global:Log_Copy_Size_Einheit), 2)
[String]$sLog_Copy_item = "$Global:zLog_Copy_item"
[String]$sLog_Copy_real_item = "$Global:zLog_Copy_real_item"
[String]$sLog_Copy_Size_Einheit = "$Global:Log_Copy_Size_Einheit"

echo "Summary: $sLog_Copy_real_item of $sLog_Copy_item files copied, $sLog_Copy_errors errors, $sLog_Copy_real_Size $sLog_Copy_Size_Einheit of $sLog_Copy_Size $sLog_Copy_Size_Einheit copied"
