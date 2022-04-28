dialog := 0

;;; Utils

RemoveToolTip() {
	ToolTip
}

Notify(str, delay) {
	ToolTip % str
	SetTimer RemoveToolTip, %delay%
}

GetAddress() {
	WinGetText texts
	RegExMatch(texts, "Address: (.*)", address)
	return RegExMatch(SubStr(address, 10), "^[A-Z]:\\") ? SubStr(address, 10) : USERPROFILE . "\" . SubStr(address, 10)
}

OpenTerminal(path) {
	SetWorkingDir % GetAddress()
	Run % path
	SetWorkingDir % A_ScriptDir
}

;;; Handlers

HandleEverythingDialog(withFile) {
	global dialog
	
	if (dialog = 0) {
		return
	}
	
	ControlGet, row, List, Selected, SysListView321
	columns := StrSplit(row, "`t")
	path := columns[2]
	if withFile {
		path .= "\" . columns[1]
	}
	
	ControlSetText, Edit1, %path%, ahk_id %dialog%
	ControlSend, Edit1, {Enter}, ahk_id %dialog%
	WinClose
	dialog := 0
}

;;; Hotkeys

; CTRL+ALT+F -- Toggle window always on top.
^!f::
	Winset AlwaysOnTop, Toggle, A
	WinGet ExStyle, ExStyle, A
	Notify(ExStyle & 0x8 ? "Marked" : "Unmarked", 500)
	return

; CTRL+T -- Open Git Bash from File Explorer.
#IfWinActive ahk_class CabinetWClass
^t::
#IfWinActive ahk_class #32770
^t::
	OpenTerminal("C:/Program Files/Git/git-bash.exe")
	return
#IfWinActive

; CTRL+SHIFT+T -- Open WSL from File Explorer.
#IfWinActive ahk_class CabinetWClass
^+t::
#IfWinActive ahk_class #32770
^+t::
	OpenTerminal("bash")
	return
#IfWinActive

; CTRL+ALT+T -- Open PowerShell from File Explorer.
#IfWinActive ahk_class CabinetWClass
^!t::
#IfWinActive ahk_class #32770
^!t::
	OpenTerminal("powershell")
	return
#IfWinActive

; WIN+F -- Open Everything from File Explorer.
#IfWinActive ahk_class CabinetWClass
#f::
	path := GetAddress()
	Run "C:/Program Files/Everything/Everything.exe" -p "%path%"
	return
#IfWinActive

; WIN+F -- Open Everything from File Explorer dialog.
#IfWinActive ahk_class #32770
#f::
	WinGet, dialog
	path := GetAddress()
	Run "C:/Program Files/Everything/Everything.exe" -p "%path%"
	return
#IfWinActive

; SHIFT+S -- Send folder path from Everything to File Explorer dialog and close Everything.
#IfWinActive ahk_class EVERYTHING
+s::
	HandleEverythingDialog(false)
	return
#IfWinActive

; ALT+S -- Send file path from Everything to File Explorer dialog and close Everything.
#IfWinActive ahk_class EVERYTHING
!s::
	HandleEverythingDialog(true)
	return
#IfWinActive

; WIN+F -- Open Everything.
#f::
	Run "C:/Program Files/Everything/Everything.exe"
	return

; WIN+C -- Open Qalculate.
#c::
	Run "C:/Program Files/Qalculate/qalculate.exe"
	return

; ESC -- Close Qalculate.
#IfWinActive Qalculate
Escape::
	WinClose
	return
#IfWinActive
