
#!!! shorthand: recurse through all files in the fs, note you get a fileinfo for each one
#Get-ChildItem c:\windows -recurse | Where-Object{$_.GetType() -eq [System.IO.FileInfo]} | select FullName

# Manual Recursion Approach
# Recurse("c:\windows", "*")
# 
# Recurses through a psdrive and prints all items that match.
#
# Args:
#   [string]$path: The starting path
#   [string]$fileglob(optional): The search string for matching files
#
function Recurse ([string]$path, [string]$fileglob){
  if (-not (Test-Path $path)) {
    Write-Error "$path is an invalid path."
    return $false
  }

  $files = @(dir -Path $path -Include $fileglob)

  foreach ($file in $files) {
    if ($file.GetType().FullName -eq 'System.IO.FileInfo') {
      Write-Output $file.FullName
    }elseif ($file.GetType().FullName -eq 'System.IO.DirectoryInfo') {
      Recurse $file.FullName
    }
  }
}