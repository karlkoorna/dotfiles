RemoveToolTip() {
	ToolTip
}

Notify(msg, delay) {
	ToolTip % msg
	SetTimer RemoveToolTip, % delay
}

DecodeURL(str) {
	loop {
		if RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex) {
			StringReplace, str, str, `%%hex%, % Chr("0x" . hex), ALL
		} else break
	}
	return str
}

ExplorerPath() {
	HWnd := WinExist("A")
	for window in ComObjCreate("Shell.Application").Windows {
		if (window.HWnd == HWnd) {
			path := window.LocationURL
			Break
		}
	}
	return DecodeURL(SubStr(path, 9))
}

; CTRL+T -- Open Git Bash, WSL or PowerShell from File Explorer.
#IfWinActive ahk_class CabinetWClass
^t::
	SetWorkingDir % ExplorerPath()
	Run "C:/Program Files/Git/git-bash.exe"
	SetWorkingDir % A_ScriptDir
	return
^+t::
	SetWorkingDir % ExplorerPath()
	Run bash
	SetWorkingDir % A_ScriptDir
	return
^!t::
	SetWorkingDir % ExplorerPath()
	Run powershell
	SetWorkingDir % A_ScriptDir
	return
#IfWinActive

; CTRL+ALT+F -- Toggle window always on top.
^!f::
	Winset AlwaysOnTop, Toggle, A
	WinGet ExStyle, ExStyle, A
	Notify(ExStyle & 0x8 ? "Marked" : "Unmarked", 500)
	return
