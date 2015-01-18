# -------------------
# BASICS
# -------------------

@"

    This is an example of a here string.
    They can be multiline.

"@

$var = @"
    They can also be assigned to variables,
    to which we must concede is rawkusly awesome.
"@ 
$var

@"
    SYNTAX:

    #operational
    map = % { ... }
    map = foreach { ...}  #everything returns like ruby?
    map = Linq-Select -Selector {$b + $_ }
    filter = ? { ... }
    invoke = & { ... }
    invoke = { ... }.Invoke(2)
    process = . { ...} 


    #data structures
    array = @()
    hash = @{}

    #splatting
    index-based (@( ... ))
    key-value-based (@{ ... })
"@


# BASIC DECLARATION SYNTAXES
$a1 = @(1,2,3,"four")
$a2 = @(
    1
    2
    3
    "four"
)

$h1 = @{0=1;1=2;2=3;3="four"}
$h2 = @{
    0=1
    1=2
    2=3
    3="four"
}


# BUILDING OBJECTS WITH ITERATION

ForEach ($objItem in $colItems) {
  $obj = New-Object PSobject
  $obj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName -PassThru `
       | Add-Member -MemberType NoteProperty -Name MacAddress -Value $objItem.MacAddress -PassThru `
       | Add-Member -MemberType NoteProperty -Name IPAdress -Value $objitem.IpAddress -PassThru
}




# -------------------
# INSTANCE-LEVEL WORK
# -------------------

# ADD PROPERTY TO INSTANCE
$object = @{}
$k = "IPv4Address"
$v = "192.168.1.1"

Try {

        Add-Member -InputObject $object -MemberType NoteProperty -Name "$($k)" -Value "$($v)" -Force
        $object | Select-Object "$($k)" | write-host -foregroundcolor Green
        #$object | Select-Object "$($k)" | export-csv ".\output-objects.csv" -Append -NoTypeInformation
    }
Catch {
    
    $object | write-host -foregroundcolor Red 
}


# INSTANCE PROPERTY WITH GETTER AND SETTER
# Add a Property - Note the Advice hook opportunities
$s = "Hello, World"
$s1 = Add-Member -InputObject $s -MemberType NoteProperty -Name 'Country' -Value 'US' -PassThru
$getblock = { return $this.Country; }
$setblock = {
    $cntry = $args[0];
    if ($cntry -isnot [string])
    {
        throw "this property only takes strings";
    }
    $this.Country = $cntry;
}
 
# SCRIPTPROPERTY: Do not need -PassThru because $s1 is already PSObject
Add-Member -InputObject $s1 -MemberType ScriptProperty -Name 'CountryCode' -Value $getblock -SecondValue $setblock;
 
Get-Member -InputObject $s1 -MemberType ScriptProperty;
 
$s1.CountryCode;
$s1.CountryCode = "UK";
$s1.CountryCode;



# SCRIPTMETHOD - ADDING MAP
$col = @(1,2,3,4)
$col | Add-Member -Force -PassThru  -MemberType ScriptMethod -Name map -Value { param ([scriptblock]$block) $this | % { & $block $_ } } 
$col.map({ $_ * $_ })








# -----------------
# CLASS-LEVEL WORK
# -----------------

$type = [System.Object]
$method = "quack"

#System.Collections.Hashtable
#System.Object

Add-Type -AssemblyName mscorlib
Add-Type -AssemblyName System.Linq

#Route Calls To .Net Type Extension Methods - The Method must exist on the type via Extension in C#,...
#Update-TypeData -TypeName System.Collections.Hashtable -MemberType ScriptMethod -Force -MemberName $method -Value {
#  switch ($args.Count)
#  {
#      0 { [System.Collections.Hashtable]::$method($this) }
#      1 { [System.Collections.Hashtable]::$method($this, $args[0]) }
#      2 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2], $args[3]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2], $args[3], $args[4]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2], $args[3], $args[4], $args[5]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2], $args[3], $args[4], $args[5], $args[6]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9]) }
#      3 { [System.Collections.Hashtable]::$method($this, $args[0], $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9], $args[10]) }
#      default { throw "No overload for $(method) takes the specified number of parameters." }
#  }
#}

