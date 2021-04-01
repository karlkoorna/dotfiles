RemoveToolTip() {
	ToolTip
}

Notify(str, delay) {
	ToolTip % str
	SetTimer RemoveToolTip, %delay%
}

; CTRL+ALT+V -- Switch selection and clipboard.
^!v::
	old := Clipboard
	Send ^c
	ClipWait 1000
	new := Clipboard
	Clipboard := old
	ClipWait 1000
	Send ^v
	ClipWait 1000
	Clipboard := new
	return

; CTRL+ALT+X -- Delete selection without copying to clipboard.
^!x::
	Send {BS}
	return

; CTRL+ALT+D -- Display selection info.
^!d::
	old := Clipboard
	Send ^c
	ClipWait 1000
	RegExReplace(Clipboard, "\b\S+\b", "", count, -1, 1)
	out := "Characters: " . StrLen(StrReplace(StrReplace(Clipboard, "`r"), "`n")) . "`n"
	out .= "Words: " . count . "`n"
	out .= "Lines: " . StrSplit(StrReplace(Clipboard, "`r"), "`n").maxindex()
	Notify(out, 3000)
	Clipboard := old
	return

; CTRL+ALT+A -- Copy public IP to clipboard.
^!a::
	ip := "0.0.0.0"
	tmp := WinDir . "/temp/ip.tmp"
	UrlDownloadToFile https://checkip.amazonaws.com, %tmp%
	FileReadLine ip, %tmp%, 1
	FileDelete % tmp
	Clipboard := ip
	Notify("Copied IP", 1000)
	return

; Automatically decode URIs in clipboard.
OnClipboardChange:
	if RegExMatch(Clipboard, "^https?:\/\/.*\/(.*)?(%[a-fA-F0-9]{2})+\S*$") {
		str := Clipboard
		DllCall("Shlwapi.dll\UrlUnescapeW", "Ptr", &str, "Ptr", 0, "UInt", 0, "UInt", 0x00140000, "UInt")
		Clipboard := StrReplace(str, " ", "%20")
	}
	return
