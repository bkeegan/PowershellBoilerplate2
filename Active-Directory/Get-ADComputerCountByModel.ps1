<# 
.SYNOPSIS 
	Returns a table of a computer count per model.
.DESCRIPTION 
	Uses WMI to query the model of machines for objects within a specified OU and increments counters in a table.
.NOTES 
    File Name  : Get-ADComputerCountByModel.ps1
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-DomainComputerWithDevice -s "OU=Computers,DC=contoso,DC=com" 
#> 

function Get-ADComputerCountByModel
{
	[cmdletbinding()]
		Param
		(
			[parameter(Mandatory=$true)]
			[alias("s")] 
			[string]$searchBase
		)

	$adComputers = Get-AdComputer -filter * -searchbase $searchBase
	$computerModels = @{}
	
	$ErrorActionPreference = 'Stop' #make all errors terminating so try/catch work. Error will occur if machine is unreachable or WMI cannot connect
	foreach($adComputer in $adComputers)
	{
		Try
		{
			If((Test-Connection $adComputer.DNSHostName)) #performs a ping
			{

				$currentComp = Get-WmiObject  -Namespace "root\cimv2" -Query "Select * from win32_computersystem" -ComputerName $adComputer.DNSHostName
				if($computerModels.ContainsKey($currentComp.Model)) #check if hashtable already has a key for the model it found
				{
					$computerModels[$currentComp.Model]++ #increment
				}
				Else
				{
					$computerModels.add($currentComp.Model,1) #new find, add key/value pair - value at 1
				}
				
			}
		}
		Catch
		{
			#do nothing on error - WMI not responding or not pingable - skip to next
		}
	}
	#function returns completed hashtable
	Return $computerModels
	
}
