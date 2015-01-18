function Load-Packages
{
    param ([string] $directory = 'Packages')
    $assemblies = Get-ChildItem $directory -Recurse -Filter '*.dll' | Select -Expand FullName
    foreach ($assembly in $assemblies) { [System.Reflection.Assembly]::LoadFrom($assembly) }
}

Load-Packages

# ... now use the c# assemblies from ps code