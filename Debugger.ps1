
#http://blogs.technet.com/b/heyscriptingguy/archive/2011/11/24/use-the-debugger-in-the-windows-powershell-ise.aspx

$test = @{ASDF=1234;qwer="blah"}

#breakpoint here
$a = $test

#run it
#play with it in the immediate window
#dump it out
#change its properties: e.g. $a.ASDF=9999

$a
