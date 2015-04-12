
Function Convert-FromUnixdate ($UnixDate) {
   [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').`
   AddSeconds($UnixDate))
}



$output_file = ".\output-users.csv"
$searchPattern = "*"

Get-ADUser -Filter {(samAccountName -like $searchPattern)} -Properties sid,employeeId,samaccountname,displayName,enabled,Title,department,location,lastLogonTimestamp,whenCreated,whenChanged,passwordlastset,passwordexpired,DistinguishedName | foreach-object  {
    
    #$user = Get-ADUser -Filter {(samAccountName -like $_.sameAccountName)} -Properties "*"
    $user = $_

    #$user.lastLogonTimestamp = $user.lastLogonTimestamp 

    Try {

        ##iter marker
        #Write-host -foregroundcolor cyan "------------------------------------------------------------------------------------"
        #Write-host -foregroundcolor green "$($user.displayName)" 
        #Write-host -foregroundcolor cyan "------------------------------------------------------------------------------------"


        $user | Select-Object -Property sid,employeeId,samaccountname,displayName,enabled,title,department,location,whenCreated,whenChanged,DistinguishedName | Export-Csv $output_file -Append -NoTypeInformation -Force

    }
    Catch {
         "----------------------------------------------------" | Out-File "$($output_file)-errors.txt" -Append
         $user | Out-File "$($output_file)-errors.txt" -Append
    }

}

write-host -foregroundcolor Green "DONE!" 