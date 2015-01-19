@echo off
setlocal enabledelayedexpansion
rem  ##############################################################
rem  ##                                                          ##
rem  ##  logwert.cmd                            version. 1.2     ##
rem  ##                                                          ##
rem  ##  Dies ist ein Hilfsscript fuer _shares_spiegeln.bat      ##
rem  ##  Es wertet die Robologfile aus und fast diese zusammen   ##
rem  ##                                                          ##
rem  ##  @param %1 Pfadangabe-Logdatei							 ##
rem  ##                                                          ##
rem  ##  @author:  Martin.Huber@stbaro.bayern.de                 ##
rem  ##                                                          ##
rem  ##############################################################

rem Einstellungen

rem Dividierender Faktor der Groe�enausgabe (GB=1073741824,...)
set Log_Copy_Size_Einheit=1073741824


rem ##########################################################################################
rem ########################### Beginn des eigendlichen Programms ############################
rem ##########################################################################################

rem
rem  Hilfsvariablen NICHT editieren
rem

set Log_Path=%1
set Log_Copy_errors=0
set Log_Copy_Size=0
set Log_Copy_real_Size=0
set Log_Copy_item=0
set Log_Copy_real_item=0

rem ##########################################################################################

:Start

rem pruefen ob auszuwertendes Logfile Existiert
if not exist "%Log_Path%" set errorlevel=1&echo Wrong Log Path&goto exit

for /f "delims=# tokens=3" %%c in ('echo %random%') do call :WichCase Dauer xy

rem Logfile Auswerten
rem Jede Zeile mit !!!MAIN!!! einzeln Auswerten
for /f "tokens=*" %%a in (%Log_Path%) do call :Main %%a

rem Umrechnen und Runden der Gr��enausgabe
call :calc "%Log_Copy_Size%/%Log_Copy_Size_Einheit%" Log_Copy_Size
set result=
call :round %Log_Copy_Size%
set Log_Copy_Size=%result%
call :calc "%Log_Copy_real_Size%/%Log_Copy_Size_Einheit%" Log_Copy_real_Size
set result=
call :round %Log_Copy_real_Size%
set Log_Copy_real_Size=%result%


echo Insgesamt: %Log_Copy_real_item% von %Log_Copy_item% Dateien kopiert, %Log_Copy_errors% Fehler, %Log_Copy_real_Size% g von %Log_Copy_Size% g kopiert
set "result=%Log_Copy_real_item% von %Log_Copy_item% Dateien kopiert, %Log_Copy_errors% Fehler, %Log_Copy_real_Size% g von %Log_Copy_Size% g kopiert"
rem bis drei stellen nach dem komma
rem 4 ziffern
rem g
goto Exit

Rem ############################################################################################

Rem Zeilenweise Auswertung
:Main
set Log_Line=%*

