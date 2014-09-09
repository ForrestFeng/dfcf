#include <export_data_as_xls_lib.au3>
#include <WinAPIShPath.au3>
#include <Array.au3>

Local $ini = "config.ini"
Local $dir  			= IniRead($ini, "General", "OutDir", "D:\data")
Local $auto  			= Int(IniRead($ini, "General", "Automatic", "1"))
Local $refeshsec  		= Int(IniRead($ini, "General", "RefreshSec", "2"))
Local $forcerun  		= Int(IniRead($ini, "General", "ForceToRun", "0"))
Local $capturedelaysec 	= Int(IniRead($ini, "General", "CaptureDelaySec", "25"))
Local $opendelaysec 	= Int(IniRead($ini, "General", "OpenDelaySec", "30"))
Local $dfcfpname 		= IniRead($ini, "General", "DfcfPorcName", "mainfree.exe")
Local $dfcfexe  		= IniRead($ini, "General", "DfcfExePath", "C:\eastmoney\swc8\mainfree.exe")

Local $msg = "Start capture tool with args of " & @CRLF & " $dir="&$dir & @CRLF & " $auto="&$auto & @CRLF & " $$refeshsec="&$refeshsec & @CRLF & " $forcerun="&$forcerun & @CRLF & " $capturedelaysec="&$capturedelaysec & @CRLF & " $opendelaysec="&$opendelaysec & @CRLF & " $dfcfpname="&$dfcfpname & @CRLF & " $dfcfexe="&$dfcfexe
Trace("[Info] " & $msg)

; main loop to capture data
While 1
   ; to store returned file name
   Local $fn1 = ""
   Local $fn2 = ""
   Local $fn3 = ""
   Local $fn4 = ""
   Local $fn5 = ""

   ; file time stamp
   Local $time = TimeStringForFileName()

   If ($forcerun Or AllowRunning(@WDAY, "")) Then
	  $fn1 = ExportDataAsXls("index",7, $dir, $time, "INDEX", $refeshsec, $auto)
	  $fn2 = ExportDataAsXls("60",   7, $dir, $time, "GGPM",  $refeshsec, $auto)
	  $fn3 = ExportDataAsXls("ZCPM", 7, $dir, $time, "ZCPM",  $refeshsec, $auto)
	  $fn4 = ExportDataAsXls("ZJLX", 7, $dir, $time, "ZJLX",  $refeshsec, $auto)
	  $fn5 = ExportDataAsXls("DDE",  7, $dir, $time, "DDE",   $refeshsec, $auto)
	  ; If any file not saved successfully restart dfcf app
	  If Not FileExists($fn1) or Not FileExists($fn2) or Not FileExists($fn3) or Not FileExists($fn4) or Not FileExists($fn5) Then
		 Close($dfcfpname)
		 ; Open the dfcf app
		 Local $hPID = Open($dfcfexe, $dfcfpname, $opendelaysec)
		 If $hPID == 0 Then
			ExitLoop(1)
		 EndIf
	  Else
		 ; Capture succeed, sleep a while to start next capture
		 CountDown($capturedelaysec, "Next Capture")
	  EndIf
   Else
	  ; Capture succeed, sleep a while to start next capture
	  CountDown($capturedelaysec, "Wait Allow Running")
   EndIf
WEnd

Func PopArg(ByRef $aCmdLine)
   ;_ArrayDisplay($aCmdLine)
   Return _ArrayPop($aCmdLine)
EndFunc