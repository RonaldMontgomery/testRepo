$report = "$($PSScriptRoot)\report_$(((Get-Date).ToShortDateString()).Replace("/",""")).xls"
$value2 = 'Dulce'

invoke-webrequest -uri 'https://file-examples.com/wp-content/uploads/2017/02/file_example_XLS_10.xls' -OutFile $report

$Excel = New-Object -ComObject Excel.Application
$ExcelWorkBook = $Excel.Workbooks.Open($report)
$ExcelWorkSheet = $Excel.WorkSheets.item("Sheet1")
$ExcelWorkSheet.activate()

$row = ($ExcelWorkSheet.UsedRange.Rows | ? { ($_.Value2 | ? {$_ -eq $value2})} | select -first 1).Row

$number = $ExcelWorkSheet.Cells.Item($row,8).Text

write-output "The number is: $($number)"

$excel.Visible = $true
$Excelprocid = Get-Process |Where-Object{$_.MainWindowHandle -eq $excel.Hwnd}|select -ExpandProperty ID
$excel.Visible = $false
taskkill /im $Excelprocid /f

<#
Open second workbook
Find Date named cell or some other text anchor
Depending on day of week populate date column
Populate compliance number below
Save spreadsheet
End application

https://www.adamtheautomator.com/powershell-excel-worksheet/
https://docs.microsoft.com/en-us/office/vba/api/excel.application(object)
#>