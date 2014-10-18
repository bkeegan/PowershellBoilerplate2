<# 
.SYNOPSIS 
	Performs a WMI query for physical network adapters.
.DESCRIPTION 
	A WMI Query will return all network adapters, even virtual network adapters. This cmdlet filters the results by excluding anything attached to the virtual hardware bus and the remaining results must be attached to some other bus (an actual physical bus such as PCI, AGP etc)
	Please note that a VM's network adapter will return as a physical network adapter because it is attached to the PCI bus.
.NOTES 
    File Name  : Get-PhysicalNetworkAdapter.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-PhysicalNetworkAdapter -c "TestPC"
	This command will return physical network adapters on the computer "TestPC"
#> 


function Get-PhysicalNetworkAdapter
{
    [cmdletbinding()]
        Param
        (
			[parameter(Mandatory=$false,ValueFromPipeline=$true)]
			[alias("c")]
			[string]$computer="localhost"
        )
	
	if((Test-Connection $computer -Quiet) -eq $true)
	{                
        $return = Get-WMIObject -ComputerName $computer win32_networkadapter | Where {$_.PNPDeviceID -notmatch "[ROOT|SW]\\.+"}
        Return $return
	}
	else
	{
		Throw "The host, $computer, could not be contacted."
	}
}
