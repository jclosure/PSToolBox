
function good_skeleton
{
    begin { 
        [Console]::TreatControlCAsInput = $true
    }
    process {
      
      # do stuff ...
      
      # check for Ctrl-C here to terminate processing
      $key = [system.console]::readkey($true)
      if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C"))
      {
          Write-Host "You want to exit, huh?"
          exit
      }
    }
    end { 
      [Console]::TreatControlCAsInput = $false
}
}