# Nest Script Blocks via Closures
$block = {
    Write-Host "i'm a block"
}

Update-TypeData -TypeName $type -MemberType ScriptMethod -Force -MemberName $method -Value {
    & $block
    Write-Host $this["abc"]
}


# Native Array Types
$arr1 = @()
$arr2 = (New-Object -TypeName System.Collections.ArrayList).ToArray()

# .Net Array Types
# Cast array to List<Object> list
[Collections.Generic.List[Object]]$list1 = $arr1
# Cast array to List<String> typed list
[Collections.Generic.List[String]]$list2 = $arr1
# New typed List
$list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Object]'

# Native Hashtable Types
$hash1 = @{}
$hash2 = New-Object -TypeName System.Collections.Hashtable
$obj1 = New-Object -TypeName System.Object







@" 
    CODE SANDWHICH 
        todo: use to monkey patch at the class-level, e.g. Class Objects in Ruby
              make a patch() a function on System.Object
"@

$type = [System.Object]
$method = "make_sandwich"

# Add a method that can use a coroutine
Update-TypeData -TypeName $type -MemberType ScriptMethod -Force -MemberName $method -Value {
    Write-Host "Top Slice"
    # run your before code here

    # Capture the coroutine
    $coroutine = $args[$args.Length - 1]
    if ($coroutine -and $coroutine  -is [System.Management.Automation.ScriptBlock])
    {
        # Remove the coroutine   
        $args = $args[0..($args.Length-2)]

        # Run the coroutine. Splat remaining args into it.
        #& $coroutine @args | Write-Host

        $result += Invoke-Command -ScriptBlock $coroutine -ArgumentList $args
        Write-Host "Meat Layer: $($result)"
    }

    Write-Host "Bottom Slice"
    #run your after code here

    return $result
}

# Coroutine
$meat_decider = {

    $choices = @{'ham'='baked ham';'turkey'='smoked turkey';'mystery'='horse brains'}
    
    $message = "your meat is:"
    
    switch ($args.Count)
    {
        0 { "$($message) $($choices['mystery'])" }
        1 { 
            "$($message) $($choices[$args[0]])"
        }
    }
}

$a = @{}
$b = $a.make_sandwich("ham", $meat_decider)
$b
$c = $b.make_sandwich("mutton", { "sheep burger" })
$c


### TYPE-LEVEL PATCH DEF
new-variable -name extension_registry -value @{} -Scope "Global" -Force
Update-TypeData -TypeName System.Type -MemberType ScriptMethod -Force -MemberName "patch" -Value {

    $type = $this
    $method = $args[0]
    
    #NEED A PROPER CLOSURE HERE

    # Set it at Script scope so the reference can be aquired by the internal closure below (-Force allows for overloading method names)
    new-variable -name fn -value $args[1] -Scope "Script" -Force
    
    Update-TypeData -TypeName $type -MemberType ScriptMethod -Force -MemberName $method -Value {
        Write-Host "Top Slice"
        # run your before code here

            Write-Host "COMMANDINVOKATION inner: $($MyInvocation.MyCommand)"
            
            $result += Invoke-Command -ScriptBlock $fn -ArgumentList $args
            Write-Host "Meat Layer: $($result)"
     

        Write-Host "Bottom Slice"
        #run your after code here

        return $result
    }.GetNewClosure()


}

# Supports Overloading == Awesome!
$x = @{}
$x.GetType().patch("fun", { "bag" })
$x.GetType().patch("fun", { param([string]$p) "$($p) bag" })

# Hash kung fu
$y = @{'foo'='bar'}
$y.GetType().patch("fu01", { param([string]$p) $this["$($p)"] })
$y.fu01('foo')

# Dyna fu
$z = @{'foo'='bar'}
$z.GetType().patch("fu02", { 
    $this["$($args[0])"] 
})
$z.fu02('foo')

# Fu in practice: 1
# Grab a subset of an Hashtable's properties
$o = @{'foo'='bar'}
$o.GetType().patch("filter1", { 
    $subset = @{}
    $args | foreach {
        $subset[$_] = $this[$_]
    }
    return $subset
})
$oo = $o.filter1('foo','nix', 'qux')
$oo




