#!/usr/bin/pwsh


        ##############################################################
        ##                                                          ##
        ##  logwert.ps1                            version. 1.2     ##
        ##                                                          ##
        ##  Dies ist ein Hilfsscript fuer _shares_spiegeln.bat      ##
        ##  und der Nachfolger des CMD-Scriptes "logwert.cmd",      ##
        ##  Es wertet die Robologfile aus und fast diese zusammen.  ##
        ##                                                          ##
        ##  @parameter: [Pfad-Log1] [Pfad-Log2] [Pfad-Log3] ...	    ##
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

function Log_Start ([String]$sLogPfad){
 If(Test-Path $sLogPfad) {                #Testen Ob Datei Existiert
 $tmp = ""
 $tmp = Get-Content $sLogPfad             #Inhalt in Array
 $tmp | ForEach-Object { Log_Main $_ }    #Jede Zeile des 1D Arrays einzeln Bearbeiten
 }
} #Starte Verarbeitung

function Log_Main ([String]$sLine){
#Trenn Zeichen Setzen
$sLine = $sLine.replace("`"", "#")
$sLine = $sLine.replace(",", "#")
$sLine = $sLine.replace("Insgesamt:", "")

if($sLine -match "[0-z]") {


 ###Anomalien ausschließen

 while(" ".Equals($sLine.Substring(0,1))) {$sLine = $sLine.Substring(1, $sLine.Length - 1)}
 #Wenn String Mit Lehrzeichen beginnt entfernen
 while("#".Equals($sLine.Substring(0,1))) {$sLine = $sLine.Substring(1, $sLine.Length - 1)}
 #Wenn String Mit Trenzeichen beginnt entfernen
 while(" ".Equals($sLine.Substring($sLine.Length - 1,1))) {$sLine = $sLine.Substring(0, $sLine.Length - 1)}
 #Wenn String Mit Lehrzeichen endet entfernen
 while("#".Equals($sLine.Substring($sLine.Length - 1,1))) {$sLine = $sLine.Substring(0, $sLine.Length - 1)}
 #Wenn String Mit Trenzeichen endet entfernen
 while($sLine.IndexOf("##") -gt -1 ) {$sLine = $sLine.Replace("##", "#")}
 #Mehrere hintereinander folgende Trenzeichen entfernen
 while($sLine.IndexOf("  ") -gt -1 ) {$sLine = $sLine.Replace("  ", " ")}
 #Mehrere hintereinander folgende Lehrzeichen entfernen
 $sLine.Split("#") | ForEach-Object { WichCase $_ }
 }
} #Zeilenweise auswertung

function WichCase ([String]$sToken) {

if($sToken -match "[0-z]") {

 while(" ".Equals($sToken.Substring(0,1))) {$sToken = $sToken.Substring(1, $sToken.Length - 1)}
 #Lehrzeichen vor werten entfernen
 while(" ".Equals($sToken.Substring($sToken.Length - 1,1))) {$sToken = $sToken.Substring(0, $sToken.Length - 1)}
 #Lehrzeichen nach werten entfernen

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
} #Übergabe der Zeile; Auswertung; Speicherung in Globale Variablen

function Calc_Byte_Sice ([Double]$Wert, [String]$EinheitEingabe, [String]$EinheitAusgabe ) {

#Calc_Byte_Sice:  [Wert] [Einheit-Ausgabe] [Einheit-Eingabe]
# Wenn bei Einheit etwas anderes als KB,MB,GB,TB eingebeben Wird, Wird mit Bytes gerechnet

#fertieren der unterschiedlichen Groeßenangaben (umrechnungseinheit= 1024)
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

  # Abfangen von Größenangaben die es nicht giebt/die nicht behandelt werden
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
} #[Wert] [Einheit-Ausgabe] [Einheit-Eingabe]

##########################################################################################################

#for each param do start(param)
$args | ForEach-Object { Log_Start $_ }

[String]$sLog_Copy_errors = "$Global:zLog_Copy_errors"
[String]$sLog_Copy_Size = [math]::round((Calc_Byte_Sice $Global:zLog_Copy_Size b $Global:Log_Copy_Size_Einheit), 2)
[String]$sLog_Copy_real_Size = [math]::round((Calc_Byte_Sice $Global:zLog_Copy_real_Size b $Global:Log_Copy_Size_Einheit), 2)
[String]$sLog_Copy_item = "$Global:zLog_Copy_item"
[String]$sLog_Copy_real_item = "$Global:zLog_Copy_real_item"
[String]$sLog_Copy_Size_Einheit = "$Global:Log_Copy_Size_Einheit"

echo "Insgesamt: $sLog_Copy_real_item von $sLog_Copy_item Dateien kopiert, $sLog_Copy_errors Fehler, $sLog_Copy_real_Size $sLog_Copy_Size_Einheit von $sLog_Copy_Size $sLog_Copy_Size_Einheit kopiert"
