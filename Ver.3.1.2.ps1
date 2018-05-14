####################################
#                                  #
#  Assembled by Wesley F. Willick  #
#          May 11, 2018            #
#                                  #
####################################

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

$ExecutionTime=[system.diagnostics.stopwatch]::StartNew()
 
#Calls the Get-Path function and stores the path in the $path variable.
$path = Get-Path

#Initialize array for change log lines.
$logarray = @()

#Creates an array list to hold the log arrays as they're created.
$loglist = New-Object System.Collections.ArrayList

#Recurse through folders starting from the chosen path start.
$folders = Get-ChildItem -Path $path -Recurse -Directory -Force

#Reverses the folders array so it works "from the bottom up".
[array]::Reverse($folders)

#Process each folder as it arrives through the pipeline.
$folders | ForEach-Object -Process {
    $newpath = Join-Path $(Split-Path -Parent $_.FullName) $($_.Name.Replace(" ", "_")) #Joins the parent path with the now renamed folder.
    if($_.FullName -ne $newpath){ 
        #Checks if the old path name is equal to the new path name. If not (due to a rename of a space), it renames the full path to the new one.
        Rename-Item -LiteralPath $_.FullName -NewName $newpath
        #Creates a formatted log line with the full, old, and new path names of the folder.
        $logadd = New-Object PSObject -Property ([ordered]@{'Old name' = $_.Name;'New name' = $(Split-Path $newpath -Leaf);'Full Path' = $_.FullName})
    }
    $loglist.Add($logadd) #Adds the log line to the log array.
}

#Same method as above, but for the files along the path instead.
$files = Get-ChildItem -Path $path -Recurse -File -Force

#Reverses the files array so it works "from the bottom up".
[array]::Reverse($files)

#Process each file as it arrives through the pipeline.
$files | ForEach-Object -Process {
    $newpath = Join-Path $(Split-Path -Parent $_.FullName) $($_.Name.Replace(" ", "_"))
    if($_.FullName -ne $newpath){ 
        Rename-Item -LiteralPath $_.FullName -NewName $newpath
        $logadd = New-Object PSObject -Property ([ordered]@{'Old name' = $_.Name;'New name' = $(Split-Path $newpath -Leaf);'Full Path' = $_.FullName})
    }
    $loglist.Add($logadd)
}

#Gets the current date and time and stores 
#it in the specified format in the $timestamp variable.
$timestamp = Get-Date -UFormat %Y-%m-%d_%H.%M.%S 

#Creates a logfile with the timestamp in the users C:\temp folder  
$logfile = "C:\temp\FileRenameLog-$timestamp.txt"

#Converts the array list to a single array.
$logarray = $loglist.ToArray()

#Exports the array to a .txt file
$logarray | Out-File -FilePath $logfile -Force -Width 256
    
$ExecutionTime.Stop() 
$ExecutionTime 