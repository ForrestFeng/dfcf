#include <Date.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <Timers.au3>
#include <ScreenCapture.au3>
;#RequireAdmin


Local $TIMEOUT = 5
Local $ini = "config.ini"

$idxbtnX 					= Int(IniRead($ini, "UIOperation", "IndexBtnX", "38"))
$idxbtnY 					= Int(IniRead($ini, "UIOperation", "IndexBtnY", "230"))
$lstX 						= Int(IniRead($ini, "UIOperation", "RightClkX", "208"))
$lstY 						= Int(IniRead($ini, "UIOperation", "RightClkY", "180"))
$keyspeed_symbol 			= Int(IniRead($ini, "UIOperation", "KeySpeedSymbol", "200"))
$keyspeed_menu 				= Int(IniRead($ini, "UIOperation", "KeySpeedMenu", "50"))
$keyspeed_fn 				= Int(IniRead($ini, "UIOperation", "KeySpeedFileName", "20"))
$exportdlg_check_delay_ms 	= Int(IniRead($ini, "UIOperation", "ExportDlgCheckDelayMs", "300"))

$HushenGGBtnX           =Int(IniRead($ini, "UIOperation", "HushenGGBtnX", "38"))
$HushenGGBtnY           =Int(IniRead($ini, "UIOperation", "HushenGGBtnY", "163"))
$GGPMBtnX               =Int(IniRead($ini, "UIOperation", "GGPMBtnX", "130"))
$GGPMBtnY               =Int(IniRead($ini, "UIOperation", "GGPMBtnY", "85"))
$ZCPMBtnX               =Int(IniRead($ini, "UIOperation", "ZCPMBtnX", "205"))
$ZCPMBtnY               =Int(IniRead($ini, "UIOperation", "ZCPMBtnY", "85"))
$ZJLXBtnX               =Int(IniRead($ini, "UIOperation", "ZJLXBtnX", "275"))
$ZJLXBtnY               =Int(IniRead($ini, "UIOperation", "ZJLXBtnY", "85"))
$DDEBtnX                =Int(IniRead($ini, "UIOperation", "DDEBtnX", "345"))
$DDEBtnY                =Int(IniRead($ini, "UIOperation", "DDEBtnY", "85"))
$CWSJBtnX               =Int(IniRead($ini, "UIOperation", "CWSJBtnX", "495"))
$CWSJBtnY               =Int(IniRead($ini, "UIOperation", "CWSJBtnY", "85"))

$AMStart				=IniRead($ini, "Schedule", "AMStart", "09:30:00")
$AMEnd					=IniRead($ini, "Schedule", "AMEnd", "11:30:00")
$PMStart				=IniRead($ini, "Schedule", "PMStart", "13:00:00")
$PMEnd					=IniRead($ini, "Schedule", "PMEnd", "15:00:00")
$Holiday				=IniRead($ini, "Schedule", "Holiday", "")


Local $nextBtn = "[CLASS:Button; INSTANCE:1]" ;"Button1"
Local $preBtn = "[CLASS:Button; INSTANCE:4]"; "Button4"
Local $fnishBtn = "[CLASS:Button; INSTANCE:1]";


; Will replace the ':' with '_' in the time part and replace '/' witn '-' in the date part
Func TimeStringForFileName()
   Local $now = _NowCalc()
   $now = StringReplace( $now, "/", "-")
   $now = StringReplace( $now, ":", "_")
   return $now
EndFunc

Func TimedFullFileName($dir, $time, $name)
   Local $datedDir = $dir & "\" & StringLeft ($time, 10)
   DirCreate($datedDir)
   Local $fn = $datedDir & "\"& $time & " " & $name
   ;MsgBox($MB_SYSTEMMODAL, "", $fn)
   Return $fn
EndFunc


Func CloseExportDlg()
   Local $hDlg = GetExportDlg()
   If $hDlg <> 0 Then
	  WinClose($hDlg)
   EndIf
EndFunc


Func GetExportDlg()
   Local $aList = WinList()
   Local $hWnd = 0
   ; Loop through the array displaying only visable windows with a title.
   For $i = 1 To $aList[0][0]
	  If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
		If $aList[$i][0] == "导出对话框" Then
		    ;MsgBox($MB_SYSTEMMODAL, "", "Got it")
		    $hWnd  = $aList[$i][1]
		EndIf
	  EndIf
   Next

   Return $hWnd
EndFunc

