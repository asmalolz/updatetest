Add-Type -AssemblyName System.Windows.Forms

# Function to check if the script is running as administrator
function Test-IsAdministrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to restart the script with elevated privileges
function Restart-Elevated {
    Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File', "`"$PSCommandPath`"" -Verb RunAs
    exit
}

# Restart with elevated privileges if not already running as administrator
if (-not (Test-IsAdministrator)) {
    Restart-Elevated
}

# Function to save paths to a file
function Save-Paths {
    param (
        [string]$growtopiaPath,
        [string]$Account1Path,
        [string]$Account2Path,
        [string]$inzectorPath
    )
    $paths = @{
        GrowtopiaPath = $growtopiaPath
        Account1Path = $Account1Path
        Account2Path = $Account2Path
        InzectorPath = $inzectorPath
    }
    $paths | ConvertTo-Json | Set-Content -Path "$PSScriptRoot\paths.json"
    
}
# Function to load paths from a file
function Load-Paths {
    if (Test-Path "$PSScriptRoot\paths.json") {
        return Get-Content -Path "$PSScriptRoot\paths.json" | ConvertFrom-Json
    } else {
        return @{
            GrowtopiaPath = "Path to Growtopia"
            Account1Path = "Path to acc 1 save dat"
            Account2Path = "Path to acc 2 save dat"
            InzectorPath = "path to inzector"
        }
    }
}

# Function to browse for a file or folder
function Browse-Item {
    param (
        [string]$initialDirectory,
        [bool]$isFolder = $false
    )
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.InitialDirectory = $initialDirectory
    if ($isFolder) {
        $fileDialog.CheckFileExists = $false
        $fileDialog.CheckPathExists = $true
        $fileDialog.FileName = "Select Folder"
        $fileDialog.ValidateNames = $false
    } else {
        $fileDialog.Filter = "Needed Files(*.dat;*.exe)|*.dat;*.exe"
    }
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        if ($isFolder) {
            return (Split-Path -Path $fileDialog.FileName -Parent)
        } else {
            return $fileDialog.FileName
        }
    }
    return ""
}

# Load paths
if ($psISE)
{
    $workingdir = Split-Path -Path $psISE.CurrentFile.FullPath        
}
else
{
    $workingdir = $PSScriptRoot
}

$paths = Load-Paths
$pythonScriptPath = "$workingdir\main.py"

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "BOT LAUNCHER"
$form.Size = New-Object System.Drawing.Size(770, 500)
$form.Icon = New-Object System.Drawing.Icon("E:\Downloads\Compressed\growpai_4.19\Battlepass-5-2_static-spray_Let_Me_In-300x300.ico")


# Create labels, textboxes, and browse buttons for paths
$labelGrowtopia = New-Object System.Windows.Forms.Label
$labelGrowtopia.Location = New-Object System.Drawing.Point(10, 10)
$labelGrowtopia.Size = New-Object System.Drawing.Size(100, 20)
$labelGrowtopia.Text = "Growtopia Folder:"

$textBoxGrowtopia = New-Object System.Windows.Forms.TextBox
$textBoxGrowtopia.Location = New-Object System.Drawing.Point(120, 10)
$textBoxGrowtopia.Size = New-Object System.Drawing.Size(200, 20)
$textBoxGrowtopia.Text = $paths.GrowtopiaPath

$buttonBrowseGrowtopia = New-Object System.Windows.Forms.Button
$buttonBrowseGrowtopia.Location = New-Object System.Drawing.Point(330, 10)
$buttonBrowseGrowtopia.Size = New-Object System.Drawing.Size(50, 20)
$buttonBrowseGrowtopia.Text = "Browse"
$buttonBrowseGrowtopia.Add_Click({
    $appDataPath = [System.Environment]::GetFolderPath('LocalApplicationData')
    $selectedPath = Browse-Item -initialDirectory $appDataPath -isFolder $true
    if ($selectedPath) {
        $textBoxGrowtopia.Text = $selectedPath
    }
})
$labelAccount1 = New-Object System.Windows.Forms.Label
$labelAccount1.Location = New-Object System.Drawing.Point(10, 40)
$labelAccount1.Size = New-Object System.Drawing.Size(100, 20)
$labelAccount1.Text = "Account1.dat Path:"

