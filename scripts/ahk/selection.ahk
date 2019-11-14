; Remove tooltip.
RemoveToolTip() {
	ToolTip
}

; CTRL+ALT+X -- Delete selection without copying to clipboard.
^!x::
Send {BS}
return

; CTRL+ALT+V -- Switch selection and clipboard.
^!v::
old := ClipboardAll
Send ^c
ClipWait, 1
new := ClipboardAll
Clipboard := old
ClipWait, 1
Send ^v
Clipboard := new
return

; CTRL+ALT+D -- Display length of selection.
^!d::
Send ^c
ClipWait, 1
ToolTip, % StrLen(Clipboard)
SetTimer, RemoveToolTip, 3000
return

; CTRL+ALT+G -- Google search selection.
^!g::
old := ClipboardAll
Send ^c
ClipWait, 1
Run "https://google.com/search?q=%clipboard%"
Clipboard := old
return

; CTRL+ALT+E -- Copy public IP to clipboard.
^!e::
ip := 0.0.0.0
tmp := WinDir . "/temp/ip.tmp"
UrlDownloadToFile, https://checkip.amazonaws.com, % tmp
FileReadLine, ip, % tmp, 1
FileDelete, % tmp
Clipboard := ip
ToolTip, Copied
SetTimer, RemoveToolTip, 500
return
