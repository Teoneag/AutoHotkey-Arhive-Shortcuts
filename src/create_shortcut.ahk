; Ctrl + Shift + s: make shortcut from the selected file

#Requires AutoHotkey v2.0
#Include utils.ahk

^+s:: { ; Ctrl + Shift + s
    ; Exit the script if File Explorer is not active
    if !WinActive("ahk_class CabinetWClass") {
        return
    }

    ; Get the selected folder in the current active window in File Explorer
    selectedFile := GetSelectedFile()    

    if (selectedFile == ""|| !FileExist(selectedFile)) {
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