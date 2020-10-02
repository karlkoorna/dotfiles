RemoveToolTip() {
	ToolTip
}

Notify(str, delay) {
	ToolTip % str
	SetTimer RemoveToolTip, % delay
}

EncodeB64(str) {
	VarSetCapacity(bin, StrPut(str, "UTF-8"))
	len := StrPut(str, &bin, "UTF-8") - 1
	DllCall("Crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x40000001, "ptr", 0, "uint*", size)
	VarSetCapacity(buf, size << 1, 0)
	DllCall("Crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x40000001, "ptr", &buf, "uint*", size)
	return StrGet(&buf)
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
	UrlDownloadToFile https://checkip.amazonaws.com, % tmp
	FileReadLine ip, % tmp, 1
	FileDelete % tmp
	Clipboard := ip
	Notify("Copied", 1000)
	return

; CTRL+ALT+B -- Paste clipboard with base64 encoded links.
^!b::
	out := ""
	index := 1
	offset := 1
	while index := RegExMatch(Clipboard, "O)(https?://)\S*", match, offset) {
		out .= SubStr(Clipboard, offset, index - offset)
		out .= RegExMatch(match.0, "(mega(\.co)?\.nz|mediafire\.com|drive\.google\.|onedrive\.live|sharepoint\.com|nyaa\.si|rutracker\.org)") ? EncodeB64(match.0) : match.0
		offset := index + match.Len
	}
	old := Clipboard
	Clipboard := out . SubStr(Clipboard, offset)
	ClipWait 1000
	Send ^v
	ClipWait 1000
	Clipboard := old
	return