$textBoxAccount1 = New-Object System.Windows.Forms.TextBox
$textBoxAccount1.Location = New-Object System.Drawing.Point(120, 40)
$textBoxAccount1.Size = New-Object System.Drawing.Size(200, 20)
$textBoxAccount1.Text = $paths.Account1Path

$buttonBrowseAccount1 = New-Object System.Windows.Forms.Button
$buttonBrowseAccount1.Location = New-Object System.Drawing.Point(330, 40)
$buttonBrowseAccount1.Size = New-Object System.Drawing.Size(50, 20)
$buttonBrowseAccount1.Text = "Browse"
$buttonBrowseAccount1.Add_Click({
    $selectedPath = Browse-Item -initialDirectory (Split-Path -Path $textBoxAccount1.Text -Parent)
    if ($selectedPath) {
        $textBoxAccount1.Text = $selectedPath
    }
})

$labelAccount2 = New-Object System.Windows.Forms.Label
$labelAccount2.Location = New-Object System.Drawing.Point(10, 70)
$labelAccount2.Size = New-Object System.Drawing.Size(100, 20)
$labelAccount2.Text = "Account2.dat Path:"

$textBoxAccount2 = New-Object System.Windows.Forms.TextBox
$textBoxAccount2.Location = New-Object System.Drawing.Point(120, 70)
$textBoxAccount2.Size = New-Object System.Drawing.Size(200, 20)
$textBoxAccount2.Text = $paths.Account2Path

$buttonBrowseAccount2 = New-Object System.Windows.Forms.Button
$buttonBrowseAccount2.Location = New-Object System.Drawing.Point(330, 70)
$buttonBrowseAccount2.Size = New-Object System.Drawing.Size(50, 20)
$buttonBrowseAccount2.Text = "Browse"
$buttonBrowseAccount2.Add_Click({
    $selectedPath = Browse-Item -initialDirectory (Split-Path -Path $textBoxAccount2.Text -Parent)
    if ($selectedPath) {
        $textBoxAccount2.Text = $selectedPath
    }
})

$labelInzector = New-Object System.Windows.Forms.Label
$labelInzector.Location = New-Object System.Drawing.Point(10, 100)
$labelInzector.Size = New-Object System.Drawing.Size(100, 20)
$labelInzector.Text = "Inzector.exe Path:"

$textBoxInzector = New-Object System.Windows.Forms.TextBox
$textBoxInzector.Location = New-Object System.Drawing.Point(120, 100)
$textBoxInzector.Size = New-Object System.Drawing.Size(200, 20)
$textBoxInzector.Text = $paths.InzectorPath

$buttonBrowseInzector = New-Object System.Windows.Forms.Button
$buttonBrowseInzector.Location = New-Object System.Drawing.Point(330, 100)
$buttonBrowseInzector.Size = New-Object System.Drawing.Size(50, 20)
$buttonBrowseInzector.Text = "Browse"
$buttonBrowseInzector.Add_Click({
    $selectedPath = Browse-Item -initialDirectory (Split-Path -Path $textBoxInzector.Text -Parent)
    if ($selectedPath) {
        $textBoxInzector.Text = $selectedPath
    }
})

# Create save paths button
$buttonSavePaths = New-Object System.Windows.Forms.Button
$buttonSavePaths.Location = New-Object System.Drawing.Point(160, 130)
$buttonSavePaths.Size = New-Object System.Drawing.Size(220, 30)
$buttonSavePaths.Text = "Save Paths"
$buttonSavePaths.Add_Click({
    Save-Paths -growtopiaPath $textBoxGrowtopia.Text -Account1Path $textBoxAccount1.Text -Account2Path $textBoxAccount2.Text -inzectorPath $textBoxInzector.Text
    [System.Windows.Forms.MessageBox]::Show("Paths Saved")
})

