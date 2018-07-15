#Persistent
OnClipboardChange("Replace")

Replace() {
	
	FileRead, config, Clipboard.txt
	rules := []
	
	; Strip comments and empty lines.
	for key, value in StrSplit(config, "`n") {
		if SubStr(value, 1, 1) != "#" && StrLen(value) != 0 {
			rules.Push(value)
		}
	}
	
	; Replace clipboard contents.
	x := 1
	while x < rules.MaxIndex() {
		Clipboard := RegExReplace(Clipboard, rules[x], rules[x + 1])
		x += 2
		Sleep, 20
	}
	
}
