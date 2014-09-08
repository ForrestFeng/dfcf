#include <export_data_as_xls_lib.au3>

;Close()
;Local $iPID = Open()
;CloseAdvDlgIfAny()
;AllowRunningTest()
;AllowRunning(@WDAY, "")
;Exit

;Close()
;Open()


Local $dir 				= "D:\data"
Local $auto 			= 1
Local $refeshsec 		= 2
Local $forcerun 		= 1
Local $capturedelaysec 	= 60
Local $opendelaysec 	= 35

Local $dfcfpname 		= "mainfree.bin"
Local $dfcfexe 			= "C:\eastmoney\swc8\stockway.exe"


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
   EndIf

   ; If any file not saved successfully restart dfcf app
   If Not FileExists($fn1) or Not FileExists($fn2) or Not FileExists($fn3) or Not FileExists($fn4) or Not FileExists($fn5) Then
	  Close($dfcfpname)
	  Open($dfcfexe, $dfcfpname, $opendelaysec)
   Else
	  ; Capture succeed, sleep a while to start next capture
	  CountDown($capturedelaysec, "Next Capture")
   EndIf

WEnd

