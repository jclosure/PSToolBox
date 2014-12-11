

Get-Content -Path .\users.txt |
ForEach-Object {
    Write-Host -ForegroundColor Green "checking user: $($_)"
    Get-ADUser -LDAPFilter "(employeeID=$_)" -Property employeeId,samaccountname,displayName,enabled,whenChanged,lastLogonTimestamp |
    Select-Object -Property employeeId,samaccountname,displayName,enabled,whenChanged,lastLogonTimestamp | Export-Csv .\output\Get-Users-Enabled.csv -Append -NoTypeInformation -Force
}