RemoveToolTip() {
	ToolTip
}

ExplorerPath() {
	HWnd := WinExist("A")
	for window in ComObjCreate("Shell.Application").Windows
		if (window.HWnd == HWnd) {
			path := window.LocationURL
			Break
		}
	return StrReplace(SubStr(path, 9), "%20", " ")
}

; CTRL+T -- Open Git Bash and WSL from File Explorer.
#IfWinActive ahk_class CabinetWClass
^t::
SetWorkingDir, % ExplorerPath()
Run, C:/Program Files/Git/git-bash.exe
SetWorkingDir, % A_ScriptDir
return
^+t::
path := ExplorerPath()
SetWorkingDir, % path
Run, bash, % path
SetWorkingDir, % A_ScriptDir
return
#IfWinActive

; CTRL+ALT+F -- Toggle window always on top.
^!f::
Winset, AlwaysOnTop, Toggle, A
WinGet, ExStyle, ExStyle, A
ToolTip, % ExStyle & 0x8 ? "Marked" : "Unmarked"
SetTimer, RemoveToolTip, 500
return
