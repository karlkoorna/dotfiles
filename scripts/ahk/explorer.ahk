RemoveToolTip() {
	ToolTip
}

DecodeURL(url) {
	doc := ComObjCreate("HTMLfile")
	doc.write("<script>document.write(decodeURIComponent('" . url . "'));</script>")
	return doc.body.innerText
}

ExplorerPath() {
	HWnd := WinExist("A")
	for window in ComObjCreate("Shell.Application").Windows
		if (window.HWnd == HWnd) {
			path := window.LocationURL
			Break
		}
	return DecodeURL(SubStr(path, 9))
}

; CTRL+T -- Open Git Bash or WSL from File Explorer.
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
