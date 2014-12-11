# Name: Get-GroupHierarchy
# 
# Usage: Example
# 
# Run-Get-GroupHeirarchy ".\output.csv"
#
#
function Run-Get-GroupHeirarchy($inputFile, $consolidate)
{

    #ensure clean output file
    #If (Test-Path $outputFile)
    #{
	#    Remove-Item $outputFile
    #}
      
    #start heirarchy gather
    $Contents = Get-Content -Path $inputFile 
    foreach ($Content in $Contents)
     {
        if ($Content.StartsWith("#") -ne $true)
        {

 	        $topLevelGroup = get-adgroup $Content
 	        foreach ($groupInfo in $topLevelGroup)
	        {       
               Write-host -foregroundcolor Cyan "------------------------------------------------------------------------------------"
  		       write-host -ForegroundColor Cyan "collecting for group: $($groupInfo)"
           
               New-Item -ItemType Directory -Force -Path .\output | Out-Null

               if ($consolidate)
               {
                    $outputFile = Join-Path .\output "Get-ADGroupHierarchy-CONSOLIDATED-output.csv"
               }
               else
               {
                    $outputFile = Join-Path .\output "Get-ADGroupHierarchy-$($groupInfo.Name)-output.csv"
               }

               write-host -ForegroundColor Cyan "outputting to file: $($outputFile)"

	           Get-GroupHierarchy $groupInfo.Name $outputFile
	        }
        }
     }
}

# Name: Get-GroupHierarchy
# 
# Usage: Example
#
# $Contents = Get-Content -Path ".\groups.txt"  
#
# foreach ($Content in $Contents)
# {
# 	$txtgroups = get-adgroup $Content
# 	foreach ($txtgroup in $txtgroups)
#	{ 
#  		write-host -ForegroundCOlor green $txtgroup
#	    Get-GroupHierarchy $txtgroup.Name ".\output.csv"
#	}
# }
function Get-GroupHierarchy ($searchGroup, $outputFile, $topLevelGroup = $null, $currentGroupInfo = $null)
{

    #iter marker
    Write-host -foregroundcolor yellow "------------------------------------------------------------------------------------"
    Write-host -foregroundcolor yellow "searching group: $($searchGroup)"
    Write-host -foregroundcolor yellow "------------------------------------------------------------------------------------"
   
   #recursed
   if ($topLevelGroup -eq $null)
   {
       $topLevelGroup = $searchGroup
   }
   
   #recursed
   if ($currentGroupInfo -eq $null)
   {
       $currentGroupInfo = get-adgroup $searchGroup -Properties *
   }
   

   $groupMembers = get-adgroupmember $searchGroup | sort-object objectClass -descending

   foreach ($member in $groupMembers)
    {
         write-host -ForegroundColor green "working on member: $member.name"
        
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
        $Properties = @{"Extract Timestamp"=[datetime]::Now;"Top-Level Group"=$topLevelGroup;"Containing Group"=$currentGroupInfo.name;"Type"=$member.objectclass;SamAccountName=$member.samaccountname;Name=$member.Name;Enabled=$memberinfo.Enabled;"Canonical Name"=$memberinfo.canonicalname}
        $Newobject = New-Object  PSObject -Property  $Properties
        $Array += $Newobject

        $Array | Select-Object "Extract Timestamp", "Top-Level Group", "Containing Group", "Type", SamAccountName, Name, Enabled, "Canonical Name" | export-csv $outputFile -Append -NoTypeInformation

        if ($member.ObjectClass -eq "group")
        {
            Get-GroupHierarchy $member.name $outputFile $topLevelGroup $groupinfo
        }
     }

} 

#RUN
Run-Get-GroupHeirarchy ".\groups.txt" $true

