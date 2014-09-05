#include <Constants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3> ; Required for _ArrayDisplay only.

; Recursively display a list of files in a directory.
Example()

Func Example()
    Local $sFilePath = "" ; use current wording dir
	; simple log
	Local $log = " >>pythonh_stdout.log 2>>pythonh_stderr.log"
	;date-time log
	Local $log = " >> """ & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & @MIN & @SEC & " " & "pythonh_stdout.log""" & " 2>> """ & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & @MIN & @SEC & " " & "pythonh_stderr.log"""
	;date log
    Local $log = " >> """ & @YEAR & "-" & @MON & "-" & @MDAY & " " & "pythonh_stdout.log""" & " 2>> """ & @YEAR & "-" & @MON & "-" & @MDAY & " " & "pythonh_stderr.log"""

	Local $sProcess = @ComSpec & " /c python " & $CmdLineRaw & $log
    ;MsgBox($MB_SYSTEMMODAL, "Command", $sProcess)

    RunWait($sProcess, $sFilePath, @SW_HIDE)

   ; Success: the exit code of the program that was run.
   ; Failure: sets the @error flag to non-zero.
   ; Autoit is buggy it does *not* set the %errorlevel% for DOS or windows command prompt
   ; Exit(@error )
EndFunc   ;==>Example

