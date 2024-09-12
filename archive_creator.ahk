#Requires AutoHotkey v2.0

^+e:: { ; Ctrl + Shift + e
    ; Exit the script if File Explorer is not active
    if !WinActive("ahk_class CabinetWClass") {
        return
    }

    shell := ComObject("Shell.Application")

    ; Get the selected files and folders in the current active window in Explorer
    for window in shell.Windows {
        if window.hwnd = WinExist("A") {  ; Make sure it's the active window
            selectedFiles := window.Document.SelectedItems
            if (selectedFiles.Count == 0) {
                ExitApp
            }

            ; Loop through selected files and paths
            firstItem := selectedFiles.Item(0).Path  ; Get the first selected item
            parentFolder := RegExReplace(firstItem, "\\[^\\]*$") ; Parent folder path for archive
            archivePath := parentFolder . "\Archive.zip"  ; Define the zip path

            ; Prepare the file list to compress
            fileList := ""
            for file in selectedFiles {
                fileList .= '"' file.Path '" '  ; Add quotes around each file path
            }

            ; Run tar to create the archive
            Run('cmd.exe /C tar -a -cf "' archivePath '" ' fileList,, "Hide")

            break  ; Exit the loop once we find the active window
        }
    }
}
