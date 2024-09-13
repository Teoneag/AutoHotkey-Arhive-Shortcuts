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