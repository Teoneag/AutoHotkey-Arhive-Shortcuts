; Ctrl + Shift + c: open selected folder with VS Code

#Requires AutoHotkey v2.0

^+c:: { ; Ctrl + Shift + c
    ; Exit the script if File Explorer is not active
    if !WinActive("ahk_class CabinetWClass") {
        return
    }

    ; Get the selected folder in the current active window in File Explorer
    selectedFile := ""
    for window in ComObject("Shell.Application").Windows {
        if window.hwnd = WinExist("A") {  ; Make sure it's the active window
            if window.Document.SelectedItems.Count > 0 {
                selectedFile := window.Document.SelectedItems.Item(0).Path
            } else {
                ; if no selected folder, get the current File Explorer path
                selectedFile := window.Document.folder.Self.Path
            }
            break  ; Exit the loop once we find the active window
        }
    }

    if (selectedFile != "") { ; if the path exists
        Run('cmd.exe /c code "' selectedFile '"',, "Hide")
    } else {
        MsgBox("No folder selected or unable to retrieve folder path.")
    }
}
