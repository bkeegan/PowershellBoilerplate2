<# 
.SYNOPSIS 
	Returns OUs where a specified GPO (by name) is linked to
.DESCRIPTION 
	Returns OUs where a specified GPO (by name) is linked to
.NOTES 
    File Name  : Get-GPLink.ps1
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-GPLink -n "GPO Name"

#> 

#imports
import-module activedirectory
import-module grouppolicy

Function Get-GPLink
{

	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("n")]
		[string]$gpoName
	)

	$GPO = Get-GPO -name $gpoName
	$GUID = $GPO.ID
	$domainOUs = Get-ADOrganizationalUnit -filter *
	foreach($domainOU in $domainOUs)
	{
		if($domainOU.LinkedGroupPolicyObjects -match $GUID)
		{
			$domainOU
		}
	}	
}
