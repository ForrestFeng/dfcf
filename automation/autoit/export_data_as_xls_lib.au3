#include <Date.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <Timers.au3>
;#RequireAdmin


$TIMEOUT = 5

$centerX = 666
$centerY = 388

$idxbtnX = 38
$idxbtnY = 230

$lstX = 208
$lstY = 180

$WAIT_OPEN_SECONDS = 20
$AUTO_MODE_SendKeyDelay = 100
$MANUAL_MODE_SendKeyDelay = 100

$pname = "mainfree.bin"
$dfcfexe = "C:\eastmoney\swc8\stockway.exe"

; Will replace the ':' with '_' in the time part and replace '/' witn '-' in the date part
Func TimeStringForFileName()
   Local $now = _NowCalc()
   $now = StringReplace( $now, "/", "-")
   $now = StringReplace( $now, ":", "_")
   return $now
EndFunc

Func TimedFullFileName($dir, $time, $name)
   DirCreate($dir)
   Local $fn = $dir & "\" & $time & " " & $name
   ;MsgBox($MB_SYSTEMMODAL, "", $fn)
   Return $fn
EndFunc

Func CloseExportDlg()
   Local $aList = WinList()
   ; Loop through the array displaying only visable windows with a title.
   For $i = 1 To $aList[0][0]
	  If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
		If $aList[$i][0] == "导出对话框" Then
		    ;MsgBox($MB_SYSTEMMODAL, "", "Got it")
		    Local $hWnd  = $aList[$i][1]
		    WinClose($hWnd)
		EndIf
	  EndIf
   Next
EndFunc


Func ExportDataAsXls($shortcut, $exportpos, $dir, $time, $auto)
   ; First close any adv dlg if any
   CloseAdvDlgIfAny()

	; Retrieve a list of window handles.
	Local $aList = WinList()

	; Loop through the array displaying only visable windows with a title.
	For $i = 1 To $aList[0][0]
		If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
		   If $aList[$i][0] == "东方财富通金融终端" Then
			   Local $hWnd  = $aList[$i][1]
			   WinActivate($hWnd)
			   Sleep(300)
			   Send("{ESC}")

			   IF $auto  Then
				  AutoItSetOption("SendKeyDelay", $AUTO_MODE_SendKeyDelay)
			   Else
				  AutoItSetOption("SendKeyDelay", $MANUAL_MODE_SendKeyDelay)
			   EndIf

			   If $shortcut == "index" Then
				  ; open the index table
				  MouseMove($idxbtnX, $idxbtnY, 2)
				  MouseClick("left")
			   Else
				  Send($shortcut)
				  Send("{ENTER}")
			   EndIf

			   ; give it 2 seconds to refresh data
			   Sleep(2*1000)

			   ; bring up the context menu
			   MouseMove($lstX, $lstY, 2)
			   ; prevent click on the adv
			   CloseAdvDlgIfAny()
			   MouseClick("right")

			   ; start the export dialog
			   Send("{DOWN " & $exportpos & "}{RIGHT 1}{ENTER}")

			   ; change the output file name.
			   AutoItSetOption("SendKeyDelay", 20)
			   Local $fn = TimedFullFileName($dir, $time, $shortcut & ".xls")
			   Send("{TAB 2}" & $fn)

			   ; stop here if not in auto mode
			   IF $auto Then
				  ; accept default config and wait 2 seconds to close the dlg
				  Send("{ENTER 3}")
				  CountDown(2, "Wait Complete")
				  CloseExportDlg()
			   EndIf

			   ; close the dialog may need Sleep(500)a while

			   ; Min all
			  ;WinMinimizeAll()

			  ;MsgBox($MB_SYSTEMMODAL, "", "Got it")
		   EndIf

			;MsgBox($MB_SYSTEMMODAL, "", "Title: " & $aList[$i][0] & @CRLF & "Handle: " & $aList[$i][1])
		EndIf
	Next
 EndFunc   ;==>Example


