<# 
.SYNOPSIS 
	Computer can be specified as a DNS/NetBIOS name or IP address. Runing this script requires read access to the c$ share on the target computer.
	Crash dumps are copied locally to a specified directory. If no local directory is specified, a folder will be created under %userprofile%\appdata\local named with a timestap and the machine name.
	This script fetches the contents of c:\windows\minidump as well as the memory.dmp file located under c:\windows (this is usually a memory dump from the last bluescreen event.
.DESCRIPTION 
	Fetches crash dumps from bluescreen events from a specified computer. Computer can be specified as a DNS/NetBIOS name or IP address. Runing this script requires read access to the c$ share on the target computer.
	Crash dumps are copied locally to a specified directory. If no local directory is specified, a folder will be created under %userprofile%\appdata\local named with a timestap and the machine name.
	This script fetches the contents of c:\windows\minidump as well as the memory.dmp file located under c:\windows (this is usually a memory dump from the last bluescreen event.
.NOTES 
    File Name  : Get-CrashDumps.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-CrashDumps -computer "TestPC" -w
	This example will collect the contents of c:\windows\minidump as well as c:\windows\memory.dmp if it exists and place them in the folder %userprofile%\appdata\local\<timestamp>.testPC.CrashDumps. An explorer window will then be opened to this folder.
.EXAMPLE 
	Get-CrashDumps -Computer "TestPC" -target "C:\temp\crashdumps" -md
	This example will collect the contents of c:\windows\minidump as well as c:\windows\memory.dmp if it exists and place them in the folder C:\temp\crashdumps. If this folder does not exist, it will create it. 
#> 

function Get-CrashDumps  
{
	[cmdletbinding()]
	
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("computer")]
		[alias("c")]
		[string]$sourceComputer,
		
		[parameter(Mandatory=$false)]
		[alias("target")]
		[alias("t")]
		[string]$targetDirectory="",
		
		[parameter(Mandatory=$false)]
		[switch]$md,
		
		[parameter(Mandatory=$false)]
		[switch]$w
	)
	
	if($targetDirectory -eq "")
	{
		$timeStamp = Get-Date -UFormat "%Y%m%d_%H%M%S"
		$targetDirectory = "$env:userprofile\AppData\Local\$timeStamp.$sourceComputer.CrashDumps\"
		New-Item -ItemType directory -Path $targetDirectory
	} 
	
	if((test-path -Path $targetDirectory) -eq $false)
	{
		if($md -eq $true)
		{
			New-Item -path $targetDirectory -type directory
		}
		else
		{
			Throw "Cannot find path $targetDirectory because it does not exist."
		}
	}
	
	Copy-Item "\\$sourceComputer\c$\Windows\Minidump\*" $targetDirectory

	if((test-path -Path "\\$sourceComputer\c$\Windows\memory.dmp") -eq $true)
	{
		Copy-Item "\\$sourceComputer\c$\Windows\memory.dmp" $targetDirectory
	}
	
	if($w -eq $true)
	{	
		explorer.exe $targetDirectory
	}
}
