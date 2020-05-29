RemoveToolTip() {
	ToolTip
}

Notify(str, delay) {
	ToolTip % str
	SetTimer RemoveToolTip, % delay
}

ExplorerAddress() {
	WinGetText texts
	RegExMatch(texts, "Address: (.*)", address)
	return RegExMatch(SubStr(address, 10), "^\w:\\", b) ? SubStr(address, 10) : USERPROFILE . "\" . SubStr(address, 10)
}

ExplorerTerminal(executable) {
	SetWorkingDir % ExplorerAddress()
	Run % executable
	SetWorkingDir % A_ScriptDir
}

; CTRL+T -- Open Git Bash from File Explorer.
#IfWinActive ahk_class CabinetWClass
^t::
#IfWinActive ahk_class #32770
^t::
	ExplorerTerminal("C:/Program Files/Git/git-bash.exe")
	return
#IfWinActive

; CTRL+SHIFT+T -- Open WSL from File Explorer.
#IfWinActive ahk_class CabinetWClass
^+t::
#IfWinActive ahk_class #32770
^+t::
	ExplorerTerminal("bash")
	return
#IfWinActive

; CTRL+ALT+T -- Open Powershell from File Explorer.
#IfWinActive ahk_class CabinetWClass
^!t::
#IfWinActive ahk_class #32770
^!t::
	ExplorerTerminal("powershell")
	return
#IfWinActive

; CTRL+F -- Open Everything from File Explorer.
#IfWinActive ahk_class CabinetWClass
^f::
	address := ExplorerAddress()
	Run "C:/Program Files/Everything/Everything.exe" -path "%address%"
	return

; WIN+F -- Open Everything.
#f::
	Run "C:/Program Files/Everything/Everything.exe"
	return

; CTRL+ALT+F -- Toggle window always on top.
^!f::
	Winset AlwaysOnTop, Toggle, A
	WinGet ExStyle, ExStyle, A
	Notify(ExStyle & 0x8 ? "Marked" : "Unmarked", 500)
	return
