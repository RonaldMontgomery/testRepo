[string]$strCompliance = 'Non-Compliant'

try{
    #Array to handle multi-homed computers
    $env:IPv4Address = @((
        Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null -and
            $_.NetAdapter.Status -ne "Disconnected"
        }
    ).IPv4Address.IPAddress)

    #Test for Nestle DNS server
    if((Test-NetConnection -ComputerName "www.bing.com").PingSucceeded) {
    
        foreach($IP in (Resolve-DnsName -Name www.bing.com -Server 8.8.8.8 -DNSOnly -Type A).IP4Address){
        
            write-output "$($env:IPv4Address) $($IP)"
        
            if($env:IPv4Address -contains $IP){
                $strCompliance = 'Compliant'
        
            }#if
    
        }#foreach
    }
    else {
            $strCompliance = 'Compliant'
    }

    Return $strCompliance
}
Catch
{
    Return $strCompliance
}