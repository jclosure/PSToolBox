

function foo()
{

    
     #Write-Host -ForegroundColor Cyan "$baz is $($baz)"

     #$baz = "grog"

     
    if ($bar = $null)
    {
        Write-Host -ForegroundColor Green "`$bar is `$null, setting to 10"
        $bar = 10
    }

    if ($bar -ne 0)
    {
        Write-Host -ForegroundColor Green "`$bar is $($bar)"
        foo
    }

     
<#
    if ($bar -ne 0)
    {
        Write-Host -ForegroundColor Green "$bar is $($bar)"
        foo ($bar - 1)
    }
#>

}


foo 10
