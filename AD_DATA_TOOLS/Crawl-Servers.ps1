

#todo: must import Get-LocalGroupMembers to run it here.

$searchPattern = "*"

Get-ADComputer -Filter {(Name -like $searchPattern)} -Properties IPv4Address | foreach-object  {
    
    #iter marker
    Write-host -foregroundcolor cyan "------------------------------------------------------------------------------------"
    Write-host -foregroundcolor cyan "$($_.dnshostname)" 
    Write-host -foregroundcolor cyan "------------------------------------------------------------------------------------"

    #see if its up via ping
    if (Test-Connection -Computername $_.dnshostname -count 1 -quiet){
        write-host -foregroundcolor green $_.Name "IS UP"
    }
    else { 
        Write-host -foregroundcolor red $_.Name "IS DOWN"
    }

    #now try to read the local members (remember it can be up, but you might get access denied.  in this case, get more rights)
    #Get-LocalGroupMembers -name $_.Name

    Write-host ""
}