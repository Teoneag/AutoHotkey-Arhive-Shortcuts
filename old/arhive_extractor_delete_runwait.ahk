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

    RunWait('cmd.exe /c tar -xf "' selectedFile '" -C "' extractFolder '"',, "Hide")

    FileDelete(selectedFile)
}