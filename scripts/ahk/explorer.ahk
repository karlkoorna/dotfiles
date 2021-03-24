RemoveToolTip() {
	ToolTip
}

Notify(str, delay) {
	ToolTip % str
	SetTimer RemoveToolTip, % delay
}

GetAddress() {
	WinGetText texts
	RegExMatch(texts, "Address: (.*)", address)
	Notify(address, 2000)
	return RegExMatch(SubStr(address, 10), "^[A-Z]:\\") ? SubStr(address, 10) : USERPROFILE . "\" . SubStr(address, 10)
}

OpenTerminal(path) {
	SetWorkingDir % GetAddress()
	Run % path
	SetWorkingDir % A_ScriptDir
}

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
#IfWinActive ahk_class #32770
#f::
	path := ExplorerAddress()
	Run "C:/Program Files/Everything/Everything.exe" -p "%path%"
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
