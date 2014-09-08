#include <export_data_as_xls_lib.au3>

Local $dir 			= "D:\data"
Local $auto 		= 1
Local $refeshsec 	= 2
Local $opendelaysec = 35

Local $dfcfpname 	= "mainfree.bin"
Local $dfcfexe 		= "C:\eastmoney\swc8\stockway.exe"


; to store returned file name
Local $fn1 = ""

; try to capture without start dfcf app
Local $time = TimeStringForFileName()
$fn1 = ExportDataAsXls("CWSJ",7, $dir, $time, "CWSJ", $refeshsec, $auto)

; If any file not saved successfully restart dfcf app
If Not FileExists($fn1) Then
   Close($dfcfpname)
   Open($dfcfexe, $dfcfpname, $opendelaysec)
   ; file time stamp
   Local $time = TimeStringForFileName()
   $fn1 = ExportDataAsXls("CWSJ",7, $dir, $time, "CWSJ", $refeshsec, $auto)
EndIf



