<# 
.SYNOPSIS 
	Returns computers in a specified OU with a particular device or device vendor present (based on PNP device ID)
.DESCRIPTION 
    This script queries computers within a specified OU for a presence of a particular device or device vendor based on values in the PNPDeviceID WMI table. This script can be used to locate a particular device (based on VID/PID) or any devices by a particular vendor (by only searching by VID/VEN)
	Because it's based on PNP device IDs - as single device may return several values.
.NOTES 
    File Name  : Get-DomainComputerWithDevice.ps1
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
	Info on VID/PID values: http://pcidatabase.com/index.php
.EXAMPLE 
	Get-DomainComputerWithDevice -s "OU=Computers,DC=contoso,DC=com" -pnp "VID_046D"
	Will return all Logitech Devices.
#> 

#imports
import-module activedirectory

Function Get-DomainComputerWithDevice
{
[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("s")] 
		[string]$searchBase,
		
		[parameter(Mandatory=$true)]
		[alias("pnp")]
		[string]$pnpQuery
	)
	$adComputers = Get-AdComputer -filter * -searchbase $searchBase
	$computersWithDevice = @()

	foreach($adComputer in $adComputers)
	{
		if(Test-Connection $adComputer.DNSHostName -ErrorAction "SilentlyContinue")
		{
			$wmi = gwmi win32_bios -ComputerName $adComputer.DNSHostName -ErrorAction "SilentlyContinue"
			if ($wmi)
			{
				$computersWithDevice += gwmi win32_pnpentity -computer $adComputer.DNSHostName | where {$_.PNPDeviceID -match $pnpQuery } | select SystemName, Description, PNPDeviceID
			}
		}
	}

	$computersWithDevice 
}
