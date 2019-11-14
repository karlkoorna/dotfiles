; Remove tooltip.
RemoveToolTip() {
	ToolTip
}

; Return active File Explorer's path.
ExplorerPath() {
	hwnd := WinExist("A")
	for window in ComObjCreate("Shell.Application").Windows
		if (window.hwnd == hwnd) return window.Document.Folder.Self.Path
	return
}

; CTRL+T -- Open bash terminals from File Explorer.
#IfWinActive ahk_class CabinetWClass
^t::
Run, C:\Program Files\Git\git-bash.exe, % ExplorerPath()
return
^+t::
Run, bash, % ExplorerPath()
return
#IfWinActive

; CTRL+ALT+F -- Toggle window always on top.
^!f::
Winset, AlwaysOnTop, Toggle, A
WinGet, ExStyle, ExStyle, A
ToolTip, % ExStyle & 0x8 ? "Marked" : "Unmarked"
SetTimer, RemoveToolTip, 500
return