$checkBoxSkipPython = New-Object System.Windows.Forms.CheckBox
$checkBoxSkipPython.Location = New-Object System.Drawing.Point(10, 135)
$checkBoxSkipPython.Size = New-Object System.Drawing.Size(120, 20)
$checkBoxSkipPython.Text = "Skip Python Script"


# Function to set window state
function Set-WindowState {
    <#
    .SYNOPSIS
    Set the state of a window.
    .DESCRIPTION
    Set the state of a window using the `ShowWindowAsync` function from `user32.dll`.
    .PARAMETER InputObject
    The process object(s) to set the state of. Can be piped from `Get-Process`.
    .PARAMETER State
    The state to set the window to. Default is 'SHOW'.
    .PARAMETER SuppressErrors
    Suppress errors when the main window handle is '0'.
    .PARAMETER SetForegroundWindow
    Set the window to the foreground
    .PARAMETER ThresholdHours
    The number of hours to keep the window handle in memory. Default is 24.
    .EXAMPLE
    Get-Process notepad | Set-WindowState -State HIDE -SuppressErrors
    .EXAMPLE
    Get-Process notepad | Set-WindowState -State SHOW -SuppressErrors
    .LINK
    https://gist.github.com/lalibi/3762289efc5805f8cfcf
    .NOTES
    Original idea from https://gist.github.com/Nora-Ballard/11240204
    #>

    [CmdletBinding(DefaultParameterSetName = 'InputObject')]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Object[]] $InputObject,

        [Parameter(Position = 1)]
        [ValidateSet(
            'FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE',
            'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED',
            'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL'
        )]
        [string] $State = 'SHOW',
        [switch] $SuppressErrors = $false,
        [switch] $SetForegroundWindow = $false,
        [int] $ThresholdHours = 84
    )

    Begin {
        $WindowStates = @{
            'FORCEMINIMIZE'      = 11
            'HIDE'               = 0
            'MAXIMIZE'           = 3
            'MINIMIZE'           = 6
            'RESTORE'            = 9
            'SHOW'               = 5
            'SHOWDEFAULT'        = 10
            'SHOWMAXIMIZED'      = 3
            'SHOWMINIMIZED'      = 2
            'SHOWMINNOACTIVE'    = 7
            'SHOWNA'             = 8
            'SHOWNOACTIVATE'     = 4
            'SHOWNORMAL'         = 1
        }

        $Win32ShowWindowAsync = Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
[DllImport("user32.dll", SetLastError = true)]
public static extern bool SetForegroundWindow(IntPtr hWnd);
'@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru

        $handlesFilePath = "$env:APPDATA\WindowHandles.json"

        $global:MainWindowHandles = @{}

        if (Test-Path $handlesFilePath) {
            $json = Get-Content $handlesFilePath -Raw
            $data = $json | ConvertFrom-Json
            $currentTime = Get-Date

            foreach ($key in $data.PSObject.Properties.Name) {
                $handleData = $data.$key

                if ($handleData -and $handleData.Timestamp) {
                    try {
                        $timestamp = [datetime] $handleData.Timestamp
                        if ($currentTime - $timestamp -lt (New-TimeSpan -Hours $ThresholdHours)) {
                            $global:MainWindowHandles[[int] $key] = $handleData
                        }
                    } catch {
                        Write-Verbose "Skipping invalid timestamp for handle $key"
                    }
                } else {
                    Write-Verbose "Skipping entry for handle $key due to missing data"
                }
            }
        }
    }

    Process {
        foreach ($process in $InputObject) {
            $handle = $process.MainWindowHandle

            if ($handle -eq 0 -and $global:MainWindowHandles.ContainsKey($process.Id)) {
                $handle = [int] $global:MainWindowHandles[$process.Id].Handle
            }

            if ($handle -eq 0) {
                if (-not $SuppressErrors) {
                    Write-Error "Main Window handle is '0'"
                } else {
                   # Write-Verbose ("Skipping '{0}' with id '{1}', because Main Window handle is '0'" -f $process.ProcessName, $process.Id)
                }

                continue
            }

            #Write-Verbose ("Processing '{0}' with id '{1}' and handle '{2}'" -f $process.ProcessName, $process.Id, $handle)

            $global:MainWindowHandles[$process.Id] = @{
                Handle = $handle.ToString()
                Timestamp = (Get-Date).ToString("o")
            }

            $Win32ShowWindowAsync::ShowWindowAsync($handle, $WindowStates[$State]) | Out-Null

            if ($SetForegroundWindow) {
                $Win32ShowWindowAsync::SetForegroundWindow($handle) | Out-Null
            }

            #Write-Verbose ("» Set Window State '{1}' on '{0}'" -f $handle, $State)
        }
    }

    End {
        $data = [ordered] @{}

        foreach ($key in $global:MainWindowHandles.Keys) {
            if ($global:MainWindowHandles[$key].Handle -ne 0) {
                $data["$key"] = $global:MainWindowHandles[$key]
            }
        }

        $json = $data | ConvertTo-Json

        Set-Content -Path $handlesFilePath -Value $json
    }
}



