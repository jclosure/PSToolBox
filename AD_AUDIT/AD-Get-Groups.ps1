
Function Convert-FromUnixdate ($UnixDate) {
   [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').`
   AddSeconds($UnixDate))
}



$output_file = ".\output-groups.csv"
$searchPattern = "*"

Get-ADGroup -Filter {(samAccountName -like $searchPattern)} -Properties sid,samaccountname,name,displayName,groupcategory,groupscope,deleted,isdeleted,whenCreated,whenChanged,ManagedBy,Description,DistinguishedName | foreach-object  {
    
    
    $group = $_


    Try {

        ##iter marker
        #Write-host -foregroundcolor cyan "------------------------------------------------------------------------------------"
        #Write-host -foregroundcolor green "$($group.name)" 
        #Write-host -foregroundcolor cyan "------------------------------------------------------------------------------------"


        $group | Select-Object -Property sid,samaccountname,name,displayName,groupcategory,groupscope,deleted,isdeleted,whenCreated,whenChanged,ManagedBy,Description,DistinguishedName | Export-Csv $output_file -Append -NoTypeInformation -Force

    }
    Catch {
         "----------------------------------------------------" | Out-File "$($output_file)-errors.txt" -Append
         $group | Out-File "$($output_file)-errors.txt" -Append
    }

}




write-host -foregroundcolor Green "DONE!" 