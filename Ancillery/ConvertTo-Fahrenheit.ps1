<# 
.SYNOPSIS 
	Converts input temperature to Fahrenheit
.DESCRIPTION 
	Converts input temperature to Fahrenheit
.NOTES 
    File Name  : ConvertTo-Fahrenheit.ps1
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	ConvertTo-Fahrenheit -t 37 -r
	Converts the temperature of "37" to Fahrenheit, rounds to nearest whole number
#> 

function ConvertTo-Fahrenheit
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("t")] 
		[float]$inputTemperature,
		
		[parameter(Mandatory=$false)]
		[alias("r")] 
		[switch]$roundResult
	)
	
	$resultTemperature = ($inputTemperature*(9/5) + 32)
	if($roundResult)
	{
		Return [Math]::Round($resultTemperature)
	}
	Else
	{
		Return $resultTemperature
	}
}
