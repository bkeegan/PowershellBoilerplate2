<# 
.SYNOPSIS 
	Gets a list of NTFS Datastreams
.DESCRIPTION 
	NTFS supports multiple datastreams for a given file. A file's normal data is stored in the $DATA datastream, but alternate data or metadata may be stored in alternate datastreams.
.NOTES 
    File Name  : Get-NTFSDataStreams.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-NTFSDataStreams -p "C:|test\file1.ext"
	This command will list the datastreams present in the file1.ext file.
#> 

function Get-NTFSDataStreams
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("p")]
		$path,
		
		[parameter(Mandatory=$false)]
		[alias("r")]
		[switch]$recurse
	)
	
	if((Test-Path $path) -eq $true)
	{		
		if($recurse -eq $false)
		{
			Get-ChildItem -path $path | Get-Item -stream *
		}
		else
		{
			Get-ChildItem -path $path -r | Get-Item -stream *	
		}
	}
	else
	{
		Throw "Cannot find path $path because it does not exist."
	}
}
