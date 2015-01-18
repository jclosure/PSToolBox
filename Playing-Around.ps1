

function foo_by_val($bar = 10)
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

}


foo_by_val 10 "qux"


function foo_by_ref($bar = @{ foo=0 })
{

    #overwriting in place via recusion
    Write-Host -ForegroundColor Cyan "`$bar is $($bar)"
    $bar['foo'] = $bar['foo'] + 1

}


foo_by_ref 10 "qux"