; $shortcut : the shortcut key to bring a page active in dfcf
; $exportpos: the export menue position in the context menu
; $dir 		: file output DirCopy
; $time		: the time to be included in the file name
; $name		: the file name to be included in the full file name
; $refeshsec : seconds for dfcf app to refresh data table, after that a dialog will bring up to save whole table data
; $auto 	: true allow user to interact with the save procedure
; return 	: the file name that shold be saved to disk. The file may be not on the disk if capture failed
Func ExportDataAsXls($shortcut, $exportpos, $dir, $time, $name, $delaysec, $auto)
   ; First close any adv dlg if any
   CloseAdvDlgIfAny()

	; Retrieve a list of window handles.
	Local $aList = WinList()
    Local $fn = "Z:\A_not_exist\file"
	; Loop through the array displaying only visable windows with a title.
	For $i = 1 To $aList[0][0]
		If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
		   If $aList[$i][0] == "东方财富通金融终端" Then
			   Local $hWnd  = $aList[$i][1]
			   WinActivate($hWnd)
			   Sleep(300)

			   ; call sub procedure to save data
			   $fn = ActiveDlgAndSaveFile($shortcut, $exportpos, $dir, $time, $name, $refeshsec, $auto)

			   ; try again, if the file was not written to disk
			   Local $retry = 0
			   While  Not FileExists($fn) And $retry < 3
				  Sleep(1000)
				  $retry += 1
			   WEnd

			   IF Not FileExists($fn) Then
				  Trace("[Warn] ****** Try save again ")
				  _ScreenCapture_Capture($fn & "Fail Save.jpg")
				  $fn = ActiveDlgAndSaveFile($shortcut, $exportpos, $dir, $time, $name, $refeshsec, $auto)
				  $retry = 0
				  While  Not FileExists($fn) And $retry < 3
					 Sleep(1000)
					 $retry += 1
				  WEnd
				  IF Not FileExists($fn) Then
					 Trace("[Erro] !!!!!! Cann't save ")
					 _ScreenCapture_Capture($fn & "Cannt Save.jpg")
				  Else
					 Trace("[Info] ----->  Done Save " & $fn)
				  EndIf
			   Else
				  Trace("[Info] -----> Done Save " & $fn)
				  ;CountDown(3, "Wait Complete")
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

	Return $fn

 EndFunc   ;==>Example

; $shortcut : the shortcut key to bring a page active in dfcf
; $exportpos: the export menue position in the context menu
; $dir 		: file output DirCopy
; $time		: the time to be included in the file name
; $name		: the file name to be included in the full file name
; $refeshsec : seconds for dfcf app to refresh data table, after that a dialog will bring up to save whole table data
; $auto 	: true allow user to interact with the save procedure
Func ActiveDlgAndSaveFile($shortcut, $exportpos, $dir, $time, $name, $refeshsec, $auto)
   ; Active the save dialog, when failed try again.
   Local $hDlg = ActiveExportDlg($shortcut, $exportpos, $dir, $time, $name, $refeshsec, $auto)
   If $hDlg == 0 Then
	  $hDlg = ActiveExportDlg($shortcut, $exportpos, $dir, $time, $name, $refeshsec, $auto)
   EndIf

   Local $fn = "C:\not_exist_path\not_exist_file"

   ; do not continue as no export dialog is opend
   If $hDlg == 0 Then
	  Trace("[Erro] The export dialog cann't be openned")
	  _ScreenCapture_Capture($dir & "\export dialog cannt be openned.jpg")
	  Return $fn
   EndIf

   ; change the output file name.
   AutoItSetOption("SendKeyDelay", $keyspeed_fn)
   $fn = TimedFullFileName($dir, $time, $name & ".xls")

   ; Retrieve the text of the edit control in export dlg
   Local $sText = ControlGetText($hDlg, "", "Edit1")
    ;MsgBox($MB_SYSTEMMODAL, "", "The text in Edit1 is: " & $sText)
   If not StringInStr($sText, "Table.xls") Then
	  ;Trace("Cannot find the file name string in this export dlg")
	  _ScreenCapture_Capture($fn & ".export file Edit1 cannot be found.jpg")
	  CloseExportDlg()
	  Sleep(200)
	  $hDlg = ActiveExportDlg($shortcut, $exportpos, $dir, $time, $name, $refeshsec, $auto)
	  If not StringInStr($sText, "Table.xls") Then
		 Trace("[Error] Cannot find the Edit1 file name input control")
		 return "C:\not_exist_path\not_exist_file"
	  EndIf
   EndIf

   ; Set the edit control in export dlg
    ControlSetText($hDlg, "", "Edit1", $fn)
    $sText = ControlGetText($hDlg, "", "Edit1")
	Trace("[Info] Set export file " & $fn)

   ; stop here if not in auto mode
   IF $auto Then
	  ; accept default config and wait 2 seconds to close the dlg
	 ;Send("{ENTER 2}")
	  Local $btnText = ControlGetText($hDlg, "", $nextBtn)
	  Trace("[Info] Click " & $btnText)
	  ControlClick($hDlg, "", $nextBtn)
	  $btnText = ControlGetText($hDlg, "", $nextBtn)
	  Trace("[Info] Click " & $btnText)
	  ControlClick($hDlg, "", $nextBtn)
   EndIf

   Return $fn
EndFunc

