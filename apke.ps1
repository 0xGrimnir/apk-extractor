# PowerShell APK Extractor
# Author Tyler L. Jones
# Note: Run as Administrator
# If running scripts is disabled on your system, run: "powershell -ExecutionPolicy ByPass" prior to invoking the script.

$s_loc = Get-Location

Set-Location "C:\Bin\Android SDK Platform Tools" #Replace $ with the file path to your Android SDK Platform Tools installation directory.
$adb_loc = Get-Location
Write-Output "Moved to your ADB directory... Done!`n"
Write-Output "ADB: Listing attached devices."

.\adb devices

#Checking if the device is authorized in Android Debugger Bridge before proceeding.
$dev_auth = Read-Host -Prompt "Does the device listed above read 'device'(d) or 'unauthorized' (u)"
#Executes if device is authorized.
if($dev_auth -eq 'd')
{
	Write-Output "`nDevice authorized.`n"

	Write-Output "Invoking ADB's list packages function, and redirecting output to text file."
	Write-Output "File will be located at c:\, and be called p_list.txt"
	#Invokes ADB to create package list, stores it to c:\ as p_list.txt
	.\adb shell pm list packages > c:\p_list.txt

	#Opens the package list for the user, then returns to ADB.
	Set-Location c:\
	.\p_list.txt
	Set-Location $adb_loc
	
	Write-Output "`nMake sure to include the full package name when prompted."
	Write-Output "Example: 'package:com.test.testApp"
	$p_name = Read-Host -Prompt "Full package name"
	$p_name = $p_name.Substring(8)
	$p_path = .\adb shell pm path $p_name
	$p_path = $p_path.Substring(8)
	
	Write-Output "`nCreating temporary APK directory at c:\APKs"
	Write-Output "Extracting APK to temporary directory."
	new-item c:\APKs -ItemType directory
	.\adb pull $p_path c:\APKs

	#Cleaning up, preparing for next run.
	Write-Output "`nMoving APK from temporary directory to c:\`n"
	Write-Output "`nRemoving temporary directory, cleaning up for next run."
	Write-Output "Removing package list text file, cleaning up for next run."
	Move-Item c:\APKs\*.apk c:\
	Remove-Item c:\APKs
	Remove-Item c:\p_list.txt

	Write-Output "`nYour APK is now located at c:\, typically named 'base.apk'"
	Write-Output "Make sure to rename/move it before extracting another APK."

	#Returning to original location of this script, preparing for next run.
	Set-Location $s_loc
}
#Executes if device is not authorized.
elseif($dev_auth -eq 'u')
{
	Write-Output "Your device is not authorized with the Android Debugger Bridge."
	Write-Output "Let's try some simple troubleshooting first."
	Write-Output "1.) Unplug your device."
	Write-Output "2.) Navigate to Developer Options and click 'Revoke USB debugging authorization'"
	Write-Output "3.) Restarting your ADB server..."
	#The following two lines restart the ADB server.
	.\adb kill-server
	.\adb start-server
	Write-Output "3.5) ADB server successfully restarted."
	Write-Output "4.) Plug your device into your computer now. You may need to confirm a prompt on the device's screen."
	Write-Output "5.) Re-execute this script. If you're still not authorized, further troubleshooting is necessary."
	
	#Returning to original location of this script, preparing for next run.
	Set-Location $s_loc
}
#Executes on invalid user input.
else
{
	Write-Output "You did not select an accurate value."
	Write-Output "Re-execute this script and try again."
	
	#Returning to original location of this script, preparing for next run.
	Set-Location $s_loc
}