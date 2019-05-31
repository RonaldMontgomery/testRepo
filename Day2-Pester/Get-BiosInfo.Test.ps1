 describe 'Verify Bios Version' {
    
    $bios = Get-CimInstance -ClassName win32_bios 
    
    it 'the BIOS version value should not be null or empty' {    
        $bios.SMBIOSBIOSVersion.Trim() | Should Not BeNullOrEmpty
    }
 }

 describe -Tag 'Serial' 'Check Serial Number Length' {
    
    $bios = Get-CimInstance -ClassName win32_bios 

    it 'the serial number value is seven characters' {
        $bios.SerialNumber.Length | Should Be "7" 
    }
}