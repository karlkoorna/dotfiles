RemoveToolTip() {
	ToolTip
}

ExplorerPath() {
	hwnd := WinExist("A")
	for window in ComObjCreate("Shell.Application").Windows
		if (window.hwnd == hwnd) itemPath := window.Document.FocusedItem.path
	SplitPath, itemPath,, path
	return path
}

; CTRL+T -- Open bash terminals from File Explorer.
#IfWinActive ahk_class CabinetWClass
^t::
SetWorkingDir, % ExplorerPath()
Run, C:/Program Files/Git/git-bash.exe
return
^+t::
SetWorkingDir, % ExplorerPath()
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
