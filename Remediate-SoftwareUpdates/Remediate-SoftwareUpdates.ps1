$logReader = Start-Job -ScriptBlock {Get-content C:\temp\testOutput.csv -Tail 0 -Wait | where { $_ -match "Apple Application Support" }}

$stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

Do{
$results= receive-job $logReader.Name -keep
Start-Sleep -Seconds 1
}
until((-not ([string]::IsNullOrEmpty($results))) -or ($stopWatch.elapsed.TotalSeconds -gt 30))

Remove-Job $logReader.Name -Force

write-output $results