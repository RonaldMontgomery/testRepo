function Get-DriveInfo {

    Set-Location -Path $env:SystemDrive

    Try{

        $logicalDisks = Get-WmiObject Win32_Logicaldisk -ErrorAction Stop | Where-Object -FilterScript {$_.DriveType -eq 3} | select DeviceID, Size |
        ForEach-Object -Process {$_.Size = ($_.Size / 1MB).ToString("#.##"); $_}

    } Catch {

       Write-LogEntry -Error $_.Exception.Message -location "$($env:OutputPath)\$($env:COMPUTERNAME)-fileAnalysis.log"

    }

    foreach($logicalDisk in $logicalDisks){

        $fileAttributes = Get-ChildItem -path "$($logicalDisk.DeviceID)\" -ErrorAction silentlycontinue -Recurse |
        Where-Object {$_.FullName -notmatch "Program Files|Windows"} |
        Sort-Object -Property length -Descending |
        Select-Object lastwritetime, length, fullname |
        ForEach-Object -Process {$_.Length = ($_.Length / 1MB).ToString("#.##"); 
        $_.lastwritetime = ($_.lastwritetime).ToshortDateString(); 
        $_ }


        Foreach($file in $fileAttributes){
            $props = [ordered]@{'Last Write Time' = $file.lastwritetime;
                        'Size MB' = $file.Length;
                        'Disk Size MB' = $logicalDisk.Size;
                        '%age of Disk' = ($file.Length / $logicalDisk.Size).ToString("#.##");
                        'Full Path' = $file.FullName}

            $obj = New-Object -TypeName PSObject -Property $props                           
    
            write-output $obj 
    
        }
    }
} # end of Get-DriveInfo function


function Write-LogEntry
{
    [CmdletBinding(DefaultParameterSetName = 'Info', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'https://github.com/MSAdministrator/WriteLogEntry',
                  ConfirmImpact='Medium')]
    [OutputType()]
    Param
    (
        # Information type of log entry
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,
                   ParameterSetName = 'Info')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("information")]
        [System.String]$Info,
 
        # Debug type of log entry
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0,
                   ParameterSetName = 'Debug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$Debugging,
 
        # Error type of log entry
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0,
                   ParameterSetName = 'Error')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$Error,
 
 
        # The error record containing an exception to log
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName = 'Error')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("record")]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
 
        # Logfile location
        [Parameter(Mandatory=$false, 
                   ValueFromPipelineByPropertyName=$true, 
                   Position=2)]
        [Alias("file", "location")]
        [System.String]$LogFile = "$($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(‘.\’))" + "\log.log"
    )
 
    if (!(Test-Path -Path $LogFile))
    {
         try
         {
            New-Item -Path $LogFile -ItemType File -Force | Out-Null
         }
         catch
         {
            Write-Error -Message 'Error creating log file'
            break
         }
    }
 
    $mutex = New-Object -TypeName 'Threading.Mutex' -ArgumentList $false, 'MyInterprocMutex'
   
    
    switch ($PSBoundParameters.Keys)
    {
         'Error' 
         {
            $mutex.waitone() | Out-Null
 
            Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyyMMddThhmmss')) [ERROR]: $Error"
 
            if ($PSBoundParameters.ContainsKey('ErrorRecord'))
            {
                $Message = '{0} ({1}: {2}:{3} char:{4})' -f $ErrorRecord.Exception.Message,
                                                            $ErrorRecord.FullyQualifiedErrorId,
                                                            $ErrorRecord.InvocationInfo.ScriptName,
                                                            $ErrorRecord.InvocationInfo.ScriptLineNumber,
                                                            $ErrorRecord.InvocationInfo.OffsetInLine
 
                Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyyMMddThhmmss')) [ERROR]: $Message"
            }
 
            $mutex.ReleaseMutex() | Out-Null
         }
         'Info' 
         {
            $mutex.waitone() | Out-Null
 
            Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyyMMddThhmmss')) [INFO]: $Info"
                
            $mutex.ReleaseMutex() | Out-Null
         }
         'Debugging' 
         {
            Write-Debug -Message "$Debugging"
 
            $mutex.waitone() | Out-Null
                
            Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyyMMddThhmmss')) [DEBUG]: $Debugging"
                
            $mutex.ReleaseMutex() | Out-Null
         }
    }#End of switch statement
} # end of Write-LogEntry function



$env:OutputPath = "C:\temp"

If(Test-Path -Path $env:OutputPath){

    Remove-Item "$($env:OutputPath)\$($env:COMPUTERNAME)*.*" -Force -ErrorAction SilentlyContinue
    
    Write-LogEntry -Info  "Populating file $($env:COMPUTERNAME)-fileAnalysis.csv" -location "$($env:OutputPath)\$($env:COMPUTERNAME)-fileAnalysis.log"
    
    Get-DriveInfo | Export-CSV -Path "$($env:OutputPath)\$($env:COMPUTERNAME)-fileAnalysis.csv" -NoTypeInformation -Force
    
    Write-LogEntry -Info  "$($env:COMPUTERNAME)-fileAnalysis.csv created." -location "$($env:OutputPath)\$($env:COMPUTERNAME)-fileAnalysis.log"

} Else {
    
    #fail quietly
    exit 1234
}