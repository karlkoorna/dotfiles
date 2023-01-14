#Requires AutoHotkey v2

CoordMode("Mouse", "Screen")
SetMouseDelay(10)
SetWinDelay(10)

Unnotify() {
	ToolTip()
}

Notify(str, delay) {
	ToolTip(str)
	SetTimer(Unnotify, delay)
}

IsWinSpecial(winId) {
	switch (WinGetClass("ahk_id " winId)) {
		case "Windows.UI.Core.CoreWindow", ; Notification Center
			 "MultitaskingViewFrame", ; Task Switcher
			 "Shell_InputSwitchTopLevelWindow", ; Language Switcher
			 "NotifyIconOverflowWindow": ; Tray icon overflow window
			return true
		default:
			return false
	}
}

/* Disabled if using AltSnap...

; [ALT+LMOUSE] Move a window from cursor location.
; [ALT+LMOUSE+LMOUSE] (Un)maximize a window.
; [CTRL+ALT+LMOUSE] Move a window from cursor location and activate it.
; [CTRL+ALT+LMOUSE+LMOUSE] (Un)maximize a window and activate it.
!LButton::
!^LButton:: {
	MouseGetPos(&mouseX, &mouseY, &winId)
	if (IsWinSpecial(winId)) {
		return
	}

	if (A_TimeSincePriorHotkey != "" && A_TimeSincePriorHotkey < 200) {
		if (WinGetMinMax("ahk_id " winId) == 0) {
			WinMaximize("ahk_id " winId)
		} else {
			WinRestore("ahk_id " winId)
		}

		return
	}

	if !GetKeyState("Control") {
		WinActivate("ahk_id " winId)
	}

	if WinGetMinMax("ahk_id " winId) != 0 {
		return
	}

	WinGetPos(&winX, &winY,,, "ahk_id " winId)
	offsetX := mouseX - winX
	offsetY := mouseY - winY

	loop {
		if (!GetKeyState("Alt", "P") or !GetKeyState("LButton", "P")) {
			break
		}

		MouseGetPos(&mouseX, &mouseY)
		WinMove(mouseX - offsetX, mouseY - offsetY,,, "ahk_id " winId)
	}
}

; [ALT+RMOUSE] Resize a window from cursor location.
!RButton:: {
	MouseGetPos(&mouseX, &mouseY, &winId)
	if (IsWinSpecial(winId)) {
		return
	}

	if (WinGetMinMax("ahk_id " winId) != 0) {
		WinRestore("ahk_id " winId)
		Sleep(180)
	}

	WinGetPos(&winX, &winY, &winW, &winH, "ahk_id " winId)
	isLeft := mouseX - winX < winW / 2
	isUp := mouseY - winY < winH / 2

	MouseGetPos(&startX, &startY)

	loop {
		if (!GetKeyState("Alt", "P") or !GetKeyState("RButton", "P")) {
			break
		}

		MouseGetPos(&mouseX, &mouseY)

		if (mouseX < startX) {
			diffX := startX - mouseX
			if (isLeft) {
				winX -= diffX
				winW += diffX
			} else {
				winW -= diffX
			}
		} else {
			diffX := mouseX - startX
			if (isLeft) {
				winW -= diffX
				winX += diffX
			} else {
				winW += diffX
			}
		}

		startX := mouseX

		if (mouseY < startY) {
			diffY := startY - mouseY
			if (isUp) {
				winY -= diffY
				winH += diffY
			} else {
				winH -= diffY
			}
		} else {
			diffY := mouseY - startY
			if (isUp) {
				winY += diffY
				winH -= diffY
			} else {
				winH += diffY
			}
		}

		startY := mouseY

		WinMove(winX, winY, winW, winH, "ahk_id " winId)
	}
}

; When Photoshop is not active...
#HotIf !WinActive("ahk_class Photoshop")

; [ALT+WHEELUP] Maximize a window.
!WheelUp:: {
	MouseGetPos(,, &winId)
	if (IsWinSpecial(winId)) {
		return
	}

	if (A_TimeSincePriorHotkey != "" && A_TimeSincePriorHotkey < 200) {
		return
	}

	WinMaximize("ahk_id " winId)
}

; [ALT+WHEELDOWN] Minimize or restore a window.
!WheelDown:: {
	MouseGetPos(,, &winId)
	if (IsWinSpecial(winId)) {
		return
	}

	if (A_TimeSincePriorHotkey != "" && A_TimeSincePriorHotkey < 200) {
		return
	}

	if (WinGetMinMax("ahk_id " winId) == 0) {
		WinMinimize("ahk_id " winId)
	} else {
		WinRestore("ahk_id " winId)
	}
}

#HotIf

*/

; [MMOUSE] Close a window by middle-clicking the title bar.
MButton:: {
	MouseGetPos(,, &winId)
	WinClose("ahk_id " winId)
}

; [CTRL+ALT+F] Toggle window always on top.
^!f:: {
	WinSetAlwaysOnTop(-1, "A")
	Notify(WinGetExStyle("A") & 0x08 ? "Marked" : "Unmarked", 500)
}
