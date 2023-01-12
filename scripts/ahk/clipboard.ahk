#Requires AutoHotkey v2

Unnotify() {
	ToolTip()
}

Notify(str, delay) {
	ToolTip(str)
	SetTimer(Unnotify, delay)
}

ClipboardChanged(type) {
	if (RegExMatch(A_Clipboard, "^https?:\/\/\S+%[a-fA-F0-9]{2}\S+$")) {
		url := A_Clipboard
		DllCall("shlwapi\UrlUnescapeW", "Str", &url, "Ptr", 0, "Ptr", 0, "Int", 0x00140000, "Int")
		A_Clipboard := url
	}
}

OnClipboardChange ClipboardChanged

; [CTRL+ALT+V] Switch selection and clipboard.
^!v:: {
	old := A_Clipboard
	Send("^c")
	Sleep(100)
	new := A_Clipboard
	A_Clipboard := old
	Sleep(100)
	Send("^v")
	Sleep(100)
	A_Clipboard := new
	Send("{Ctrl down}")
}

; [CTRL+ALT+X] Delete selection without copying to clipboard.
^!x:: {
	Send("{BS}")
}

; [CTRL+ALT+D] Display selection info.
^!d:: {
	old := A_Clipboard
	Send("^c")
	Sleep(100)
	new := A_Clipboard
	RegExReplace(new, "\b\S+\b", "", &count)
	out := "Characters: " . StrLen(StrReplace(StrReplace(new, "`r"), "`n")) . "`n"
	out .= "Words: " . count . "`n"
	out .= "Lines: " . StrSplit(StrReplace(new, "`r"), "`n").Length
	Notify(out, 3000)
	A_Clipboard := old
}
