
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
                $record | Select-Object "Extract Timestamp", "Computer Name", "Member Domain", "Type", "Member Name" | export-csv .\output\Get-LocalGroupMembers__$($GroupName)__output.csv -Append -NoTypeInformation
                
                $arr += $member

                write-host -ForegroundCOlor green $item.PartComponent
               
			}
		}

		$hash = @{ComputerName=$ComputerName;Members=$arr}
		return $hash
	}
	
	end{}
}


#RUN
Run-Get-LocalGroupMembers .\servers.txt
