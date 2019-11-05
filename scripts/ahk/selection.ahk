RemoveToolTip:
ToolTip
return

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
SetTimer, RemoveToolTip, 5000
return
