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
	ClipWait 1
	new := Clipboard
	Clipboard := old
	ClipWait 1
	Send ^v
	ClipWait 1
	Clipboard := new
	return

; CTRL+ALT+X -- Delete selection without copying to clipboard.
^!x::
	Send {BS}
	return

; CTRL+ALT+D -- Display length of selection.
^!d::
	old := Clipboard
	Send ^c
	ClipWait 1
	Notify(StrLen(Clipboard), 3000)
	Clipboard := old
	return

; CTRL+ALT+G -- Google search selection.
^!g::
	old := Clipboard
	Send ^c
	ClipWait 1
	Clipboard := old
	Run "https://google.com/search?q=%clipboard%"
	return

; CTRL+ALT+E -- Copy public IP to clipboard.
^!e::
	ip := "0.0.0.0"
	tmp := WinDir . "/temp/ip.tmp"
	UrlDownloadToFile https://checkip.amazonaws.com, % tmp
	FileReadLine ip, % tmp, 1
	FileDelete % tmp
	Clipboard := ip
	Notify("Copied", 500)
	return

; CTRL+ALT+B -- Paste clipboard with encoded links.
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
	ClipWait 1
	Send ^v
	ClipWait 1
	Clipboard := old
	return
