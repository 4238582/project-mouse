' Runs LaunchProjectMouse.bat completely hidden (no flashing console window)
Set objShell = CreateObject("WScript.Shell")
installDir = objShell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\ProjectMouse"
objShell.Run """" & installDir & "\LaunchProjectMouse.bat""", 0, False
