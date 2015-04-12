

$timestamp = [datetime]::Now
$output_file = ".\output-computers.csv"
$searchPattern = "*"

Get-ADComputer -Filter {(samAccountName -like $searchPattern)} -Properties IPv4Address,DNSHostName,Enabled,SID,DistinguishedName,LastLogonDate,SamAccountName,whenCreated,whenChanged | foreach-object  {

    $computer = $_

    #add extract timestamp member
    
    Add-Member -InputObject $computer -MemberType NoteProperty -Name "ExtractTimeStamp" -Value $timestamp -Force

    Try {


        #iter marker
        Write-host -foregroundcolor cyan "------------------------------------------------------------------------------------"
        Write-host -foregroundcolor green "$($computer.samaccountname) --- $($computer.LastLogonDate)" 
        Write-host -foregroundcolor cyan "------------------------------------------------------------------------------------"

    

        # see if its up via ping
        # add the OnLine data point

        #if (-Not [string]::IsNullOrEmpty($computer.dnshostname)){
        #        $computer.dnshostname = "not_set"
        #}
        #if (Test-Connection -Computername $computer.dnshostname -count 1 -quiet){
        #    write-host -foregroundcolor green $computer.Name "IS UP"
        #    $online = "UP"
        #}
        #else { 
        #    Write-host -foregroundcolor red $computer.Name "IS DOWN"
        #    $online = "DOWN"
        #}
        #Add-Member -InputObject $computer -MemberType NoteProperty -Name "OnLine" -Value $online -Force
    
        #Write-host ""


    
        #$computer | Select-Object "IPv4Address", "DNSHostName", "Enabled", "SID", "DistinguishedName", "LastLogonDate"  |  write-host -foregroundcolor Magenta 

        $computer | Select-Object "SID", "SamAccountName", "Enabled", "WhenCreated" , "WhenChanged", "LastLogonDate", "IPv4Address", "DNSHostName", "DistinguishedName" | export-csv $output_file -Append -NoTypeInformation
    }
    Catch {
        $computer | Out-File "$($output_file)-errors.txt" -Append
    }
}



write-host -foregroundcolor Green "DONE!" 