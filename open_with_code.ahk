; Ctrl + Shift + c: open selected folder with VS Code

#Requires AutoHotkey v2.0

^+c:: { ; Ctrl + Shift + c
    ; Exit the script if File Explorer is not active
    if !WinActive("ahk_class CabinetWClass") {
        return
    }

    ; Get the current explorer path
    explorerPath := ""
    for window in ComObject("Shell.Application").Windows {
        if window.Document.Folder.Self.Path {
            explorerPath := window.Document.Folder.Self.Path
        }
    }

    if (explorerPath) { ; if the path exists
        Run('cmd.exe /c code "' explorerPath '"',, "Hide")
    } else {
        MsgBox("No folder selected or unable to retrieve folder path.")
    }
}
