####################################
#                                  #
#  Assembled by Wesley F. Willick  #
#          May 14, 2018            #
#                                  #
####################################

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Space Replacing Script'
$form.Size = New-Object System.Drawing.Size(320,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'Start'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,100)
$label.Text = 'This script will rename all folders and files within a selected directory. A log file will be created in your C:\temp folder. 

Click Start to choose a starting directory, and then click OK to begin.'
$form.Controls.Add($label)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $path = $foldername.SelectedPath
    }
}

$ExecutionTime=[system.diagnostics.stopwatch]::StartNew()

#Gets the current date and time and stores 
#it in the specified format in the $timestamp variable.
$timestamp = Get-Date -UFormat %Y-%m-%d_%H.%M.%S 

#Creates a logfile with the timestamp in the users C:\temp folder  
$outpath = New-Item C:\temp\FileRenames_$timestamp.txt -Type file

#New line variable
$nl = "`r`n"

#Recurse through folders starting from the chosen path start.
$folders = Get-ChildItem -Path $path -Recurse -Directory -Force

#Heading
"Directories: There were $($folders.Count) directories in this path$nl" | Out-File -FilePath $outpath -Append -Force -NoClobber

#Reverses the folders array so it works "from the bottom up".
[array]::Reverse($folders)

#Loop initializing for progress bar.
$i = 1
#Process each folder as it arrives through the pipeline.
$folders | ForEach-Object -Process {
    #Progress bar.
    Write-Progress -Id 1 -Activity "Directories" -status "Renaming Directories: $i of $($folders.Count)" -PercentComplete ($i / $folders.Count *100)  -CurrentOperation "Updating $($_.FullName)"
    $newpath = Join-Path $(Split-Path -Parent $_.FullName) $($_.Name.Replace(" ", "_")) #Joins the parent path with the now renamed folder.
    if($_.FullName -ne $newpath){ 
        #Checks if the old path name is equal to the new path name. If not (due to a rename of a space), it renames the full path to the new one.
        Rename-Item -LiteralPath $_.FullName -NewName $newpath
        #Formats and outputs the old, new, and full path names of the file or folder.
        "Old Name: $_.Name $nl`New Name: $(Split-Path $newpath -Leaf) $nl`Full Path: $_.FullName $nl" | Out-File -FilePath $outpath -Append -Force -NoClobber -Width 256 
    }
    $i++
    #Sleeps the script for a quarter second to allow the progress bar to be read.
    Start-Sleep -Milliseconds 125
}

Start-Sleep -Seconds 1 

#Same method as above, but for the files along the path instead.
$files = Get-ChildItem -Path $path -Recurse -File -Force

#Heading
"Files: There were $($files.Count) files in this path$nl" | Out-File -FilePath $outpath -Append -Force -NoClobber

#Reverses the files array so it works "from the bottom up".
[array]::Reverse($files)

$i = 1
#Process each file as it arrives through the pipeline.
$files | ForEach-Object -Process {
    Write-Progress -Id 2 -Activity "Files" -status "Renaming Directories: $i of $($files.Count)" -PercentComplete ($i / $files.Count *100)  -CurrentOperation "Updating $($_.FullName)"
    $newpath = Join-Path $(Split-Path -Parent $_.FullName) $($_.Name.Replace(" ", "_"))
    if($_.FullName -ne $newpath){ 
        Rename-Item -LiteralPath $_.FullName -NewName $newpath
        "Old Name: $_.Name $nl`New Name: $(Split-Path $newpath -Leaf) $nl`Full Path: $_.FullName $nl" | Out-File -FilePath $outpath -Append -Force -NoClobber -Width 256
    }
    $i++
    Start-Sleep -Milliseconds 125
}

Write-Progress -Id 2 -Activity "Files" -Completed -PercentComplete 100 -Status "Completed"

$ExecutionTime.Stop() 
$ExecutionTime

Read-Host "Renaming complete: $($folders.Count) folders and $($files.Count) files were found in the selected path. Press ENTER to exit"