Func ActiveExportDlg($shortcut, $exportpos, $dir, $time, $name, $refeshsec, $auto)
   ; Close last eport dlg if any
   CloseExportDlg()
   ; adjust send key speed
   AutoItSetOption("SendKeyDelay", $keyspeed_symbol)
   Local $clickSleep = 90
   ; special case of index
   If $shortcut == "index" Then
	  ; open the index table
	  ;MsgBox($MB_SYSTEMMODAL, "", "X:"& $idxbtnX & " Y:" & $idxbtnY)
	  MouseClick("left", $idxbtnX, $idxbtnY, 2)
   ElseIf $shortcut == "60" Then
	  MouseClick("left", $HushenGGBtnX, $HushenGGBtnY, 2)
   ElseIf $shortcut == "ZCPM" Then
	  MouseClick("left", $HushenGGBtnX, $HushenGGBtnY, 2)
	  Sleep($clickSleep)
	  MouseClick("left",$ZCPMBtnX, $ZCPMBtnY, 2)
   ElseIf $shortcut == "ZJLX" Then
	  MouseClick("left", $HushenGGBtnX, $HushenGGBtnY, 2)
	  Sleep($clickSleep)
	  MouseClick("left", $ZJLXBtnX, $ZJLXBtnY, 2)
   ElseIf $shortcut == "DDE" Then
	  MouseClick("left", $HushenGGBtnX, $HushenGGBtnY, 2)
	  Sleep($clickSleep)
	  MouseClick("left", $DDEBtnX, $DDEBtnY, 2)
   Else
	  Send($shortcut)
	  Send("{ENTER}")
   EndIf
   Sleep($clickSleep)

   ; give it $refeshsec seconds to refresh data
   Sleep($refeshsec*1000)

   ; bring up the context menu
   MouseMove($lstX, $lstY, 2)

   ; prevent click on the adv dlg
   CloseAdvDlgIfAny()
   MouseClick("right")

   ; start the export dialog
   AutoItSetOption("SendKeyDelay", $keyspeed_menu)
   Send("{DOWN " & $exportpos & "}{RIGHT 1}{ENTER}")

   ; give app time to show the dlg
   Sleep($exportdlg_check_delay_ms)

   ; tab to the file name editor
   Send("{TAB 2}")

   ; check and return the hwnd of the dialog
   $hDlg = GetExportDlg()
   ;Trace("[Info] Export dialog is opend with $hDlg=" & $hDlg )
   return $hDlg

EndFunc

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
   ; @HOUR@MIN [$AMStart, $AMEnd] & [$PMStart, $PMEnd]
   IF $wday >= 2 And $wday <= 6 Then
	  ; AM and PM
	  IF StringCompare($time, $AMStart) >= 0 and StringCompare($time, $AMEnd) <= 0 Then
		 ConsoleWrite("wday " & $wday & " time " & $time & " return True" & @CRLF)
		 return True
	  ElseIf StringCompare($time, $PMStart) >= 0 and StringCompare($time, $PMEnd) <= 0 Then
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
   IF AllowRunning(3, "09:24:59") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf


   ; True
   IF NOT AllowRunning(3, "09:25:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "09:30:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "09:30:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "10:34:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "11:08:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "11:29:59") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "11:30:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF Not AllowRunning(3, "11:32:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

   ; False
   IF AllowRunning(1, "09:30:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(1, "09:30:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(7, "10:34:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(7, "11:08:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(7, "11:29:59") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(7, "11:30:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

   ; Fase
   IF AllowRunning(2, "11:32:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
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
   IF Not AllowRunning(5, "15:02:00") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

   ; Fase
   IF AllowRunning(5, "15:02:01") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf
   IF AllowRunning(5, "16:20:44") Then MsgBox($MB_SYSTEMMODAL, "Error", $info) EndIf

EndFunc




Func Open($dfcfexe, $dfcfpname, $opendelaysec)
   ; Open the Process
   Trace("Open dfcf Process ...")
   Local $try = 0
   Local $iPID = Run($dfcfexe, "", @SW_SHOWMAXIMIZED)
   while ((ProcessExists($dfcfpname) == 0  And $try < $TIMEOUT))
	  $try += 1
	  Sleep(1*1000)
   WEnd

   If ProcessExists($dfcfpname) == 0 Then
	  MsgBox($MB_SYSTEMMODAL, "", "Cannot start " &  $dfcfpname & ". Please check DfcfPorcName value in you config.ini file.")
	  return $iPID
   EndIf

   ; Sleep until logon
   CountDown($opendelaysec, " Wait Open")

   Trace("Close adv dlg if any...")
   Local $i = 0
   While $i < 5
	  CloseAdvDlgIfAny()
	  $i+=1
   WEnd
   Return $iPID
EndFunc


; Close the Process
Func Close($dfcfpname)
   Local	 $try = 0
   Trace("Close dfcf Process ...")
   while ((ProcessExists($dfcfpname) <> 0  And $try < $TIMEOUT))
	  ProcessClose($dfcfpname)
	  $try += 1
	  Sleep(1000)
   WEnd
EndFunc

Func GetSaveDlg()

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
   Local $logmsg = "" & $now & " " & $message;
   ConsoleWrite($logmsg & @CRLF)

   ; write to file as well
   Local $logFile = ".\traceviewer.log"

;~    Local $hFileOpen FileOpen($logFile,  $FO_APPEND )

;~    If $hFileOpen = -1 Then
;~       ConsoleWrite("An error occurred when open log file " & $logFile )
;~    EndIf

   FileWriteLine($logFile,$logmsg)
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