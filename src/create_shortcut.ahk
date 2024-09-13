; Ctrl + Shift + s: make shortcut from the selected file

#Requires AutoHotkey v2.0

^+s:: { ; Ctrl + Shift + s
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
            }
            break  ; Exit the loop once we find the active window
        }
    }

    if (selectedFile == "") {
        MsgBox("No file selected. Please select a file to create a shortcut.")
        return
    }

    parentFolder := RegExReplace(selectedFile, "\\[^\\]*$")

    ; Define the shortcut path (same folder as the selected file)
    shortcutPath := selectedFile . ".lnk"

    ; Create the shortcut
    shortcut := ComObject("WScript.Shell").CreateShortcut(shortcutPath)
    shortcut.TargetPath := selectedFile
    shortcut.WorkingDirectory := parentFolder
    shortcut.Save()
}
