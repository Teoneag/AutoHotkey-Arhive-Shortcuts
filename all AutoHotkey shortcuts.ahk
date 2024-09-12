; Ctrl + e: Extract the selected zip
; Ctrl + Shift + e: Arhive all the selected files & folders
; Ctrl + Shift + c: open selected folder with VS Code

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

    FileAppend("", archivePath) ; create empty zip folder
    zipFile := shell.NameSpace(archivePath)

    zipFile.CopyHere(selectedFiles)
}

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

    FileDelete(selectedFile)
}

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