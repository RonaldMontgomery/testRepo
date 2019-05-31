function Get-FileContents
 {
     [CmdletBinding()]
     param
     (
         [Parameter(Mandatory)]
         [ValidateNotNullOrEmpty()]
         [string]$Path
     )
     
     if (Test-Path -Path $Path -PathType Leaf)
     {
         Get-Content -Path $Path
     }
     else
     {
         Add-Content -Path $Path -Value 'something in here'
         Get-Content -Path $Path
     }
 }