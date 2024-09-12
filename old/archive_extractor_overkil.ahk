#Requires AutoHotkey v2.0

^e:: { ; Ctrl + e
    ; Exit the script if File Explorer is not active
    if !WinActive("ahk_class CabinetWClass") {
        return  
    }

    shell := ComObject("Shell.Application")

    ; Get the selected file in the current active window in Explorer
    selectedFile := ""
    for window in shell.Windows {
        if window.hwnd = WinExist("A") {  ; Make sure it's the active window
            if window.Document.SelectedItems.Count > 0 {
                selectedFile := window.Document.SelectedItems.Item(0).Path
            }
            break  ; Exit the loop once we find the active window
        }
    }

    if (selectedFile == "" || !FileExist(selectedFile) || !InStr(selectedFile, ".zip")) {
        MsgBox "Please select a valid ZIP archive."
        return
    }

    ; remove everything after the last \
    extractFolder := RegExReplace(selectedFile, "\\[^\\]*$")

    zipFolder := shell.NameSpace(selectedFile)
    extractDestination := shell.NameSpace(extractFolder)

    extractDestination.CopyHere(zipFolder.Items())

    ; wait for the zip to not be in use, then delete
    maxAttempts := 3600 ; Max wait time of 1 hour
    while deleteIfNotInUse(selectedFile, maxAttempts) && maxAttempts > 0 {
        maxAttempts--
        Sleep 1000
    }
}

deleteIfNotInUse(filePath, nr) {
    try { ; Try to open the file in read/write mode
        file := FileOpen(filePath, "rw")
        if !IsObject(file) {
            return true ; File is in use
        }
        file.Close()
        FileDelete(filePath)
        MsgBox nr
        return false ; File is not in use
    } catch {
        return true ; Any error indicates the file is in use
    }
}