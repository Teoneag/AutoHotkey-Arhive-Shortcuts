; Ctrl + e: Extract the selected zip
; Ctrl + Shift + e: Arhive all the selected files & folders
; Ctrl + Shift + c: open selected folder with VS Code
; Ctrl + Shift + s: make shortcut from the selected file

#Requires AutoHotkey v2.0

; Archive all the selected files & folders
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
    if selectedFiles.Count = 1 { ; If 1 file selected: file.zip; else: Arhive.zip
        archivePath := parentFolder . "\" . RegExReplace(firstItem, ".*\\") . ".zip"
    } else {
        archivePath := parentFolder . "\Archive.zip"
    }

    FileAppend("", archivePath) ; create empty zip folder
    zipFile := shell.NameSpace(archivePath)

    zipFile.CopyHere(selectedFiles)
}

; Extract the selected zip
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

    ; Remove everything after the last \
    extractFolder := RegExReplace(selectedFile, "\\[^\\]*$")

    zipFolder := shell.NameSpace(selectedFile)
    extractDestination := shell.NameSpace(extractFolder)

    extractDestination.CopyHere(zipFolder.Items())

    FileDelete(selectedFile)
    ; Refresh the explorer window so the file disappears
    DllCall("Shell32.dll\SHChangeNotify", "UInt", 0x8000000, "UInt", 0, "Ptr", 0, "Ptr", 0)
}

; Open selected folder with VS Code
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

; Make shortcut from the selected file
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
    shortcutPath := selectedFile . ".lnk"

    shortcut := ComObject("WScript.Shell").CreateShortcut(shortcutPath)
    shortcut.TargetPath := selectedFile
    shortcut.WorkingDirectory := parentFolder
    shortcut.Save()
}

; Get the selected file in the current active window in Explorer
GetSelectedFile() {
    for window in ComObject("Shell.Application").Windows {
        if window.hwnd = WinExist("A") {  ; Make sure it's the active window
            if window.Document.SelectedItems.Count > 0 {
                return window.Document.SelectedItems.Item(0).Path
            }
        }
    }
    return ""
}