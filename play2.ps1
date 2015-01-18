
Add-PSSnapin PSEventing -ErrorAction SilentlyContinue



do
{
    $events = Get-Event
}
while(!$events)

foreach ($event in $events)
{
    if ($event.Name -eq "CtrlC")
    {
        Write-Host "Ctrl+C detected"
    }
    else
    {
        Write-Host -ForegroundColor Yellow
            "Warning!!! You just got: $($event.Args)"
    }
}

