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
For $q = 0 To 100
Send("!+^S")
WinWaitActive("Save for Web")
Sleep(100)
MouseClick("left",1450,226)
MouseClick("left",1450,226)
Sleep(100)
Send("$q${ENTER}")
Send("{ENTER}")
WinWaitActive("Save Optimized As")
Send("z:\museum\$q$.jpg{ENTER}")
Sleep(1000)
Next


EndFunc
