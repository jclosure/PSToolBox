
function Run-Get-LocalGroupMembers($inputFile)
{
    foreach($server in (gc $inputFile))
    { 
        #iter marker
        Write-host -foregroundcolor yellow "------------------------------------------------------------------------------------"
        Write-host -foregroundcolor yellow "visiting server: $($server)"
        Write-host -foregroundcolor yellow "------------------------------------------------------------------------------------"
    
        Get-LocalGroupMembers -name $server 
    }
}


# ==============================================================================================
# 
# NAME: Get-LocalGroupMembers
# 
# USAGE: foreach($server in (gc .\servers.txt)){ Get-LocalGroupMembers -name $server }
# 
# COMMENT: 
# Given a machine name, retrieves a list of members in
# the specified group.
#
# NOTE: servers.txt should be a file with a single column of text representing the servers to have their local groups queried
#
#
# ==============================================================================================



function Get-LocalGroupMembers
{
	param(
		[parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[Alias("Name")]
		[string]$ComputerName,
		[string]$GroupName = "Administrators"
	)
	
	begin {}
	
	process
	{
        New-Item -ItemType Directory -Force -Path .\output | Out-Null
        
		# If the account name of the computer object was passed in, it will
		# end with a $. Get rid of it so it doesn't screw up the WMI query.
		$ComputerName = $ComputerName.Replace("`$", '')

		# Initialize an array to hold the results of our query.
		$arr = @()

		$wmi = Get-WmiObject -ComputerName $ComputerName -Query "SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$ComputerName',Name='$GroupName'`""

		# Parse out the username from each result and append it to the array.
		if ($wmi -ne $null)
		{
			foreach ($item in $wmi)
			{
				$member = ($item.PartComponent.Substring($item.PartComponent.IndexOf(',') + 1).Replace('Name=', '').Replace("`"", ''))
                $item.PartComponent -match 'Win32_(Group|User)' | Out-Null
                $type = $Matches[1]
                $item.PartComponent -match 'Domain="([-_a-zA-Z0-9]+)"' | Out-Null
                $domain = $Matches[1]


                $record = New-Object  PSObject -Property @{"Extract Timestamp"=[datetime]::Now;"Computer Name"=$ComputerName;"Member Domain"=$domain;"Type"=$type;"Member Name"=$member} 


                Write-host -foregroundcolor Cyan "------------------------------------------------------------------------------------"             
                Write-host -foregroundcolor Cyan "found $($record.Type) $($member) in $($record.`"Member Domain`"): recording"
                Write-host -foregroundcolor Cyan "------------------------------------------------------------------------------------"

                #is it a domain object?
                if ($record."Member Domain" -eq "AMD")
                {
                    #call to expand
                    Get-GroupHierarchy $record $member (Join-Path .\output .\Get-LocalGroupMembers-Expanded-AD-Users-And-Groups-output.csv)
                }
                else #local
                {
                    $array = @()
                    $array += $record
                    $array | export-csv (Join-Path .\output .\Get-LocalGroupMembers-Expanded-Local-Users-And-Groups-output.csv) -Append -NoTypeInformation
                }
			}
		}

		#$hash = @{ComputerName=$ComputerName;Members=$arr}
		#return $hash
	}
	
	end{}
}





function Get-GroupHierarchy ($serverRecord, $searchGroup, $outputFile, $topLevelGroup = $null, $currentGroupInfo = $null)
{

    #iter marker
    Write-host -foregroundcolor yellow "------------------------------------------------------------------------------------"
    Write-host -foregroundcolor yellow "searching AD $($serverRecord.Type) $($searchGroup)"
    Write-host -foregroundcolor yellow "------------------------------------------------------------------------------------"
   
   

    #is it a group
    if ($serverRecord.Type -eq "group")
    {

        #recursed
        if ($topLevelGroup -eq $null)
        {
            $topLevelGroup = $searchGroup
        }
   
        #recursed
        if ($currentGroupInfo -eq $null)
        {
            $currentGroupInfo = get-adgroup $searchGroup -Properties * -ErrorAction SilentlyContinue   
        }

        $groupMembers = get-adgroupmember $searchGroup -ErrorAction SilentlyContinue | sort-object objectClass -descending 
    }
    #is it a user
    else
    {
        $groupMembers = @()
        $groupMembers += get-aduser $searchGroup -Properties *
    }
    

    

    foreach ($member in $groupMembers)
    {
        write-host -ForegroundColor green "working on member: $($serverRecord."Member Domain") -> $member.name"
        
        
        if ($member.objectclass -eq "user")
        {
            $memberinfo = get-aduser $member.samaccountname -Properties *
            $userinfo = $memberinfo
            $groupinfo = $currentGroupInfo
        }
        if ($member.objectclass -eq "group")
        {
            $memberinfo = get-adgroup $member.name -Properties *
            $groupinfo = $memberinfo
        }

        #new group encountered
        $currentGroupInfo = $(if(($member.objectclass -eq "group") -and ($member.name -eq $groupinfo.name)){$currentGroupInfo}else{$groupinfo})

        $array = @()
        
        $Properties = @{"Extract Timestamp"=[datetime]::Now;"Computer Name"=$serverRecord."Computer Name";"Member Domain"=$serverRecord."Member Domain";"Top-Level Group"=$topLevelGroup;"Containing Group"=$currentGroupInfo.name;"Type"=$member.objectclass;SamAccountName=$member.samaccountname;Name=$member.Name;Enabled=$memberinfo.Enabled;"Canonical Name"=$memberinfo.canonicalname}
        $Newobject = New-Object  PSObject -Property  $Properties
        $array += $Newobject


        $array | Select-Object "Extract Timestamp", "Computer Name", "Member Domain", "Top-Level Group", "Containing Group", "Type", SamAccountName, Name, Enabled, "Canonical Name" | export-csv $outputFile -Append -NoTypeInformation
        
    

        if ($member.ObjectClass -eq "group")
        {
            Get-GroupHierarchy $serverRecord $member.name $outputFile $topLevelGroup $groupinfo
        }
     }
} 



#RUN
Run-Get-LocalGroupMembers .\servers.txt
#Get-LocalGroupMembers "someserverhostname"