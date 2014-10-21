<# 
.SYNOPSIS 
	Returns a boolean value to indicate whether or not a specified member belogs to the specified groups.
.DESCRIPTION 
	Used in conjunction with other scripts to perform actions based on group membership. Multiple groups can be entered and function will return true if user is a member of any of the specified groups.
.NOTES 
    File Name  : Get-PhysicalVideoController.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Test-ADGroupMembership -u "bkadmin" -g "Domain Admins;Enterprise Admins" 
	This command will check if the user "bkadmin" is a member of either Domain Admins or Enterprise Admins. If bkadmin is a member of at least one of the groups, it will return true.
#> 


function Test-ADGroupMembership
{	
	#written by Brenton Keegan on 11/6/13. Returns $true if the specified user is a member of at least one of the specified groups.
	#1. $username - SAMAccountname of user to perform test on
	#2. $groupnames - Group names separated by semicolons
	
	[cmdletbinding()]
	
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("user")]
		[alias("u")]
		[string]$username,
		
		[parameter(Mandatory=$true)]
		[alias("groups")]
		[alias("g")]
		[string]$groupnames
	)
	
	#causes a terminating exception if user does not exist. Otherwise this function will return no exception if an invalid user is entered since all it does is search thru a group's members and matches text.
	$ErrorActionPreference = "Stop"
	Get-ADUser -id $username
	
	$groupnamesArray = $groupnames -split(";")
	$isMemberof = $false
	
	Foreach ($group in $groupnamesArray)
	{
	
		$result = Get-ADGroupMember $group | Where {$_.SamAccountName -eq $username} | foreach {$_.SamAccountName
			If($_.SamAccountName -contains $username)
			{
				$isMemberof = $true
			}
		} 	
	} 
	
	Return $isMemberof 
}
