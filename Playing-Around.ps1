

function foo($bar = 10)
{

    #overwriting in place via recusion
    Write-Host -ForegroundColor Cyan "`$baz is $($baz)"
    $baz = $baz + 1

    
    #recursion driver
    if ($bar -ne 0)
    {
        Write-Host -ForegroundColor Green "`$bar is $($bar)"
        foo ($bar - 1)
    }

     
<#
    if ($bar -ne 0)
    {
        Write-Host -ForegroundColor Green "$bar is $($bar)"
        foo ($bar - 1)
    }
#>

}


foo 10 "qux"
