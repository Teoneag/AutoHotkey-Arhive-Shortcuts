#Requires AutoHotkey v2.0

^+e:: { ; Ctrl + Shift + e
    ; Exit the script if File Explorer is not active
    if !WinActive("ahk_class CabinetWClass") {
        return
    }

    shell := ComObject("Shell.Application")

    ; Get the selected files and folders in the current active window in Explorer
    selectedFiles := []
    for window in shell.Windows {
        if window.hwnd = WinExist("A") {  ; Make sure it's the active window
            selectedFiles := window.Document.SelectedItems        
            break  ; Exit the loop once we find the active window
        }
    }

    if (selectedFiles.Count == 0) {
        MsgBox "Please select at least one file to arhive"
        return
    }

    firstItem := selectedFiles.Item(0).Path  ; Get the first selected item
    parentFolder := RegExReplace(firstItem, "\\[^\\]*$") ; Parent folder path for archive
    archivePath := parentFolder . "\Archive.zip"  ; Define the zip path

    ; Prepare the file list to compress
    fileList := ""
    for file in selectedFiles {
        fileList .= '"' StrReplace(file.Path, parentFolder . "\") '" '
    }

    Run('cmd.exe /c cd /d "' parentFolder '" && tar -a -cf "' archivePath '" ' fileList,, "Hide")
}
