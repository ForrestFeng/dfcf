#include <export_data_as_xls_lib.au3>

Local $dir = "D:\data"
Local $auto = 1

Close()
Open()

For $i = 1 To 1
   Local $time = TimeStringForFileName()
   ExportDataAsXls("CWSJ",  7, $dir, $time, $auto)
Next


