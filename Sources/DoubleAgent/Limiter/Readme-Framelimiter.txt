History:
--------

Version 0.2, 11/15/2007
-----------------------
 - New command line switch to set the desired fps (/f:x), default is 30
 - New command line switch to enable or disable logging (/l:ON|OFF), default is OFF
 - New ingame keys to change the desired fps (F10 decrease / F11 increase)
 - New ingame fps display, show or hide with F12, command line switch is /x:ON|OFF, default is OFF

Version 0.1b, 11/13/2007
-----------------------
 - Fixed Bug in D3D9 Hook
 - Fixed Bug in D3D8 Hook


Version 0.1, 11/12/2007
-----------------------
 - Inital Release
Batch Dateien brauchst nicht mal. Erstelle einen shortcut von der Limiter.exe und füge im ZIEL einfach den PFad zur game.exe dazu, fertig 
Wennst den shortcut umbenennst so wie die game .exe heißt, dann weißt auch gleich was du startest- und das machst dann mit allen games die du so hast 

Zur Nutzung:

Archiv entpacken und mit der Konsole in das Verzeichnis wechseln (oder ggf. eine Batchdatei anlegen). Hier der Syntax:

fps_limiter /r: D3D8|D3D9|OGL "pfad zur spiele.exe" (ohne das Leerzeichen nach dem Doppelpunkt, das Forum macht aus : D ein Smiley)

Mit dem Schalter /r wird der Renderer Hook angegeben, wenn dieser Schalter nicht angegeben wird, wird automatisch D3D9 benutzt. Beispiel:

fps_limiter /r: OGL "c:\spiele\quake4\quake4.exe" <- Nutzt OGL, also explizit angeben
fps_limiter "c:\spiele\jade empire\jadeempire.exe" <- Nutzt D3D9, muss also nicht angegeben werden

Wenn der Pfad richtig ist, wird das Spiel gestartet. Anschließend befindet sich im Spielverzeichnis eine Datei namen "limiter.log".