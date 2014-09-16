#include <MsgBoxConstants.au3>

Example()


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

Func Example()
    ; Run Notepad
    ;Run("notepad.exe")

    ; get export dlg hWnd
    Local $hWnd = GetExportDlg()

    ; Retrieve the text of the edit control in export dlg
    Local $sText = ControlGetText($hWnd, "", "Edit1")
    ;MsgBox($MB_SYSTEMMODAL, "", "The text in Edit1 is: " & $sText)
   If not StringInStr($sText, "Table.xls") Then
	  Trace("Cannot find the file name string in this export dlg")
	  _ScreenCapture_Capture()
	  ; retry logic to get the
	  ;ActiveTheDlg again
	  ;Click the 上一步 button ClassnameNN = Button4 until it is disalbed
	  ; try to get the Edit1 control again.

   EndIf

    ; Set the edit control in export dlg
    ControlSetText($hWnd, "", "Edit1", "This is some text")
    Local $sText = ControlGetText($hWnd, "", "Edit1")
    MsgBox($MB_SYSTEMMODAL, "", "The text in Edit1 is: " & $sText)

    ; Close the Notepad window using the handle returned by WinWait.
    ;WinClose($hWnd)
EndFunc   ;==>Example

