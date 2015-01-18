$ServerThreadCode = {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add('http://+:8008/')
 
    $listener.Start()
 
    while ($listener.IsListening) {
 
        $context = $listener.GetContext() # blocks until request is received
        $request = $context.Request
        $response = $context.Response
        $message = "Testing server"
       
        # This will terminate the script. Remove from production!
        if ($request.Url -match '/end$') { break }
     
        [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
        $response.ContentLength64 = $buffer.length
        $response.StatusCode = 500
        $output = $response.OutputStream
        $output.Write($buffer, 0, $buffer.length)
        $output.Close()
    }
 
    $listener.Stop()
}
  
$serverJob = Start-Job $ServerThreadCode
Write-Host "Listening..."
Write-Host "Press Ctrl+C to terminate" 
 
#[console]::TreatControlCAsInput = $true

# Wait for it all to complete
while ($serverJob.State -eq "Running")
{
     if ([console]::KeyAvailable) {
        $key = [system.console]::readkey($true)
        if (($key.modifiers -and [consolemodifiers]"control") -and ($key.key -eq "C"))
        {
            Write-Host "Terminating..."
            $serverJob | Stop-Job 
            Remove-Job $serverJob
            break
        }
    }
    
    Start-Sleep -s 1
}
 
# Getting the information back from the jobs
Get-Job | Receive-Job