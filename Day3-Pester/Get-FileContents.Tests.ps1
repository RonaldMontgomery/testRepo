 ## Ensure the function is available
 . 'C:\Users\ronal\version-control\testRepo\Day3-Pester\Get-FileContents.ps1'

describe 'Get-FileContents' {
    it 'creates a file then reads if the file does not exist' {
        mock -CommandName 'Test-Path' -Mockwith {return $false}
        mock -CommandName 'Get-Content' -MockWith {return $null}
        mock -CommandName 'Add-Content' -MockWith {return $null}

        Get-FileContents -Path 'C:\SomeBogusFile.txt'
        Assert-MockCalled -CommandName 'Get-Content' -Times 1 -Scope It
        Assert-MockCalled -CommandName 'Add-Content' -Times 1 -Scope It
    }

    it 'only reads the file if it already exists' {
        mock -CommandName 'Test-Path' -MockWith {
            return $true            
        }
        mock -CommandName 'Get-Content' -MockWith {
            return $null
        } 
        Get-FileContents -Path 'C:\SomeBogusFile.txt'
        Assert-MockCalled -CommandName 'Get-Content' -Times 1 -Scope It
    }
}