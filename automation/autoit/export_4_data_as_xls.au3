#include <export_data_as_xls_lib.au3>

;Close()
;Local $iPID = Open()
;CloseAdvDlgIfAny()
;AllowRunningTest()
;AllowRunning(@WDAY, "")
;Exit

;Close()
;Open()


Local $dir = "D:\data"
Local $auto = 1
Local $forcerun = 1

While 1

   Local $time = TimeStringForFileName()

   If ($forcerun Or AllowRunning(@WDAY, "")) Then
	  ExportDataAsXls("index",7, $dir, $time, $auto)
	  ExportDataAsXls("60",   7, $dir, $time, $auto)
	  ExportDataAsXls("ZCPM", 7, $dir, $time, $auto)
	  ExportDataAsXls("ZJLX", 7, $dir, $time, $auto)
	  ExportDataAsXls("DDE",  7, $dir, $time, $auto)
   EndIf

   ; sleep 60 seconds
   Sleep(1000*60)
WEnd


