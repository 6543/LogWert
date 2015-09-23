        ##############################################################
        ##                                                          ##
        ##  logwert.ps1                            version. 1.0     ##
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





###################################  Variablen Declaration  ###############################################
[String]$Global:Log_Copy_Size_Einheit = "GB"


### Hilfsvariablen NICHT editieren ###

[Double]$Global:zLog_Copy_errors = 0
[Double]$Global:zLog_Copy_Size = 0
[Double]$Global:zLog_Copy_real_Size = 0
[Double]$Global:zLog_Copy_item = 0
[Double]$Global:zLog_Copy_real_item = 0

###################################  Functionen  ##########################################################

function Log_Start ([String]$sLogPfad){
 If(Test-Path $sLogPfad) {
 $tmp = ""
 $tmp = Get-Content $sLogPfad
 $tmp | ForEach-Object { Log_Main $_ }
 }
}

function Log_Main ([String]$sLine){
#Zeilenweise auswertung

while(" ".Equals($sLine.Substring(0,1))) {$sLine = $sLine.Substring(1, $sLine.Length - 1)}
while("`"".Equals($sLine.Substring(0,1))) {$sLine = $sLine.Substring(1, $sLine.Length - 1)}
while(" ".Equals($sLine.Substring($sLine.Length - 1,1))) {$sLine = $sLine.Substring(0, $sLine.Length - 1)}

#Trenn Zeichen Setzen
$sLine = $sLine.replace("`"", "#")
$sLine = $sLine.replace(",", "#")
$sLine = $sLine.replace(":", "#")

#Entferne Problemeverursachende Zeichen
$sLine = $sLine.replace(")", "+")
$sLine = $sLine.replace("(", "+")

$sLine.Split("#") | ForEach-Object { WichCase $_ }
}

function WichCase ([String]$sTocken) {
$aTocken = ""
while(" ".Equals($sTocken.Substring(0,1))) {$sTocken = $sTocken.Substring(1, $sTocken.Length - 1)} #Lehrzeichen vor werten entvernen
while(" ".Equals($sTocken.Substring($sTocken.Length - 1,1))) {$sTocken = $sTocken.Substring(0, $sTocken.Length - 1)} #Lehrzeichen nach werten entvernen
while($sTocken.IndexOf("  ") -gt -1 ) {$sTocken = $sTocken.Replace("  ", " ")} #Mehrere hintereinander volgende Lehrzeichen entvernen

$aTocken = $sTocken.Split(" ")

# Count_Copy_errors
If("Fehler".Equals($aTocken[1])) { 
 [Double]$Global:zLog_Copy_errors = [Double]$Global:zLog_Copy_errors + $aTocken[0] 
 }

# Count_Items
If("von".Equals($aTocken[1]) -and ("Dateien".Equals($aTocken[3]))) {
 [Double]$Global:zLog_Copy_item = [Double]$Global:zLog_Copy_item + $aTocken[2]
 [Double]$Global:zLog_Copy_real_item = [Double]$Global:zLog_Copy_real_item + $aTocken[0]
 }

# Count_Size
If("von".Equals($aTocken[2]) -and ("kopiert".Equals($aTocken[5])) ) {
 [Double]$Global:zLog_Copy_Size = [Double]$Global:zLog_Copy_Size + (Calc_Bite_Sice $aTocken[3] $aTocken[4] b)
 [Double]$Global:zLog_Copy_real_Size = [Double]$Global:zLog_Copy_real_Size + (Calc_Bite_Sice $aTocken[0] $aTocken[1] b)
 }

} #Übergabe der Zeile; Auswertung; Speicherung in Globale Variablen

function Calc_Bite_Sice ([Double]$Wert, [String]$EinheitEingabe, [String]$EinheitAusgabe ) {

#Calc_Bite_Sice:  [Wert] [Einheit-Ausgabe] [Einheit-Eingabe] 
# Wenn bei Einheit etwas anderes als KB,MB,GB,TB eingebeben Wird, Wird mit Bites gerechnet

#fertieren der unterschiedlichen Groeßenangaben (umrechnungseinheit= 1024)
# b (=Bytes), k (=Kilobytes), m (=Megabytes), g (=Gigabytes) und t (=Terabytes)

 If("".Equals("$sWert") -and "0".Equals("$sWert")) {return 0} else {

  $EinheitEingabe = ($EinheitEingabe.substring(0,1)).replace("K","k")
  $EinheitEingabe = ($EinheitEingabe.substring(0,1)).replace("M","g")
  $EinheitEingabe = ($EinheitEingabe.substring(0,1)).replace("G","g")
  $EinheitEingabe = ($EinheitEingabe.substring(0,1)).replace("T","g")
 
  $EinheitAusgabe = ($EinheitAusgabe.substring(0,1)).replace("K","k")
  $EinheitAusgabe = ($EinheitAusgabe.substring(0,1)).replace("M","g")
  $EinheitAusgabe = ($EinheitAusgabe.substring(0,1)).replace("G","g")
  $EinheitAusgabe = ($EinheitAusgabe.substring(0,1)).replace("T","g")

  
  If ( -not ("k".Equals("$EinheitAusgabe") -or "m".Equals("$EinheitAusgabe") -or "g".Equals("$EinheitAusgabe") -or "t".Equals("$EinheitAusgabe"))) {$EinheitAusgabe = "b"} 
  If ( -not ("k".Equals("$EinheitEingabe") -or "m".Equals("$EinheitEingabe") -or "g".Equals("$EinheitEingabe") -or "t".Equals("$EinheitEingabe"))) {$EinheitEingabe = "b"} 
 
  switch("$EinheitEingabe") {
  
  "k" { $Wert = $Wert * 1024 }
 
  "m" {$Wert = $Wert * 1048576}
 
  "g" {$Wert = $Wert * 1073741824}
 
  "t" {$Wert = $Wert * 1099511627776}
 
  }
 
  switch("$EinheitAusgabe") {

  #"b" {$Wert = [math]::round($Wert, 0)}
 
  "k" {$Wert = $Wert / 1024}
 
  "m" {$Wert = $Wert / 1048576}
 
  "g" {$Wert = $Wert / 1073741824}
 
  "t" {$Wert = $Wert / 1099511627776}
  
  }
  return $Wert
 }
} #[Wert] [Einheit-Ausgabe] [Einheit-Eingabe] 

###################################################################################

#for each param do start(param)
$args | ForEach-Object { Log_Start $_ }

[String]$sLog_Copy_errors = "$Global:zLog_Copy_errors"
[String]$sLog_Copy_Size = [math]::round((Calc_Bite_Sice $Global:zLog_Copy_Size b $Global:Log_Copy_Size_Einheit), 2)
[String]$sLog_Copy_real_Size = [math]::round((Calc_Bite_Sice $Global:zLog_Copy_real_Size b $Global:Log_Copy_Size_Einheit), 2)
[String]$sLog_Copy_item = "$Global:zLog_Copy_item"
[String]$sLog_Copy_real_item = "$Global:zLog_Copy_real_item"

echo "Insgesamt: $sLog_Copy_real_item von $sLog_Copy_item Dateien kopiert, $sLog_Copy_errors Fehler, $sLog_Copy_real_Size g von $sLog_Copy_Size g kopiert"