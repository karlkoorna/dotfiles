#Requires AutoHotkey v2

Unnotify() {
	ToolTip()
}

Notify(str, delay) {
	ToolTip(str)
	SetTimer(Unnotify, delay)
}

GetExplorerAddress() {
	address := WinGetTitle()
	if (address == "Home") {
		return EnvGet("USERPROFILE")
	}
	if (!InStr(address, "\")) {
		return EnvGet("USERPROFILE") . "/" . address
	}

	return address
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

; When Qalculate is active then...
#HotIf WinActive("Qalculate")

; Close with escape.
Escape:: {
	WinClose("A")
}

#HotIf
