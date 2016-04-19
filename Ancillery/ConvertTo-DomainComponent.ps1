<# 
.SYNOPSIS 
	Converts a domain name (e.g. "city.domain.local") to LDAP notation (e.g dc=city,dc=domain,dc=org) with regular expressions.
.DESCRIPTION 
 	Converts a domain name (e.g. "city.domain.local") to LDAP notation (e.g dc=city,dc=domain,dc=org) with regular expressions.
.NOTES 
    File Name  : ConvertTo-DomainComponent.ps1
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	ConvertTo-DomainComponent -dn "contoso.com"

#> 

Function ConvertTo-DomainComponent
{
	[cmdletbinding()]

	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("dn")]
		[string]$domainname
	)

	#Turns a domain name (e.g. "city.domain.local") to LDAP notation (e.g dc=city,dc=domain,dc=org)
	
	$domainname = $domainname -replace "^","dc=" #first part of DN
	$domainname = $domainname -replace "\.",",dc=" #all others
	Return $domainname
}