; If $time is not empty it is used else will use _NowCalc to get the current time
Func AllowRunning($wday, $time)
   Local $now = _NowCalc()
   ; time string in the format of 13:09:33
   IF Not $time Then
	  $time = StringSplit($now, " ")[2]
   EndIf



   ;@WDAY Numeric day of week. Range is 1 to 7 which corresponds to Sunday through Saturday.
   ; only run for weekday from 1 - 5
   ; @WDAY [1,5]
   ; @HOUR@MIN [9:30, 11:30] & [13:00,15:00]
   IF $wday >= 2 And $wday <= 6 Then
	  ; AM and PM
	  IF StringCompare($time, "09:30:00") >= 0 and StringCompare($time, "11:30:00") <= 0 Then
		 ConsoleWrite("wday " & $wday & " time " & $time & " return True" & @CRLF)
		 return True
	  ElseIf StringCompare($time, "13:00:00") >= 0 and StringCompare($time, "15:00:00") <= 0 Then
		 ;MsgBox($MB_SYSTEMMODAL, "", "Got it")
		 ConsoleWrite("wday " & $wday & " time " & $time & " return True" & @CRLF)
		 Return True
	  EndIf

   EndIf
   ConsoleWrite("wday " & $wday & " time " & $time & " return False" & @CRLF)
   Return False
EndFunc

Func AllowRunningTest()
   ;MsgBox($MB_SYSTEMMODAL, "_NowCalc", _NowCalc())
   $info = "Unexpected return, please check error"
   ; False
   IF AllowRunning(3, "05:20:44") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(3, "09:29:59") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

   ; True
   IF Not AllowRunning(3, "09:30:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "09:30:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "10:34:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "11:08:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "11:29:59") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "11:30:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

   ; False
   IF AllowRunning(1, "09:30:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(1, "09:30:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(7, "10:34:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(7, "11:08:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(7, "11:29:59") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(7, "11:30:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

   ; Fase
   IF AllowRunning(2, "11:30:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(2, "11:34:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(2, "12:20:44") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(2, "12:10:64") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(2, "12:00:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(2, "12:59:59") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

   ; True
   IF Not AllowRunning(5, "13:00:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(5, "13:00:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(5, "14:00:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(5, "14:59:59") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(5, "15:00:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

   ; Fase
   IF AllowRunning(5, "15:00:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(5, "16:20:44") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

EndFunc




Func Open()
   ; Open the Process
   Trace("Open dfcf Process ...")
   Local $try = 0
   Local $iPID = Run($dfcfexe, "", @SW_SHOWMAXIMIZED)
   while ((ProcessExists($pname) == 0  And $try < $TIMEOUT))
	  $try += 1
	  Sleep(1*1000)
   WEnd

   ; Sleep until logon
   CountDown($WAIT_OPEN_SECONDS, " Wait Open")

   Trace("Close adv dlg if any...")
   Local $i = 0
   While $i < 5
	  CloseAdvDlgIfAny()
	  $i+=1
   WEnd
   Return $iPID
EndFunc


; Close the Process
Func Close()
   Local	 $try = 0
   Trace("Close dfcf Process ...")
   while ((ProcessExists($pname) <> 0  And $try < $TIMEOUT))
	  ProcessClose($pname)
	  $try += 1
	  Sleep(1000)
   WEnd
EndFunc


Func CloseAdvDlgIfAny()
	; Retrieve a list of window handles.
	Local $aList = WinList()

	; Loop through the array displaying only visable windows with a title.
	For $i = 1 To $aList[0][0]
		If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
		   ;MsgBox($MB_SYSTEMMODAL, "", "Title: " & $aList[$i][0] & @CRLF & "Handle: " & $aList[$i][1])

		   If StringInStr($aList[$i][0], "按Esc关闭") Then
			   Local $hWnd  = $aList[$i][1]
			   WinActivate($hWnd)
			   Sleep(500)
			   Send("{ESC}")
		   EndIf
		EndIf
	Next
 EndFunc   ;==>Example

Func Trace($message)
   Local $now = _NowCalc()
   ConsoleWrite("" & $now & " " & $message & @CRLF)
EndFunc


Func CountDown($seconds, $message)
    Local $hStarttime = _Timer_Init()
    While 1
	  sleep(1*1000)

	  $left = $seconds - Int(_Timer_Diff($hStarttime) / 1000)
	  If $left <= 0 Then ExitLoop

	  ToolTip( $message & " " & $left & " seconds " )
   WEnd

   ToolTip("")
EndFunc