<# 
.SYNOPSIS 
	Gets files from a specified zone (Internet, Trusted Sites etc)
.DESCRIPTION 
	This cmdlet determines from which zone a file originated. This information is stored in an alternate datastream called "Zone.Identifier". 
	This cmdlet requires Get-NTFSDataStreams, which is a non-standard cmdlet and is available from the same repository as this cmdlet.
.NOTES 
    File Name  : Get-FilesFromZone.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-NTFSDataStreams -internet  -p "C:\test" -r
	This command will find any files originating from the "Internet" zone in the C:\test folder. This will also recurse thru any subfolders.
#> 

function Get-FilesFromZone
{
	<#Description: Gets files from a non-local source. By default it will return any file with zone.identifer data. Use the optional switches to narrow results 
	1.$path - folder to search
	2.$recurse - optional switch to recurse through all subfolders
	3.$intranet - return intranet files only - can be combined with other source types
	4.$trusted - return trusted site files only - can be combined with other source types
	5.$internet - return internet files only - can be combined with other source types
	6.$untrusted - return untrusted site files only - can be combined with other source types	
	#>
	
	
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("p")]
		$path,
		
		[parameter(Mandatory=$false)]
		[alias("r")]
		[switch]$recurse,
			
		[parameter(Mandatory=$false)]
		[alias("intra")]
		[switch]$intranet,	
			
		[parameter(Mandatory=$false)]
		[alias("t")]
		[switch]$trusted,
		
		[parameter(Mandatory=$false)]
		[alias("inter")]
		[switch]$internet,
		
		[parameter(Mandatory=$false)]
		[alias("u")]
		[switch]$untrusted
	)
	
	#if no zone was specified - default to internet zone.
	if(($intranet -eq $false) -and ($trusted -eq $false) -and ($internet -eq $false) -and ($untrusted -eq $false))
	{
		$internet = $true
	}

	if($recurse -eq $false)
	{
		$nonLocalFiles = Get-NTFSDataStreams -p $path | where {$_.stream -eq "Zone.Identifier"}	
	}
	else
	{
		$nonLocalFiles = Get-NTFSDataStreams -p $path -r | where {$_.stream -eq "Zone.Identifier"}		
	}
	
	$regexFilter = "ZoneId=["
	
	if($intranet -eq $true)
	{
		$regexFilter = "$regexFilter"+"1|"
	}
	if($trusted -eq $true)
	{
		$regexFilter = "$regexFilter"+"2|"
	}
	if($internet -eq $true)
	{
		$regexFilter = "$regexFilter"+"3|"
	}
	if($untrusted -eq $true)
	{
		$regexFilter = "$regexFilter"+"4|"
	}
	
	$regexFilter = $regexFilter -replace "\|$","]"
	$filesToReturn = @()
	foreach($file in $nonLocalFiles)
	{
		$zonedata = Get-Content $file.FileName -stream "Zone.Identifier"
		$result = $zonedata -match $regexFilter
		if($result -ne $null)
		{
			$filesToReturn = $filesToReturn + $file.FileName
		}
	}
	for($i=0;$i -le $filesToReturn.GetUpperBound(0);$i++)
	{
		Get-Item $filesToReturn[$i]
	}
}	
