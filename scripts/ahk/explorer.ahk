#Requires AutoHotkey v2

Unnotify() {
	ToolTip()
}

Notify(str, delay) {
	ToolTip(str)
	SetTimer(Unnotify, delay)
}

GetExplorerAddress() {
	address := SubStr(ControlGetText("ToolbarWindow324"), 10)
	if (InStr(address, "\")) {
		return address
	}

	return EnvGet("USERPROFILE") . "/" . address
}

OpenTerminal(profile, path) {
	Run(Format("{1}/Microsoft/WindowsApps/wt.exe new-tab -p `"{2}`" -d .", EnvGet("LOCALAPPDATA"), profile), path)
}

; When File Explorer or File Dialog is active then...
#HotIf WinActive("ahk_class CabinetWClass") or WinActive("ahk_class #32770")

; [CTRL+T] Open Git Bash.
^t:: {
	OpenTerminal("Git Bash", GetExplorerAddress())
}

; [CTRL+SHIFT+T] Open WSL.
^+t:: {
	OpenTerminal("Ubuntu", GetExplorerAddress())
}

; [CTRL+ALT+T] Open PowerShell.
^!t:: {
	OpenTerminal("PowerShell", GetExplorerAddress())
}

; [WIN+F] Open Everything.
#f:: {
	Run(Format("`"C:/Program Files/Everything/Everything.exe`" -p `"`"{1}`"`"", GetExplorerAddress()))
}

#HotIf

; [CTRL+ALT+F] Toggle window always on top.
^!f:: {
	WinSetAlwaysOnTop(-1, "A")
	Notify(WinGetExStyle("A") & 0x08 ? "Marked" : "Unmarked", 500)
}

; [WIN+F] Open Everything.
#f:: {
	Run("C:/Program Files/Everything/Everything.exe")
}

; [WIN+C] Open Qalculate.
#c:: {
	Run("C:/Program Files/Qalculate/qalculate.exe",,, &pid)
	WinWait("ahk_pid " pid)
	WinActivate("ahk_pid " pid)
}

; Close Qalculate with escape.
#HotIf WinActive("Qalculate")
Escape:: WinClose("A")
#HotIf
