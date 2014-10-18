<# 
.SYNOPSIS 
	Converts a binary or hexadecimal number to decimal.
.DESCRIPTION 
	This cmdlet will accept a value to be converted to decimal. It can be made to convert a binary or hexadecimal number to decimal. 
.NOTES 
    File Name  : ConvertTo-Decimal.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-ConvertTo-Decomal -v "0x123AEF" -h
	This command will convert the hexadecimal value "123AEF" to decimal
.EXAMPLE 
	Get-ConvertTo-Decinal -v "11001011" -b
	This command will convert the binary number "11001011" to decimal
#> 

function ConvertTo-Decimal
{
	<# Description: Converts a decimal of hexadecimal number to binary 
	1. $binary - specify a binary number to convert to decimal
	2. $hex - specify a hexadecimal number to convert to decimal. If this is specified the -b value will be ignored.
	#>
	
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$false,ValueFromPipeline=$true)]
		[alias("v")]
		$inputValue,
		
		[parameter(Mandatory=$false)]
		[switch]$b,

		[parameter(Mandatory=$false)]
		[switch]$h
		
	)

	#regex to match hexadecimal numbers
	$regexHex = "^[0-9A-Fa-f]+$"
	#regex to match binary numbers
	$regexBin = "^[0-1]+$"
	#regex to match the "0x" prefix at the beginning of hexadecimal numbers.
	$regexHexPrefix = "^[0x|0X]"
	
	#checks if value was specified
	if($inputValue -eq $null)
	{
		Throw "Specified value is null, please specify a value to convert to decimal"
	}
	
	#trims whitespace
	$inputValue = $inputValue.Trim(" ")
	#checks to make sure a input value type was specified
	if(($h -eq $false) -and ($b -eq $false))
	{
		Throw "Please specify whether specified value is binary of hexadecimal using the -b and -h switches respectively."
	}
	#checks to make sure that both input values were not selected
	elseif(($h -eq $true) -and ($b -eq $true))
	{
		Throw "The -b and -h switches are mutually exclusive. Please use only one."
	}
	#hex conversion to decimal
	elseif($h -eq $true)
	{
		if($inputValue -match $regexHexPrefix)
		{
			$inputValue = $inputValue.Trim($regexHexPrefix)
		}
		if($inputValue -match $regexHex)
		{
			return [Convert]::ToInt32($inputValue,16)
		}
		else
		{
			Throw "The specified value, $inputValue, doesn't appear to be a valid hexadecimal number."
		}
	}
	#binary conversion to decimal
	elseif($b -eq $true)
	{
		if($inputValue -match $regexBin)
		{
			return [convert]::ToInt32($inputValue,2)
		}
		else
		{
			Throw "The specified value, $inputValue, doesn't appear to be a valid binary number."
		}
	}
}
