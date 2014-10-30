<# 
.SYNOPSIS 
	Returns properties of the Windows Firewall on the specified machine.
.DESCRIPTION 
	Returns the output from netsh advfirewall as a powershell object. Values are derived dynamically using regular expressions. 
	This cmdlet parses the results from netsh advfirewall show (global | domain | private | public). This cmdlet requires WinRM to be enabled on the target machine.
.NOTES 
    File Name  : Get-WindowsFirewall.ps1
    Author     : Brenton Keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-WindowsFirewall -d -c "localhost"
	Gets the properties of the domain profile firewall on the local host.
.EXAMPLE 
	Get-WindowsFirewall -g -d -pri -pub -c "RemotePC"
	Gets all properties (global,domain,private,public) on the computer named "RemotePC"
#> 

function Get-WindowsFirewall
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("c")]
		$computer,

		[parameter(Mandatory=$false)]
		[alias("g")]
		[switch]$global,
		
		[parameter(Mandatory=$false)]
		[alias("d")]
		[switch]$domain,
		
		[parameter(Mandatory=$false)]
		[alias("pri")]
		[switch]$private,
		
		[parameter(Mandatory=$false)]
		[alias("pub")]
		[switch]$public
		
	)
	
	if(($global -eq $false) -and ($domain -eq $false) -and ($private -eq $false) -and ($public -eq $false))
	{
		Throw "You must specify at least one set of values to return. Use -g for global values, -d for domain profile values, -pri for private profile values, -pub for public profile values"
	}
	
	Invoke-Command -Computer $computer -ScriptBlock {
		$firewallDetails = New-Object PSObject 

		If($args[0].IsPresent -eq $true)
		{
			$queryResult = netsh advfirewall show global
			for($i=0;$i -le $queryResult.GetUpperBound(0);$i++)
			{
				$matches = $null
				$regexResult = $queryResult[$i] -match "(.+[ ]{2,})(.*)"
				if($matches.count -eq 3) 
				{
					Add-Member -InputObject $firewallDetails -Type NoteProperty -Name "Global_$($matches[1])" -value $matches[2]
				}
	
			}
		}

		If($args[1].IsPresent -eq $true)
		{
			$queryResult = netsh advfirewall show domain
			for($i=0;$i -le $queryResult.GetUpperBound(0);$i++)
			{
				$matches = $null
				$regexResult = $queryResult[$i] -match "(.+[ ]{2,})(.*)"
				if($matches.count -eq 3) 
				{
					Add-Member -InputObject $firewallDetails -Type NoteProperty -Name "Domain_$($matches[1])" -value $matches[2]
				}
	
			}
		}
		
		if($args[2].IsPresent -eq $true)
		{
			$queryResult = netsh advfirewall show private
			for($i=0;$i -le $queryResult.GetUpperBound(0);$i++)
			{
				$matches = $null
				$regexResult = $queryResult[$i] -match "(.+[ ]{2,})(.*)"
				if($matches.count -eq 3) 
				{
					Add-Member -InputObject $firewallDetails -Type NoteProperty -Name "Private_$($matches[1])" -value $matches[2]
				}
	
			}
		}

		if($args[3].IsPresent -eq $true)
		{
			$queryResult = netsh advfirewall show public
			for($i=0;$i -le $queryResult.GetUpperBound(0);$i++)
			{
				$matches = $null
				$regexResult = $queryResult[$i] -match "(.+[ ]{2,})(.*)"
				if($matches.count -eq 3) 
				{
					Add-Member -InputObject $firewallDetails -Type NoteProperty -Name "Public_$($matches[1])" -value $matches[2]
				}
	
			}
		}
		
		Return $firewallDetails 
	} -Args $global,$domain,$private,$public 
	
}
