<# 
.SYNOPSIS 
	Returns the active directory object that has the specified email address(es) associated with it. 
.DESCRIPTION 
	An email address can be associated with multiple types of active directory objects (users, groups, public folders etc). An email address can also be an alias email address of any of these same objects. It can be difficult to find which object a given email address is associated with.
	This cmdlet will search all active directory objects that has the specified email address associated with it or associated as an alias. There is also an optional parameter to also search for Shadow Proxy Addresses.
	This cmdlet performs a similar function to that of "Get-Recipient", a native exchange powershell cmdlet. This cmdlet, however, does not require Exchange and can potentially be used in non-Exchange environments (however this has not been tested) or in the lack of the Exchange shell or when the return of an AD object is required
.NOTES 
    File Name  : Find-ADEmailAddressOwner 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Find-ADEmailAddressOwner -e "test@contoso.com"
	This command will find which active directory object that has the email address "test@contoso.com" associated with it.
.EXAMPLE 
	Find-ADEmailAddressOwner -e "test.*" -d "adventureworks.com" -ap "-IncludeDeletedObjects"
	This command will find any email addres beginning "test" in the "adventureworks.com" domain (assuming it is reachable). The search for email address performs a regular expression. ".*" will search for any character any amount of times (including no character). 
	-ap is used to pass thru any parameters that would be valid for the "Get-ADObject" commandlet. In this example, this command will also search deleted objects.
.EXAMPLE 
	Find-ADEmailAddressOwner -e ".+\..+" -d "contoso.com"
	This will find any email address that matches characters.morecharacters on the costoso.com domain. For example "john.doe@contoso.com" would get matched. "Sarah.Doe@contoso.com" would also get matched. "Jdoe@contoso.com" would not get matched.
#> 
function Find-ADEmailAddressOwner
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("e")]
		[string]$emailAddress,
		
		[parameter(Mandatory=$false)]
		[alias("d")]
		[string]$domain,

		[parameter(Mandatory=$false)]
		[alias("f")]
		[string]$filter,
					
		[parameter(Mandatory=$false)]
		[alias("sb")]
		[string]$searchBase,
		
		[parameter(Mandatory=$false)]
		[alias("ap")]
		[string]$additionalParameters,
		
		[parameter(Mandatory=$false)]
		[alias("xa")]
		[switch]$excludeAliases,
		
		[parameter(Mandatory=$false)]
		[alias("s")]
		[switch]$includeShadowProxy
		
	)
	
	####cmdlet components
	
	#base command	
	$baseCmdlet = "Get-ADObject"
	
	#-server parameter
	if($emailAddress -match "@")
	{
		$domain = $emailAddress -replace "@.+$",""
	}
	else
	{
		if($domain -eq "")
		{
			Get-ADDomain | foreach {$_.dnsroot
				$domain = $_.dnsroot
			} | Out-Null
		}
		$emailAddress = $emailAddress + "@" + $domain	
	}
	
	$serverCmd = ' -Server $domain'

	#filter
	if($filter -eq "")
	{
		$filterCmd = ' -filter *'
	}
	else
	{
		$filterCmd = ' -filter $filter'	
	}
	
	#Searchbase
	if($searchBase -ne "")
	{
		$searchBaseCmd = ' -searchbase $searchBase'
	}
	
	#-Property Parameter and search clauses
	$propertyCmd = ' -Property mail'
	$searchClause = ' where {($_.mail -eq $emailAddress)'
	if($excludeAliases -eq $false)
	{
		$propertyCmd = $propertyCmd + ',proxyaddresses'
		$searchClause = $searchClause + ' -or ($_.proxyaddresses -match $emailAddress)'
	}
	if($includeShadowProxy -eq $true)
	{
		$propertyCmd = $propertyCmd + ',msExchShadowProxyAddresses'
		$searchClause = $searchClause + '-or ($_.msexchshadowproxyaddresses -match $emailAddress)'
	}
	$searchClause = $searchClause + '}'
	
	###assemble and execute command
	$finalCommand = $baseCmdLet + $severCmd + $filterCmd + $searchBaseCmd + $propertyCmd + " $additionalParameters" + "|" + $searchClause
	Invoke-Expression -Command $finalCommand
}
