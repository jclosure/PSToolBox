
Function ConvertTo-GBPEuro
{
    param ([int]$Pounds)

    $Currency = New-WebServiceProxy -Uri http://www.webservicex.net/CurrencyConvertor.asmx?WSDL
    $GBPEURConversionRate = $Currency.ConversionRate('GBP','EUR')
    $Euros = $Pounds * $GBPEURConversionRate
    Write-Host “$Pounds British Pounds convert to $Euros Euros”
}

Function ConvertTo-EuroGBP
{
    param ([int]$Euros)
 
    $Currency = New-WebServiceProxy -Uri http://www.webservicex.net/CurrencyConvertor.asmx?WSDL
    $EURGBPConversionRate = $Currency.ConversionRate('EUR','GBP')
    $Pounds = $Euros * $EURGBPConversionRate
    Write-Host “$Euros Euros convert to $Pounds British Pounds”
}