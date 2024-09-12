#Requires AutoHotkey v2

^e:: { ; Ctrl + e
    shell := ComObject("Shell.Application")
    
    ; Get the selected file in File Explorer
    selectedFile := ""
    for window in shell.Windows {
        if (window.hwnd == WinExist("ahk_class CabinetWClass")) {
            selectedItems := window.document.SelectedItems()
            if (selectedItems.Count > 0) {
                selectedFile := selectedItems.Item(0).Path
                break
            }
        }
    }

    if (selectedFile == "" || !FileExist(selectedFile) || !InStr(selectedFile, ".zip")) {
        MsgBox "Please select a valid ZIP archive."
        return
    }

    currentFolder := StrReplace(selectedFile, "\" . RegExReplace(selectedFile, ".*\\"))
    
    ; Extract the ZIP file
    try {
        zipFolder := shell.NameSpace(selectedFile)
        extractFolder := shell.NameSpace(currentFolder)

        extractFolder.CopyHere(zipFolder.Items())
    } catch {
        MsgBox "An error occurred during extraction."
    }
}
