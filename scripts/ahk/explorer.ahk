;;; Utils

Unnotify() {
	ToolTip
}

Notify(str, delay) {
	ToolTip % str
	SetTimer Unnotify, %delay%
}

GetExplorerAddress() {
	WinGetText texts
	RegExMatch(texts, "Address: (.*)", address)

	if (RegExMatch(SubStr(address, 10), "^[A-Z]:\\")) { ; Absolute path
		return SubStr(address, 10)
	} else { ; Quick Access path
		return USERPROFILE . "\" . SubStr(address, 10)
	}
}

OpenTerminal(profile, path) {
	Run % LOCALAPPDATA . "/Microsoft/WindowsApps/wt.exe new-tab -d . -p """ . profile . """", path
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
	OpenTerminal("Git Bash", GetExplorerAddress())
	return
#IfWinActive

; CTRL+SHIFT+T -- Open WSL from File Explorer.
#IfWinActive ahk_class CabinetWClass
^+t::
#IfWinActive ahk_class #32770
^+t::
	OpenTerminal("Ubuntu", GetExplorerAddress())
	return
#IfWinActive

; CTRL+ALT+T -- Open PowerShell from File Explorer.
#IfWinActive ahk_class CabinetWClass
^!t::
#IfWinActive ahk_class #32770
^!t::
	OpenTerminal("PowerShell", GetExplorerAddress())
	return
#IfWinActive

; WIN+F -- Open Everything from File Explorer window or dialog.
#IfWinActive ahk_class CabinetWClass
#f::
#IfWinActive ahk_class #32770
#f::
	Run % """C:/Program Files/Everything/Everything.exe"" -p """ . GetExplorerAddress() . """"
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
