function Load-Packages
{
    param ([string] $directory = 'Packages')
    $assemblies = Get-ChildItem $directory -Recurse -Filter '*.dll' | Select -Expand FullName
    foreach ($assembly in $assemblies) { [System.Reflection.Assembly]::LoadFrom($assembly) }
}

Load-Packages



$Server = {

    $url = 'http://localhost:8080/'
    
    
    $routes = @{
        "/ola" = { return '<html><body>Hello world!</body></html>' }
        "/json" = { return '[{"hello": "world"},{"hello": "world"}]' }
    }
    
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($url)

    Write-Host "Listening at $url..."

    Try
    {
        $listener.Start()

        while ($listener.IsListening)
        {
            $context = $listener.GetContext()
            $requestUrl = $context.Request.Url
            $response = $context.Response

            Write-Host ''
            Write-Host "> $requestUrl"

            $localPath = $requestUrl.LocalPath
            $route = $routes.Get_Item($requestUrl.LocalPath)

            if ($route -eq $null)
            {
                $response.StatusCode = 404
            }
            if ($request.Url -match '/end$') 
            { 
                break 
            }
            else
            {
                $content = & $route
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            }
    
            $response.Close()

            $responseStatus = $response.StatusCode
            Write-Host "< $responseStatus"
        }
    }
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        #Send-MailMessage -From jh@huggle.com -To jclosure@gmail.com -Subject "Failed!" -SmtpServer EXCH01.AD.MyCompany.Com -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
        Write-Host $_.Exception
        break
    }
    Finally 
    {
        if ($listener.IsListening)
        {
            Write-Host "Stopping now.."
            $listener.Stop()
        }
    }
    
}



#[system.console]::TreatControlCAsInput = $true
#check for exit
#$key = [system.console]::readkey($true)
#if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C"))
#{
#    $listener.Stop()
#    break  
#}

$serverJob = Start-Job $Server
Write-Host "Listening..."
Write-Host "Press Ctrl+C to terminate" 
 



#cleanup on exit
Register-EngineEvent PowerShell.Exiting –Action {
    Write-Host "Terminating..."
    Invoke-RestMethod -Uri "http://localhost:8080/end" -Method "Get" -usedefaultcredentials
    $serverJob | Stop-Job
    Remove-Job $serverJob
}


#NOTE: Kill it with: Invoke-RestMethod -Uri "http://localhost:8080/end" -Method "Get" -usedefaultcredentials


# Wait for it all to complete
$i = 0
while ($serverJob.State -eq "Running")
{
    $i = $i + 1
    Write-Host "spin $($i)"
    #this if is not running because no key available.  todo: fix.
    if ([console]::KeyAvailable) 
    {
       [console]::TreatControlCAsInput = $true
       $key = [system.console]::readline()
       if (($key.modifiers -and [consolemodifiers]"control") -and ($key.key -eq "C"))
       {
           Write-Host "Terminating..."
           
           $serverJob | Stop-Job
           Remove-Job $serverJob
           break
       }
    }

    # Getting the information back from the jobs
    Get-Job | Receive-Job

    Start-Sleep -s 1
}
 
