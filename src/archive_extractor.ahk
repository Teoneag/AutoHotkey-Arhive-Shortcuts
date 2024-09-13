; Ctrl + e: Extract the selected zip

#Requires AutoHotkey v2.0
#Include utils.ahk

^e:: { ; Ctrl + e
    ; Exit the script if File Explorer is not active
    if !WinActive("ahk_class CabinetWClass") {
        return
    }

    shell := ComObject("Shell.Application")

    ; Get the selected file in the current active window in Explorer
    selectedFile := GetSelectedFile()

    if (selectedFile == "" || !FileExist(selectedFile) || !InStr(selectedFile, ".zip")) {
        MsgBox "Please select a valid ZIP archive."
        return
    }

    ; remove everything after the last \
    extractFolder := RegExReplace(selectedFile, "\\[^\\]*$")

    zipFolder := shell.NameSpace(selectedFile)
    extractDestination := shell.NameSpace(extractFolder)

    extractDestination.CopyHere(zipFolder.Items())

    FileDelete(selectedFile)
}