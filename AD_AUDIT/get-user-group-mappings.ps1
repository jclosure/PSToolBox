
$file_base_name = "userstest"


$input_file = ".\$($file_base_name)"


$output_file = ".\$($file_base_name).csv"
$searchPattern = "*"
$cpDelim = "->"

$log_file = ".\$($file_base_name).log"
$echoLog = $True


function Log()
{
    Param($msg)
    
    try
    {
        $msg | Out-File -FilePath $log_file -Append -Force
    }
    catch{}
}

function Get-ADPrincipalGroupMembershipRecursive( ) {

    Param(
        $obj,
        [string] $containmentPath = "",
        [array] $groups = @()
    )

    #$obj = Get-ADObject $obj -Properties memberOf,displayName


    foreach( $groupDsn in $obj.memberOf ) {

        $tmpGrp = Get-ADGroup $groupDsn -Properties memberOf,sid,displayName,samaccountname,name,groupcategory,groupscope,whenCreated,whenChanged,ManagedBy,Description,DistinguishedName

        Log("`t`tGROUP: $($tmpGrp.name)")

        #is this a user object?
        if ([string]::Compare($obj.ObjectClass, "user", $True) -eq 0)
        {
            $username = $obj.SamAccountName
            $containmentPath = $obj.SamAccountName
        }
        else
        {
            $containmentPath = "$($containmentPath) $($cpDelim) $($obj.SamAccountName)" 
        }
        $tmpGrp | Add-Member @{level=$level} -PassThru -Force
        $tmpGrp | Add-Member @{containmentPath=$containmentPath} -PassThru -Force


        if( ($groups | where { $_.DistinguishedName -eq $groupDsn }).Count -eq 0 ) {
            $groups +=  $tmpGrp           
            $groups = Get-ADPrincipalGroupMembershipRecursive $tmpGrp $containmentPath $groups 
        }
        $containmentPath = $username
    }

    return $groups
}




## Simple Example of how to use the function
#$username = Read-Host -Prompt "Enter a username"
#$groups   = Get-ADPrincipalGroupMembershipRecursive (Get-ADUser $username).DistinguishedName
#$groups | Sort-Object -Property name | Format-Table

# Drive it from a file input
$i = 1
Get-Content -Path $input_file | % {
    
    $username = $_

    $user = Get-ADUser $username -Properties employeeId,samaccountname,displayName,enabled,whenChanged,lastLogonTimestamp,name,memberOf,DistinguishedName
    $groups   = Get-ADPrincipalGroupMembershipRecursive $user
    #$groups | Sort-Object -Property name | Format-Table

    Log("USER $($i): $($username)")
    
    $groups | Select -Unique | Sort-Object -Property name | % {
        
        $group = $_

        #fixup containmentpath to contain toplevel group
        $group.containmentPath = "$($group.containmentPath) -> $($group.SamAccountName)"

        #level computation
        $level = ($group.containmentPath -split $cpDelim).Count - 1

        $properties = @{
            "UserSID"=$user.SID
            "UserSamAccountName"=$user.SamAccountName
            "UserDisplayName"=$user.displayName
            "GroupSID"=$group.SID
            "MembershipLevel"=$level
            "MembershipContainmentPath"=$group.containmentPath
            "GroupSamAccountName"=$group.SamAccountName
            "GroupDisplayName"=$group.displayName
            "GroupDescription"=$group.Description
            }

        #temp custodian pattern
        $records = @()
        $record = New-Object  PSObject -Property  $properties
        $records += $record

        $records | Select-Object * | export-csv $output_file -Append -NoTypeInformation -Force

    }


    $i = $i + 1
}







### NOT WORKING BELOW ####

#Get-ADUser -Filter {(samAccountName -like $searchPattern)} -Properties memberOf,sid,employeeId,samaccountname,displayName,enabled | % {
#
#    $user = $_
#
#    $groups = $user | Select -ExpandProperty memberOf
#    
#    $groups | % {
#        
#        $groupDN = $_
#
#        
#        $group = @{}
#        $group = Get-ADGroup -Filter {(distinguishedName -eq $groupDN)} -Properties sid,samaccountname,name,displayName,groupcategory,groupscope,managedBy,Description
#
#        $managedByDN = $group.ManagedBy
#
#
#        if (![string]::IsNullOrEmpty($managedByDN))
#        {
#            $managedBy = Get-ADObject -Filter {(distinguishedName -like $managedByDN )} -Properties displayName
#        }
#
#        
#        
#        $mapping =  New-Object  PSObject -Property  @{
#            "UserSID"=$user.SID
#            "UserSamAccountName"=$user.SamAccountName
#            "UserDisplayName"=$user.DisplayName
#            "UserEnabled"=$user.Enabled
#            "GroupSID"=$group.SID
#            "GroupSamAccountName"=$group.SamAccountName
#            "GroupDisplayName"=$group.DisplayName
#            "GroupManagedBy"=$managedBy.DisplayName
#            "GroupDescription"=$group.Description}
#        $arr = @()
#        $arr += $mapping
#        $arr | Select-Object -Property * | Export-Csv $output_file -Append -NoTypeInformation -Force
#
#    }
#
#}

Write-Host -ForegroundColor Green "DONE!"