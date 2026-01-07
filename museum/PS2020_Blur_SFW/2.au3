HotKeySet("{ESC}", "Terminate")
HotKeySet("{NUMPADADD}", "DoIt")
AutoItSetOption("WinTitleMatchMode",2)
AutoItSetOption("ExpandVarStrings",1)

Beep(500, 100)

While 1
        Sleep(100)
WEnd

Func Terminate()
        Exit
EndFunc

Func DoIt()
Beep(500, 1000)

$q=50

For $q = 1 To 100


; Open image
Send("!+^O")
Sleep(1000)
Send("Z:\JPEG-DCT-toys\ref\R0.png{ENTER}")

; change mode to RGB
MouseClick("left",120,15)
MouseClick("left",124,34)
MouseClick("left",395,106)


; Fix image (if any need)
MouseClick("left",117,11)
MouseClick("left",115,60)
MouseClick("left",415,330)
WinWaitActive("Threshold")
Send("{ENTER}");


; Resize image to 80x80 pixels, nearest mode
Send("!^i") ; ALT+CTRL+I
WinWaitActive("Image Size")
Send("80{TAB}{TAB}80{TAB}{TAB}!6{ENTER}");

; Apply gaussian blur
MouseClick("left",288,12)
MouseClick("left",288,235)
MouseClick("left",617,312)
Local $blur=$q/3.0
Send("$blur${ENTER}")

; Resize image to 8x8 pixels, bilinear mode
Send("!^i") ; ALT+CTRL+I
WinWaitActive("Image Size")
Send("8{TAB}{TAB}8{TAB}{TAB}!7{ENTER}");

; Save image to Museum
Send("!+^S")
WinWaitActive("Save for Web")
Sleep(100)
MouseClick("left",1450,226)
MouseClick("left",1450,226)
Sleep(100)
Send("100{ENTER}")
Send("{ENTER}")
WinWaitActive("Save Optimized As")
Send("z:\museum\$q$.jpg{ENTER}")
Sleep(1000)

; Close current document
Send("^w")
Sleep(1000)
Send("!n")

Sleep(1000)


Next


EndFunc
