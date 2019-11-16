; Remove tooltip.
RemoveToolTip() {
	ToolTip
}

; Return active File Explorer's path.
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
