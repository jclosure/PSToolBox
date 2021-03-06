
$script:scriptPath = split-path -parent $MyInvocation.MyCommand.Definition


$script:folder = (Join-Path $script:scriptPath '.\test') # Enter the root path you want to monitor.
$script:filter = '*.*'  # You can enter a wildcard filter here.

$logFile =  (Join-Path $scriptPath '.\test-monitoring\outlog.txt')

function monitor()
{
    $scriptPath = $script:scriptPath
    $folder = $script:folder 
    $filter = $script:filter 
                  
    $logFile = $script:logFile
    

    # In the following line, you can change 'IncludeSubdirectories to $true if required.                          
    $fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}

    $global:fsw = $fsw

    # Here, all three events are registered.  You need only subscribe to events that you need:

    Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
        $name = $Event.SourceEventArgs.Name
        $changeType = $Event.SourceEventArgs.ChangeType
        $timeStamp = $Event.TimeGenerated
        #Copy-Item $Event.FullPath c:\
        Write-Host "The file '$name' was $changeType at $timeStamp" -fore green
        Out-File -FilePath $global:logFile -Append -InputObject "The file '$name' was $changeType at $timeStamp"
    }

    Register-ObjectEvent $fsw Deleted -SourceIdentifier FileDeleted -Action {
        $name = $Event.SourceEventArgs.Name
        $changeType = $Event.SourceEventArgs.ChangeType
        $timeStamp = $Event.TimeGenerated
        Write-Host "The file '$name' was $changeType at $timeStamp" -fore red
        Out-File -FilePath $global:logFile -Append  -Verbose -InputObject "The file '$name' was $changeType at $timeStamp"
    }

    Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
        $name = $Event.SourceEventArgs.Name
        $changeType = $Event.SourceEventArgs.ChangeType
        $timeStamp = $Event.TimeGenerated
        Write-Host "The file '$name' was $changeType at $timeStamp" -fore white
        Out-File -FilePath $global:logFile -Append  -Verbose -InputObject "The file '$name' was $changeType at $timeStamp"
    }

    Register-ObjectEvent $fsw Renamed -SourceIdentifier FileRenamed -Action {
        $name = $Event.SourceEventArgs.Name
        $changeType = $Event.SourceEventArgs.ChangeType
        $timeStamp = $Event.TimeGenerated
        Write-Host "The file '$name' was $changeType at $timeStamp" -fore white
        Out-File -FilePath $global:logFile -Append -Verbose -InputObject "The file '$name' was $changeType at $timeStamp" 
    }
}

function unmonitor()
{
    # To stop the monitoring, run the following commands:
    Unregister-Event FileDeleted
    Unregister-Event FileCreated
    Unregister-Event FileChanged
    Unregister-Event FileRenamed
}

#RUN
unmonitor
monitor