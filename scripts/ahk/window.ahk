CoordMode Mouse, Screen
SetMouseDelay 0
SetWinDelay 0

IsWinApplicable(win_id) {
	WinGetClass win_class, ahk_id %win_id%
	if (win_class = "WorkerW" or win_class = "Windows.UI.Core.CoreWindow" or win_class = "MultitaskingViewFrame" or win_class = "Shell_InputSwitchTopLevelWindow" or win_class = "NotifyIconOverflowWindow") {
		return false
	}
	
	WinGet win_minmax, MinMax, ahk_id %win_id%
	if (win_minmax != 0) {
		return false
	}
	
	return true
}

; ALT+LMOUSE -- Move window from cursor location.
!LButton::
	MouseGetPos start_x, start_y, win_id
	
	if !IsWinApplicable(win_id) {
		Send !{LButton}
		return
	}
	
	WinActivate ahk_id %win_id%
	WinGetPos win_x, win_y, win_w, win_h, ahk_id %win_id%
	WinRestore ahk_id %win_id%
	WinMove ahk_id %win_id%,, %win_x%, %win_y%, %win_w%, %win_h%
	
	x := win_x + win_w * .8
	y := win_y + 12
	Click down, %x%, %y%
	
	WinGetPos win_x, win_y,,, ahk_id %win_id%
	offset_x := start_x - win_x
	offset_y := start_y - win_y
	
	loop {
		if GetKeyState("LButton", "P") {
			continue
		}
		
		Click up
		WinGetPos win_x, win_y, win_w, win_h, ahk_id %win_id%
		x := win_x + offset_x
		y := win_y + offset_y
		MouseMove %x%, %y%
		break
	}
	return

; ALT+RMOUSE -- Resize window from cursor location.
!RButton::
	MouseGetPos start_x, start_y, win_id

	if !IsWinApplicable(win_id) {
		Send !{RButton}
		return
	}
	
	WinActivate ahk_id %win_id%
	WinGetPos win_x, win_y, win_w, win_h, ahk_id %win_id%
	WinRestore ahk_id %win_id%
	WinMove ahk_id %win_id%,, %win_x%, %win_y%, %win_w%, %win_h%
	
	WinGetPos win_x, win_y, win_w, win_h, ahk_id %win_id%
	hor := (start_x - win_x < win_w / 2) ? "left" : "right"
	ver := (start_y - win_y < win_h / 2) ? "up" : "down"
	
	loop {
		if !GetKeyState("ALT", "P") or !GetKeyState("RButton", "P") {
			break
		}
		
		MouseGetPos x, y
		
		if (x < start_x) {
			diff_x := start_x - x
			if (hor = "left") {
				win_x -= diff_x
				win_w += diff_x
			} else {
				win_w -= diff_x
			}
		} else {
			diff_x := x - start_x
			if (hor = "left") {
				win_w -= diff_x
				win_x += diff_x
			} else {
				win_w += diff_x
			}
		}
		
		start_x := x
		
		if (y < start_y) {
			diff_y := start_y - y
			if (ver = "up") {
				win_y -= diff_y
				win_h += diff_y
			} else {
				win_h -= diff_y
			}
		} else {
			diff_y := y - start_y
			if (ver = "up") {
				win_y += diff_y
				win_h -= diff_y
			} else {
				win_h += diff_y
			}
		}
		
		start_y := y
		
		WinMove ahk_id %win_id%,, %win_x%, %win_y%, %win_w%, %win_h%
	}
	return

; ALT+MMOUSE -- Close window on title bar click.
MButton::
	CoordMode Mouse, Relative
	MouseGetPos x, y, win_id
	
	if (y > 30) {
		SendInput {MButton}
		return
	}
	
	WinClose ahk_id %win_id%
	return
