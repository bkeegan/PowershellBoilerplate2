<# 
.SYNOPSIS 
	Converts CIDR notation to subnet address.
.DESCRIPTION 
	Calcualtes a subnet address based on CIDR notation. Alternatively this ccmdlet can return the number of hosts in a subnet. 
	This cmdlet requires the cmdlet ConvertTo-Decimal, which is a non-standard cmdlet and is available from the same repository as this cmdlet.
.NOTES 
    File Name  : ConvertTo-Subnet.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-ConvertTo-Subnet -c "/24"
	This command will return the subnet mask associated with the CIDR notation of /24 (255.255.255.0 in this case)
.EXAMPLE 
	Get-ConvertTo-Subnet -c "/16" -h
	This command will return the number of hosts in a network with the CIDR notation of /16 (65534 in this case). Subtracts 2 to account for network/broadcast address.
#> 

function ConvertTo-Subnet
{
        <# Description: This function takes cidr notation and outputs the corresponding subnet mask. This script can handle input with our without the preceeding forward-slash. 
        This function can optionally output the number of hosts instead of the subnet mask
        #>
		
		[cmdletbinding()]
		Param
		(
			[parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[alias("c")]
			$CIDR,

			[parameter(Mandatory=$false)]
			[alias("h")]
			[switch]$numberOfHosts
		)
		
        #strips out leading / - will do nothing if no / is present
        $CIDR = $CIDR -Replace "\/", ""
		#strips out leading \ if user erroneously used backslash
		$CIDR = $CIDR -Replace "\\", ""
		
		$invalidCIDRMsg = "Invalid CIDR notation. Please specify an integer between 0 and 32 with or without the proceeding slash"
		
		#convert to integer - will fail if input contains something else besides a number
		Try
		{
			$CIDR = [int]$CIDR
		}
		Catch
		{
			Throw $invalidCIDRMsg
		}
		
		if(($CIDR -lt 0) -or ($CIDR -GT 32))
		{
			Throw $invalidCIDRMsg
		}
		
        $hostbits = (32 - [int]$CIDR) #get the number of bits for the host
        if($numberOfHosts -eq $true)
        {
			return [math]::pow(2,$hostbits) - 2 # Calculate total number of addrs minus network and broadcast
        }
        else
        {
			#begin looping starting at one and going to 4 (each loop represents one octet) 
			for($i=1; $i -le 4; $i++)
			{        
				#set subnetBinary to an empty string - reset at the beginning holds one octet in binary
				$subnetBinary = ""
				for($q=1; $q -le 8;$q++)
				{
					#loop to 8 - each binary digit in octet
					if(($i*8 + $q)-8 -le $CIDR)
					{
						#if current position in total subnet is less than cidr still in mask - write a 1
						$subnetBinary = $subnetBinary + "1"
					}
					else
					{
						#now in host portion of subnet - write a 0
						$subnetBinary = $subnetBinary + "0"
					}
				}
				#append the octet converted to decimal to the final output
				$subnetDecimal = $subnetDecimal + [string](ConvertTo-Decimal -b $subnetBinary)
				#if not on final octet append a .
				if($i -lt 4)
				{
					$subnetDecimal = $subnetDecimal + "."
				}
			} 
		
			return $subnetDecimal
        }
}
