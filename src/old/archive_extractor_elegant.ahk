#Requires AutoHotkey v2

^e:: { ; Ctrl + e
    ; Get the selected file path
    filePath := GetSelectedFile()

    if FileExist(filePath) && InStr(filePath, ".zip") {
        ; Extract the archive to the same folder
        folderPath := GetParentFolderPath(filePath)
        ExtractArchive(filePath, folderPath)
    } else {
        MsgBox "Please select a valid ZIP archive."
    }
}

GetSelectedFile() {
    ; Uses COM to get the selected file in File Explorer
    for window in ComObject("Shell.Application").Windows {
        if (window.hwnd == WinExist("ahk_class CabinetWClass")) {
            selectedItems := window.document.SelectedItems()
            if (selectedItems.Count > 0) {
                return selectedItems.Item(0).Path
            }
        }
    }
    return ""
}

GetParentFolderPath(filePath) {
    ; Returns the parent folder of the given file path
    return StrReplace(filePath, "\" . RegExReplace(filePath, ".*\\"))
}

ExtractArchive(filePath, destinationPath) {
    ; Perform the extraction using the Windows Shell
    try {
        shell := ComObject("Shell.Application")
        zipFolder := shell.NameSpace(filePath)
        extractFolder := shell.NameSpace(destinationPath)

        if zipFolder && extractFolder {
            extractFolder.CopyHere(zipFolder.Items())
        } else {
            MsgBox "Failed to extract the archive."
        }
    } catch {
        MsgBox "An error occurred during extraction."
    }
}
