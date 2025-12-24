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
;$q=5
Send("+^E")
Sleep(1000)
Send("^a{DEL}z:\museum\$q$.jpg{ENTER}")
WinWaitActive("JPEG")
MouseClick("left",1197,355)
Send("^a$q$")

MouseClick("left",1095,777)
Sleep(1000)
Next


EndFunc