Rem Entfernen Problematischer Zeichen und setzen des Trennzeichens (#)
set Log_Line=%Log_Line:"=#%
set Log_Line=%Log_Line:,=#%
set Log_Line=%Log_Line:)=+%
set Log_Line=%Log_Line:(=+%

rem Abschnitte einzeln weiter Auswerten
for /f "delims=# tokens=2" %%b in ('echo %Log_Line%') do (
	set tempvar=%%b
	call :WichCase !tempvar!
)
for /f "delims=# tokens=3" %%c in ('echo %Log_Line%') do call :WichCase %%c
for /f "delims=# tokens=4" %%d in ('echo %Log_Line%') do call :WichCase %%d
for /f "delims=# tokens=5" %%e in ('echo %Log_Line%') do call :WichCase %%e


goto Exit

Rem ##################################################################################################

:WichCase

Rem herausfinden der Informations Art (Item, Error, Size)
rem und starten der zugehoerigen auswerte Funktion

set var_a=%*
if not defined var_a goto exit

Rem Lehre Ordner werden so uebersprungen
for /f "tokens=1" %%g in ('echo !var_a!') do if "%%g" == "Dauer" goto exit

rem zaehlen der Dateien
for /f "tokens=1,3,4" %%h in ('echo !var_a!') do if "%%j" == "Dateien" (
  call :calc "%Log_Copy_item%+%%i" Log_Copy_item
  call :calc "%Log_Copy_real_item%+%%h" Log_Copy_real_item
  goto exit
)

rem zaehlen der Fehler
for /f "tokens=1,2" %%i in ('echo !var_a!') do if "%%j" == "Fehler" (
  call :calc "%Log_Copy_errors%+%%i" Log_Copy_errors
  goto exit
)

rem aufrufen der additions Funktion der Groe�enangaben
for /f "tokens=1,2,4,5,6" %%k in ('echo !var_a!') do if "%%o" == "kopiert" (
  call :count_real_Size %%k %%l
  call :count_Size %%m %%n
  goto exit
)

goto exit

rem ###############################################################################################

Rem erstellen aehnlicher Funktionen um "setlocal enabledelayedexpansion" zu Umgehen

:count_real_Size

set result=
call :convert_to_bytes %1 %2 result
call :calc "%result%+%Log_Copy_real_Size%" Log_Copy_real_Size
goto exit


:count_Size

set result=
call :convert_to_bytes %1 %2 result
call :calc "%result%+%Log_Copy_Size%" Log_Copy_Size
goto exit

rem ##############################################################################################

rem konfertieren der unterschiedlichen Groe�enangaben in bytes (umrechnungseinheit= 1024)
rem b (=Bytes), k (=Kilobytes), m (=Megabytes), g (=Gigabytes) und t (=Terabytes)

:convert_to_bytes
rem convert_to_bytes [zahl] [einheit] (r�ckgabe-variable)
set convert_to_bytes_zahl=%1
set convert_to_bytes_einheit=%2
set convert_to_bytes_var=%3
if not defined convert_to_bytes_var set convert_to_bytes_var=result

rem "Select Case convert_to_bytes_einheit"
goto :convert_to_bytes_%convert_to_bytes_einheit%
:convert_to_bytes_b
set %convert_to_bytes_var%=%convert_to_bytes_zahl%
goto exit
:convert_to_bytes_k
call :calc "%convert_to_bytes_zahl%*1024" %convert_to_bytes_var%
goto exit
:convert_to_bytes_m
call :calc "%convert_to_bytes_zahl%*1048576" %convert_to_bytes_var%
goto exit
:convert_to_bytes_g
call :calc "%convert_to_bytes_zahl%*1073741824" %convert_to_bytes_var%
goto exit
:convert_to_bytes_t
call :calc "%convert_to_bytes_zahl%*1099511627776" %convert_to_bytes_var%
goto exit
:convert_to_bytes_0
echo Kein Sharezugriff!
set %convert_to_bytes_var%=0

goto exit


rem ###############################################################################################

rem auslagern der Rechenfunktion in die PowerShell

:calc
rem calc ["berechnung"] (r�ckgabe-variable)
set result=%1
if not defined result goto exit

rem herausfiltern unerlaubter Zeichen
set result=%result:,=.%
set result=%result:(=^(%
set result=%result:)=^)%
set result=%result:"=%

set result=%result:[=^(%
set result=%result:]=^)%

set var_name=%2
if not defined var_name set var_name=result

for /f %%a in ('powershell -C "%result%"') do set result=%%a
set result=%result:,=.%
set %var_name%=%result%
goto exit

rem #############################################################################################

rem  die Funktion round konnte nicht in die PowerShell ausgelagert werden,
rem  da der befehl Klammern enth�llt!
rem  Rundet immer auf zwei Stellen nach dem Komma

:round
rem round [zahl]
set result=%*
if not defined result goto exit
set result=%result:,=.%
set result=%result:"=%

call :calc "%result%*1000" result
set result=%result:.=#%
set result=%result:,=#%
for /f "delims=# tokens=1" %%a in ('echo %result%') do set result=%%a
set last_number=%result:~-1%
if "%last_number%" GTR "5" (set round_zahl=1) else (set round_zahl=0)
call :calc "%result:~,-1%+%round_zahl%" result
call :calc "%result%/100" result
set last_number=
set round_zahl=
goto exit

rem #############################################################################################

:exit
