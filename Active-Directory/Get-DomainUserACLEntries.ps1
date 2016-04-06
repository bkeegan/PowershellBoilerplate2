<# 
.SYNOPSIS 
	Outputs directories with ACL entries that are assigned to a user and not a group
.DESCRIPTION 
	Iterates recursively through a directory and outputs ACL entries that are assigned to a user and not a group 
.NOTES 
    File Name  : Get-DomainUserACLEntries.ps1
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowerShellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-UserACLEntries -f "\\contoso.com\root\share" -d "CONTOSO"

#> 

#Imports
Import-Module activedirectory


Function Get-DomainUserACLEntries
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("f")]
		[string]$folderToCheck,
		
		[parameter(Mandatory=$true)]
		[alias("d")]
		[string]$domainPrefix
		
	)

	$ACLsToCheck = get-childitem $folderToCheck -directory -r | %{get-ACL $_.FullName} -ErrorAction SilentlyContinue
	$ACLResults = @()
	
	Foreach($ACL in $ACLsToCheck)
	{

		$currentPath = $ACL.Path -replace "Microsoft.PowerShell.Core\\FileSystem::",""
		
		Foreach ($ACLEntry in $ACL.Access)
		{
			$entryIsUser=$false
			$currentUser = $ACLEntry.IdentityReference -replace "$domainPrefix\\",""
			Try
			{
				Get-ADGroup $currentUser | Out-Null
			}
			Catch
			{
				$entryIsUser=$true
				
			}
			
			if ($entryIsUser)
			{
				switch -regex ($ACLEntry.IdentityReference)
				{
					#IGNORE LIST
					"CREATOR OWNER.+" {}
					"NT AUTHORITY\\.+" {}
					"BUILTIN\\.+" {}
					"S-1-5.+" {}
					default
					{
						$folderWithACL = New-Object PSObject    
						$folderWithACL | Add-Member -NotePropertyName "Path" -NotePropertyValue $currentPath
						$folderWithACL | Add-Member -NotePropertyName "ACL Entry" -NotePropertyValue $ACLEntry.IdentityReference
						$folderWithACL | Add-Member -NotePropertyName "Rights" -NotePropertyValue $ACLEntry.FileSystemRights
						$ACLResults += $folderWithACL
					}
				}
			}
			
		}	
	}
	$ACLResults
}
