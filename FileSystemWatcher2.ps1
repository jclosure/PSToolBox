
Unregister-Event "File System Deleted"
Unregister-Event "File System Created"
Unregister-Event "File System Changed"
Unregister-Event "File System Renamed"

function Setup-Subscriptions()
{
    ## folder to watch 
    $folder = "C:\temp" 
    ## watch all files 
    $filter = "*" 
    ## events to watch 
    $events = @("Changed", "Created", "Deleted", "Renamed") 
    ## 
    ## create watcher 
    $fsw = New-Object -TypeName System.IO.FileSystemWatcher -ArgumentList $folder, $filter 
    $fsw.IncludeSubDirectories = $true 
    ## 
    ## register events 
    foreach ($event in $events){ 
        Register-ObjectEvent -InputObject $fsw -EventName $event -SourceIdentifier "File System $($event)" 
    }
}

#NOW LETS INSPECT WHAT WE'VE SUBSCRIBED

#We can see the Eventsubscribers we have created.
Get-EventSubscriber | Select SubscriptionId, EventName, SourceIdentifier | ft -a

#We now need to perform some actions on the files – create, change, rename, delete that we are monitoring
Get-Event | group SourceIdentifier

#If we look at this in more detail, 
Get-Event | select EventIdentifier, SourceIdentifier, TimeGenerated


#AFTER YOU GENERATE SOME OF THE EVENTS YOU CAN RUN THESE AND COLLECT THEM

function Get-Subscribed-Events()
{
    Get-Event -SourceIdentifier "File System Changed" | Group TimeGenerated | where {$_.Count-eq 2} |  foreach {
        #$time = $_.Name; Get-Event | where {$_.TimeGenerated.ToString() -eq $time}| select -First 1
        "{0}, {1}, {2}" -f   $_.SourceIdentifier, $_.SourceEventArgs.FullPath, $_.TimeGenerated 

    }

    Get-Event -SourceIdentifier "File System Created" | foreach { 
        "{0}, {1}, {2}" -f   $_.SourceIdentifier, $_.SourceEventArgs.FullPath, $_.TimeGenerated 
    
    }

    Get-Event -SourceIdentifier "File System Renamed" | foreach { 
        "{0}, {1}, {2}, {3}" -f   $_.SourceIdentifier, $_.SourceEventArgs.OldFullPath, $_.SourceEventArgs.FullPath, $_.TimeGenerated 
    
    }

    Get-Event -SourceIdentifier "File System Deleted" | foreach { 
        "{0}, {1}, {2}" -f   $_.SourceIdentifier, $_.SourceEventArgs.FullPath, $_.TimeGenerated 
    
    }
}