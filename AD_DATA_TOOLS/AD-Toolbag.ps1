
    #recursively get all users under a group
    Get-ADGroupMember "Domain Users" -Recursive | Select DistinguishedName

    #direct only get of groups to which the user belongs
    get-aduser "jclosure" -property Memberof | Select -ExpandProperty memberOf

    #get all disabled user accounts
    Search-ADAccount -AccountDisabled -UsersOnly

    #get all data about all enabled users
    Get-ADUser -Filter 'Enabled -eq $true' -Properties *

    #are there any users who do not have a manager
    Get-ADUser -Filter * -Properties * | where {$_.manager -eq $null}

    #are there any users who do not have a manager via ldap (faster than the other)
    Get-ADUser -LDAPFilter "(!manager=*)" -Properties *
    
    #get a list of all AD users and whether they are enabled or disabled
    Get-ADUser -LDAPFilter "(samAccountName=*)" | select SamAccountName,Enabled | Format-Table -AutoSize

    #get a computer object
    Get-ADComputer -Filter  'name -eq "someserverhostname"' -Properties *