 function Ping-Computer {
    param($ComputerName)

    Test-Connection -ComputerName $ComputerName
}