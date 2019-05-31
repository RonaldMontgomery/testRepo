  ## Ensure the function is available
. .\Ping-Computer.ps1
 
 describe 'Ping-Computer' {

    it 'should return $true when the computer is online' {
        mock 'Test-Connection' -MockWith { $true }

        Ping-Computer -ComputerName 'DESKTOP-2QUQADA' | should be $true
    }

    it 'should return $false when the computer is offline' {
        mock 'Test-Connection' -MockWith { $false }

        Ping-Computer -ComputerName 'DESKTOP-2QUQADA' | should be $false
    }
}