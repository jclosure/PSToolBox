
$fileName = ".\processes.csv"

If (Test-Path $fileName){
	Remove-Item $fileName
}

#set a readonly variable (a constant)
#set-variable -name processes -value (Get-Process) -option constant -scope global -description "All processes" -passthru | format-list -property *

#control through pipeline, can output to whatever
#Get-Process Format-List -Property * 
#Get-Process | select Name, Description, Product, StartTime, Responding, NPM | Format-List -Property * 
#Get-Process | select Name, Description, Product, StartTime, Responding, NPM | Format-Table -Property * 
#Get-Process | select Name, Description, Product, StartTime, Responding, NPM | Format-Custom -Property *

#broken
#Get-Process | select Name, Description, Product, StartTime, Responding, NPM | ConvertTo-Json -Property * | Out-File .\output.json 

#Get-Process | select Name, Description, Product, StartTime, Responding, NPM | Export-Csv $fileName -Append -NoTypeInformation


#@{Account="User01";Domain="Domain01";Admin="True"} | ConvertTo-Json - Compress

#pipe object to file
#Get-Process | Out-File .\output.txt

#get processes from remote computer
#Get-Process -ComputerName "bosshog"

#convert xml to json
#$JsonSecurityHelp = Get-Content $pshome\Modules\Microsoft.PowerShell.Security\en-US\Microsoft.PowerShell.Security.dll-Help.xml | ConvertTo-Json


