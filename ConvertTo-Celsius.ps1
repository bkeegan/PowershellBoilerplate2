<# 
.SYNOPSIS 
	Converts input temperature to Celsius
.DESCRIPTION 
	Converts input temperature to Celsius
.NOTES 
    File Name  : ConvertTo-Celsius.ps1
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	ConvertTo-Celsius -t 37 -r
	Converts the temperature of "37" to Celsius, rounds to nearest whole number
#> 

function ConvertTo-Celsius
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
	
	#([float]$fltTemperature,[boolean]$bolCtoF=$true,[boolean]$bolRound=$true)
	
	#function by brenton keegan - written on 8/9/2013. Converts Celsius to Fahrenheit and vice-versa
	#params: 
	#		$fltTemperature - integer of the number to convert 
	#		$bolCtoF - Default is True. Will assume specified number is Celsius and convert to Fahrenheit - set to False to do vice-versa
	#		$bolRound - default is True - rounds result to nearest whole number
	
	$resultTemperature = ($inputTemperature - 32) * (5/9)
	if($roundResult)
	{
		Return [Math]::Round($resultTemperature)
	}
	Else
	{
		Return $resultTemperature
	}
}
