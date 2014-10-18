<# 
.SYNOPSIS 
	Performs a WMI query for physical video controllers (i.e. graphic cards)
.DESCRIPTION 
	A WMI Query will return all video controllers, even virtual video controllers. This cmdlet filters the results by excluding anything attached to the virtual hardware bus and the remaining results must be attached to some other bus (an actual physical bus such as PCI, AGP etc)
	Please note that a VM's video controller will return as a physical video controller because it is attached to the PCI bus.
.NOTES 
    File Name  : Get-PhysicalVideoController.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-PhysicalVideoController -c "TestPC"
	This command will return physical video controllers on the computer "TestPC"
#> 

function Get-PhysicalVideoController
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$false,ValueFromPipeline=$true)]
		[alias("c")]
		[string]$computer="localhost"
	)

	$return = Get-WMIObject -ComputerName $computer win32_videocontroller | Where {$_.PNPDeviceID -notmatch "[ROOT|SW]\\.+"}
	Return $return

}