# Fu in practice: 2
# Grab a subset of an Hashtable's properties
$o = @{'foo'='bar';'qux'='blah';'zorg'='bam'}
$o.GetType().patch("get_elements", { 
    $subset = @{}
    $args | foreach {
        $subset[$_] = $this[$_]
    }
    return $subset
})
$oo = $o.get_elements({ param([object[]]$p1) 
    $p1 |  % { $this[$_] } 
})
$oo

$oo = $o.get_elements(@('foo','ee'))
$oo


# Fu in practice: 3
# Grab a subset of an Hashtable's properties
$hz = @{'foo'='bar';'qux'='blah';'zorg'='bam'}
$hz.GetType().patch("get_many", {
    $args | % { $this[$_] }
})
$hzz = $hz.get_many('foo', 'zorg')
$hzz


# MAP/REDUCE/FILTER

#IDIOMATIC MAP
1..10 | % { $_ * $_ }

#IDIOMATIC REDUCE
1..10 | % {$total=1} {$total *= $_} {$total}

#IDIOMATIC FILTER
1..10 | ? { $_ % 2 -eq 0 }




# Ast parameter validation is used to ensure that the lambda
# function passed in has either one or two parameters.
    
function Map-Sequence
{
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ $_.Ast.ParamBlock.Parameters.Count -eq 1 })]
        [Scriptblock] $Expression,
 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Object[]] $Sequence
    )
 
    $Sequence | % { &$Expression $_ }
}
 
function Reduce-Sequence
{
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ $_.Ast.ParamBlock.Parameters.Count -eq 2 })]
        [Scriptblock] $Expression,
 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Object[]] $Sequence
    )
 
    $AccumulatedValue = $Sequence[0]
 
    if ($Sequence.Length -gt 1)
    {
        $Sequence[1..($Sequence.Length - 1)] | % {
            $AccumulatedValue = &$Expression $AccumulatedValue $_
        }
    }
 
    $AccumulatedValue
}
 
function Filter-Sequence
{
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ $_.Ast.ParamBlock.Parameters.Count -eq 1 })]
        [Scriptblock] $Expression,
 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Object[]] $Sequence
    )
 
    $Sequence | ? { &$Expression $_ -eq $True }
}

# EXTENDING SEQUENCES WITH A MAP REDUCE FILTER API

$IntArray = @(1, 2, 3, 4, 5, 6)
 
$Double = { param($x) $x * 2 }
$Sum = { param($x, $y) $x + $y }
$Product = { param($x, $y) $x * $y }
$IsEven = { param($x) $x % 2 -eq 0 }
 
Map-Sequence $Double $IntArray
Reduce-Sequence $Sum $IntArray
Reduce-Sequence $Product $IntArray
Filter-Sequence $IsEven $IntArray

# LET'S PUT SOME SUGAR INTO IT
@().GetType().patch("map", { $this | Map-Sequence $args[0] $this })
@().GetType().patch("reduce", { $this | Reduce-Sequence $args[0] $this })
#@().GetType().patch("filter", { $this | Filter-Sequence $args[0] $this })

@(1,2,3,4).map({ param($x) $x * $x })

@(1,2,3,4).reduce({ param($x, $y) $x * $y })

#@(1,2,3,4).filter({ param($x) $x % 2 -eq 0 })

#@(1..10).map({ param($x) $x * $x })

#@(1..10).reduce({ param($x, $y) $x * $y })

#@(1..10).filter({ param($x) $x % 2 -eq 0 })




# WEBIFY SELF METHODS VIA ALIASING TO __*


# NEXT DO MONKEY PATCHING OF EXISTIN METHODS BY ALIASING AT CLASS LEVEL

#RIGHTEOUS KUNGFU
#$Target= @()
#foreach ($Machine in $Machines)
#{
#    $TargetProperties = @{Name=$Machine}    
#    $TargetObject = New-Object PSObject –Property $TargetProperties
#    $Target += $TargetObject
#}


write-host -foregroundcolor Green "DONE!" 