# Update the Open-Account function to pass window title and PID
function Open-Account {
    param (
        [string]$accountName,
        [string]$filePath,
        [string]$affinity,
        [string]$opt,
        [string]$pythonScriptPath
    )
    if (Test-Path $filePath -PathType Leaf) {
        Copy-Item -Path $filePath -Destination "$($textBoxGrowtopia.Text)\save.dat" -Force
        $job = Start-Job -ScriptBlock {
            param ($accountName, $affinity, $inzectorPath, $opt, $pythonScriptPath)
            
            function Get-GrowtopiaPID {
                param (
                    [int]$timeout = 60
                )
                
                $endTime = (Get-Date).AddSeconds($timeout)
                while ((Get-Date) -lt $endTime) {
                    $growtopiaProcesses = Get-Process -Name "growtopia" -ErrorAction SilentlyContinue
                    foreach ($process in $growtopiaProcesses) {
                        if ($process.StartTime -gt (Get-Date).AddSeconds(-5)) {
                            return $process
                        }
                    }
                    Start-Sleep -Seconds 1
                }
                return $null
            }
            
            Start-Process -FilePath $inzectorPath -ArgumentList "`"$accountName`""
            $growtopiaProcess = Get-GrowtopiaPID
            if ($growtopiaProcess) {
                $growtopiaProcess.ProcessorAffinity = [System.IntPtr]::new($affinity)
                $pidss = $growtopiaProcess.Id

                # Wait until the Growtopia window has a title (indicating it's fully loaded)
                $endTime = (Get-Date).AddSeconds(60)
                while ((Get-Date) -lt $endTime -and !$growtopiaProcess.MainWindowTitle) {
                    Start-Sleep -Seconds 1
                    $growtopiaProcess.Refresh()
                }

                if ($growtopiaProcess.MainWindowTitle) {
                    python "$pythonScriptPath", $pidss, $accountName, $opt
                    return @{
                        MainWindowTitle = $growtopiaProcess.MainWindowTitle
                        GrowtopiaPID = $pidss
                    }
                }
            }
            return $null
        } -ArgumentList $accountName, $affinity, $textBoxInzector.Text, $opt, $pythonScriptPath
        
        $job | Wait-Job -Timeout 60

        if ($job.State -eq 'Completed') {
            $result = Receive-Job -Job $job
            
            if ($result) {
                $syncContext = [System.Threading.SynchronizationContext]::Current
                $syncContext.Post([System.Threading.SendOrPostCallback]{
                    param ($state)
                    $listViewItem = New-Object System.Windows.Forms.ListViewItem($state.MainWindowTitle)
                    $listViewItem.SubItems.Add($state.GrowtopiaPID.ToString())
                    $listView.Items.Add($listViewItem)
                }, $result)
            } else {
                [System.Windows.Forms.MessageBox]::Show("Failed to get PID for $accountName")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("$accountName file not found.")
        }
        Remove-Job -Job $job
    } else {
        [System.Windows.Forms.MessageBox]::Show("$accountName file not found.")
    }
}

#check skip
    if ($checkBoxSkipPython.Checked) {
        $opti = "no"
    } else {
        # Call Open-Account function without skipping Python script
        $opti = "yes"
    }




# Create buttons for main functionalities
$button1 = New-Object System.Windows.Forms.Button
$button1.Location = New-Object System.Drawing.Point(10, 170)
$button1.Size = New-Object System.Drawing.Size(370, 30)
$button1.Text = "Open Account1"
$button1.Add_Click({
    
    Open-Account -accountName "Account1" -filePath $textBoxAccount1.Text -affinity 4 -opt $opti -pythonScriptPath $pythonScriptPath
})

$button2 = New-Object System.Windows.Forms.Button
$button2.Location = New-Object System.Drawing.Point(10, 210)
$button2.Size = New-Object System.Drawing.Size(370, 30)
$button2.Text = "Open Account2"
$button2.Add_Click({
    
    Open-Account -accountName "Account2" -filePath $textBoxAccount2.Text -affinity 2 -opt $opti -pythonScriptPath $pythonScriptPath
})

$button3 = New-Object System.Windows.Forms.Button
$button3.Location = New-Object System.Drawing.Point(10, 250)
$button3.Size = New-Object System.Drawing.Size(370, 30)
$button3.Text = "Open Both"
$button3.Add_Click({
    
    Open-Account -accountName "Account1" -filePath $textBoxAccount1.Text -affinity 4 -opt $opti -pythonScriptPath $pythonScriptPath
    Start-Sleep -Seconds 15
    Open-Account -accountName "Account2" -filePath $textBoxAccount2.Text -affinity 2 -opt $opti -pythonScriptPath $pythonScriptPath
})

$button4 = New-Object System.Windows.Forms.Button
$button4.Location = New-Object System.Drawing.Point(10, 290)
$button4.Size = New-Object System.Drawing.Size(370, 30)
$button4.Text = "Set Affinity"
$button4.Add_Click({
    Get-Process growtopia | ForEach-Object { $_.ProcessorAffinity = 2 }
    [System.Windows.Forms.MessageBox]::Show("Affinity Set to 2")
})

$button5 = New-Object System.Windows.Forms.Button
$button5.Location = New-Object System.Drawing.Point(10, 330)
$button5.Size = New-Object System.Drawing.Size(370, 30)
$button5.Text = "Minimize"
$button5.Add_Click({
    Get-Process Growtopia | Set-WindowState -State Hide -SuppressErrors
})

$button6 = New-Object System.Windows.Forms.Button
$button6.Location = New-Object System.Drawing.Point(10, 370)
$button6.Size = New-Object System.Drawing.Size(370, 30)
$button6.Text = "Run Process Checker"
$button6.Add_Click({
    Start-Process -FilePath "Powershell" -ArgumentList "-ExecutionPolicy Bypass -command & {%MYFILES%\a.ps1}"
})

# Create ListView to display window titles and PIDs
$listView = New-Object System.Windows.Forms.ListView
$listView.Location = New-Object System.Drawing.Point(400, 10)
$listView.Size = New-Object System.Drawing.Size(335, 400)
$listView.View = [System.Windows.Forms.View]::Details

# Add columns to ListView
$listView.Columns.Add("Index", 70) | Out-Null
$listView.Columns.Add("Window Title", 200) | Out-Null
$listView.Columns.Add("PID", 60) | Out-Null

# Create label to display PID
$labelPID = New-Object System.Windows.Forms.Label
$labelPID.Location = New-Object System.Drawing.Point(10, 410)
$labelPID.Size = New-Object System.Drawing.Size(380, 30)
$labelPID.Text = ""

# Add controls to the form
$form.Controls.Add($labelGrowtopia)
$form.Controls.Add($textBoxGrowtopia)
$form.Controls.Add($buttonBrowseGrowtopia)
$form.Controls.Add($labelAccount1)
$form.Controls.Add($textBoxAccount1)
$form.Controls.Add($buttonBrowseAccount1)
$form.Controls.Add($labelAccount2)
$form.Controls.Add($textBoxAccount2)
$form.Controls.Add($buttonBrowseAccount2)
$form.Controls.Add($labelInzector)
$form.Controls.Add($textBoxInzector)
$form.Controls.Add($buttonBrowseInzector)
$form.Controls.Add($buttonSavePaths)
$form.Controls.Add($button1)
$form.Controls.Add($button2)
$form.Controls.Add($button3)
$form.Controls.Add($button4)
$form.Controls.Add($button5)
$form.Controls.Add($button6)
$form.Controls.Add($listView)
$form.Controls.Add($checkBoxSkipPython)
$form.Controls.Add($labelPID)

# Create context menu for ListView
$contextMenu = New-Object System.Windows.Forms.ContextMenu

# Menu item to kill the selected process
$menuItemKill = New-Object System.Windows.Forms.MenuItem "Kill Process"
$menuItemKill.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItem = $listView.SelectedItems[0]
        $selectedPID = [int]$selectedItem.SubItems[2].Text  # Renamed to $selectedPID
        Stop-Process -Id $selectedPID -Force
        $listView.Items.Remove($selectedItem)
    }
})

# Menu item to hide the selected process window
$menuItemHide = New-Object System.Windows.Forms.MenuItem "Hide Process"
$menuItemHide.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItem = $listView.SelectedItems[0]
        $selectedPID = [int]$selectedItem.SubItems[2].Text  # Renamed to $selectedPID
        $process = Get-Process -Id $selectedPID
        if ($process) {
            $process | Set-WindowState -State Hide -SuppressErrors
        }
    }
})

# Menu item to show the selected process window
$menuItemShow = New-Object System.Windows.Forms.MenuItem "Show Process"
$menuItemShow.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItem = $listView.SelectedItems[0]
        $selectedPID = [int]$selectedItem.SubItems[2].Text  # Renamed to $selectedPID
        $process = Get-Process -Id $selectedPID
        if ($process) {
            $process | Set-WindowState -State Show -SuppressErrors
        }
    }
})


$contextMenu.MenuItems.Add($menuItemKill)
$contextMenu.MenuItems.Add($menuItemHide)
$contextMenu.MenuItems.Add($menuItemShow)

# Assign the context menu to the ListView
$listView.ContextMenu = $contextMenu

# Function to update the ListView
function Update-ListView {
    $listView.Items.Clear()
    $growtopiaProcesses = Get-Process -Name "growtopia" -ErrorAction SilentlyContinue
    $index = 1
    foreach ($process in $growtopiaProcesses) {
        $listViewItem = New-Object System.Windows.Forms.ListViewItem($index.ToString())
        $listViewItem.SubItems.Add($process.MainWindowTitle)
        $listViewItem.SubItems.Add($process.Id.ToString())
        $listView.Items.Add($listViewItem) | Out-Null
        $index++
    }
}

# Timer to update ListView every 5 seconds
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 5000  # 5000 milliseconds = 5 seconds
$timer.Add_Tick({
    Update-ListView
})
$timer.Start()

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
