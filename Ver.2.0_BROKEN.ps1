#Get-Path function opens a Folder Selection Box for the user to select the first 
#folder in the path they want to have files renamed in.
#Returns the selected path to the $folder variable.
Function Get-Path

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

#Write-Log function inserts the old and new filenames as strings into the log file.
Function Write-Log
{
   Param ([string]$logstring)

   Add-content $logfile -value $logstring
}

#Gets the current date and time and stores 
#it in the specified format in the $timestamp variable.
$timestamp = Get-Date -UFormat %Y-%m-%d.%H.%M.%S 

#Creates a logfile with the timestamp in the users C:\temp folder. 
$logfile = "C:\temp\FileRenameLog_$timestamp.txt"

#Calls the Get-Path function and stores the path in the $path variable.
$path = Get-Path

Get-ChildItem -Path $path –Recurse -Force | Rename-Item -NewName { $_.Name -replace " ","_" } | Write-Log $_
