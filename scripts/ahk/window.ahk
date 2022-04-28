CoordMode Mouse, Screen
SetMouseDelay 10
SetWinDelay 10

;;; Utils

IsWinSpecial(win_id) {
	WinGetClass win_class, ahk_id %win_id%
	if (win_class = "WorkerW"
		or win_class = "Windows.UI.Core.CoreWindow"
		or win_class = "MultitaskingViewFrame"
		or win_class = "Shell_InputSwitchTopLevelWindow"
		or win_class = "NotifyIconOverflowWindow") {
		return true
	}
	
	return false
}

IsWinFloating(win_id) {
	WinGet win_minmax, MinMax, ahk_id %win_id%
	return win_minmax == 0 ; If window is not minimized or maximized.
}

;;; Handlers

HandleLeftAction(activate) {
	MouseGetPos start_mx, start_my, win_id
	if IsWinSpecial(win_id) {
		return
	}
	
	if (A_TimeSincePriorHotkey < 200 && A_TimeSincePriorHotkey <> -1) {
		if IsWinFloating(win_id) {
			WinMaximize ahk_id %win_id%
		} else {
			WinRestore ahk_id %win_id%
		}
		
		return
	}
	
	if activate {
		WinActivate ahk_id %win_id%
	}
	
	if !IsWinFloating(win_id) {
		return
	}
	
	WinGetPos start_wx, start_wy,,, ahk_id %win_id%
	offset_x := start_mx - start_wx
	offset_y := start_my - start_wy
	
	loop {
		if !GetKeyState("ALT", "P") or !GetKeyState("LButton", "P") {
			break
		}
		
		MouseGetPos x, y
		WinMove ahk_id %win_id%,, % x - offset_x, % y - offset_y
	}
}

HandleRightAction(activate) {
	MouseGetPos start_mx, start_my, win_id
	if IsWinSpecial(win_id) {
		return
	}
	
	if !IsWinFloating(win_id) {
		WinRestore ahk_id %win_id%
		Sleep 180
	}
	
	if activate {
		WinActivate ahk_id %win_id%
	}
	
	WinGetPos win_x, win_y, win_w, win_h, ahk_id %win_id%
	hor := (start_mx - win_x < win_w / 2) ? "left" : "right"
	ver := (start_my - win_y < win_h / 2) ? "up" : "down"
	
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
}

HandleMiddleAction(force) {
	MouseGetPos ,, y, win_id
	WinGetPos ,, win_y,,, ahk_id %win_id%
	
	if (!force && y - win_y > 30) {
		SendInput {MButton}
		return
	}
	
	WinClose ahk_id %win_id%
}

HandleWheelAction(dir) {
	MouseGetPos ,,, win_id
	if IsWinSpecial(win_id) {
		return
	}
	
	if (A_TimeSincePriorHotkey < 200 && A_TimeSincePriorHotkey <> -1) {
		return
	}
	
	if (dir = -1) { ; UP
		WinMaximize ahk_id %win_id%
	} else if (IsWinFloating(win_id)) { ; DOWN & FLOATING
		WinMinimize ahk_id %win_id%
	} else { ; DOWN & MAXIMIZED
		WinRestore ahk_id %win_id%
	}
}

;;; Hotkeys

; ALT+SCROLLLOCK -- Toggle functionality (for use in apps that have ALT+MOUSE functionality).
!ScrollLock:: Suspend

; ALT+LMOUSE -- Move a window from cursor location.
; ALT+LMOUSE+LMOUSE -- (Un)maximize a window.
!LButton:: HandleLeftAction(true)

; CTRL+ALT+LMOUSE -- Move a window from cursor location without activating it.
; CTRL+ALT+LMOUSE+LMOUSE -- (Un)maximize a window without activating it.
^!LButton:: HandleLeftAction(false)

; ALT+RMOUSE -- Resize a window from cursor location.
!RButton:: HandleRightAction(true)

; ALT+RMOUSE -- Resize a window from cursor location without activating it.
^!RButton:: HandleRightAction(false)

; MMOUSE -- Close a window by middle-clicking the title bar.
MButton:: HandleMiddleAction(false)

; ALT+MMOUSE -- Close a window.
!MButton:: HandleMiddleAction(true)

; ALT+WHEELUP -- Maximize a window.
!WheelUp:: HandleWheelAction(-1)

; ALT+WHEELDOWN -- Restore or minimize a window.
!WheelDown:: HandleWheelAction(1)
