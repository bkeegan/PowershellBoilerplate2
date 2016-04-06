<# 
.SYNOPSIS 
	Outputs directories with ACL entries that are not inherited.
.DESCRIPTION 
	Iterates recursively through a directory and outputs ACL entries that are not inherited. 
.NOTES 
    File Name  : Get-NonInheritedACLEntries.ps1
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowerShellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-NonInheritedACLEntries -f "\\contoso.com\root\share"

#> 
Function Get-NonInheritedACLEntries
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("f")]
		[string]$folderToCheck
	)

	$ACLsToCheck = get-childitem $folderToCheck -directory -r -ErrorAction SilentlyContinue | %{get-ACL $_.FullName} -ErrorAction SilentlyContinue | where {$_.Access.IsInherited -eq $false}
	$ACLResults = @()
	
	Foreach($ACL in $ACLsToCheck)
	{

		$currentPath = $ACL.Path -replace "Microsoft.PowerShell.Core\\FileSystem::",""
		Foreach ($ACLEntry in $ACL.Access)
		{
			If ($ACLEntry.IsInherited -eq $false)
			{
				$folderWithACL = New-Object PSObject    
				$folderWithACL | Add-Member -NotePropertyName "Path" -NotePropertyValue $currentPath
				$folderWithACL | Add-Member -NotePropertyName "ACL Entry" -NotePropertyValue $ACLEntry.IdentityReference
				$folderWithACL | Add-Member -NotePropertyName "Rights" -NotePropertyValue $ACLEntry.FileSystemRights
				$ACLResults += $folderWithACL
			}
		}
	}

	$ACLResults
}
