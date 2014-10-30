<# 
.SYNOPSIS 
	Updates Group Policy on machines within a specified OU. 
.DESCRIPTION 
	Runs gpupdate /force /target:computer on all machines in a specified ou. Requires WinRM to be enabled on target machines to involve command.
.NOTES 
    File Name  : Update-GroupPolicyOnDomainComputers.ps1
    Author     : Brenton Keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Update-GroupPolicyOnDomainComputers -t "OU=Computers,DC=Contoso,DC=com" -SearchScope Subtree
	This command will run gpupdate /force /target:computer on every computer in the Computers OU (and any sub OUs) on the contoso.com domain 
#> 


function Update-GroupPolicyOnDomainComputers 
{
	[cmdletbinding()]
		Param
		(
			
			[parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[alias("target")]
			[alias("t")]
			[string]$targetOU,
			
			[parameter(Mandatory=$false)]
			[alias("scope")]
			[string]$searchScope="Base"
		
		)
	Import-Module activedirectory
	Get-ADObject -filter * -searchbase $targetOU -SearchScope $searchScope | where {$_.objectClass -eq "Computer"} | foreach {
		Invoke-Command {
			Write-Output $_.name
			gpupdate /force /target:computer
		}
	}	
}
