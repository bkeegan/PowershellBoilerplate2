<# 
.SYNOPSIS 
	Queries whether or not a specified Windows Update (by KB number) is installed on Domain computers in a specified OU
.DESCRIPTION 
    Runs the "Get-Hotfix" cmdlet against all computers in a specified OU and queries for the presence of a particular update (referenced by the KB number). It can return hosts that both have it missing or present and can optionally include or exclude hosts that are unreachable. Can be displayed on the screen or exported to CSV
.NOTES 
    File Name  : Get-KBStatusofDomainComputers.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-KBStatusofDomainComputers -kb "KB1234567" -ou "OU=Corp Computers,DC=contoso,DC=com" -p 
	This command will display which computersin the Corp Computers OU have the update KB1234567 installed 
.EXAMPLE 
	Get-KBStatusofDomainComputers -kb "KB1234567" -ou "OU=Corp Computers,DC=contoso,DC=com" -m -ho -CSV "C:\Reports\UpdateStatus.csv"
    This command will export the hostnames of which computers in the Corp Computers OU do not have the update KB1234567 installed.
#> 

Function Get-KBStatusofDomainComputers
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("kb")]
		[string]$kbNumber,
		
		[parameter(Mandatory=$true)]
		[alias("ou")]
		[string]$ouSearchBase,
		
		[parameter(Mandatory=$false)]
		[alias("t")]
		[int]$timeout=300,

        [parameter(Mandatory=$false)]
		[alias("m")]
	    [switch]$reportMissing,

        [parameter(Mandatory=$false)]
		[alias("p")]
	    [switch]$reportPresent,

        [parameter(Mandatory=$false)]
		[alias("u")]
	    [switch]$reportUnreachable,

        [parameter(Mandatory=$false)]
		[alias("uk")]
	    [switch]$reportUnknown,
		
        [parameter(Mandatory=$false)]
		[alias("to")]
	    [switch]$reportTimeouts,
		
        [parameter(Mandatory=$false)]
		[alias("csv")]
	    [string]$ExportToCSV,

        [parameter(Mandatory=$false)]
		[alias("ho")]
	    [switch]$hostnamesOnly
	)

    import-module activedirectory
    $adComputers = Get-AdComputer -filter * -searchbase $ouSearchBase
    #$timeout = 300
    $computerResults = @{}

    foreach($adComputer in $adComputers)
    {
    
        #reset result values from previous PC
        $result = $NULL
        $filteredResult = $NULL

        #ping desktop - if pinable, run the cmdlet "get-hotfix" as a job with a timeout value of $timeout (in seconds). Receive the value from job and store in variable $result
	    if(Test-Connection $adComputer.DNSHostName -ErrorAction "SilentlyContinue")
	    {
            #invoke the command on the remote host - waiting the value specified in $timeout
            $jobInfo = Invoke-Command -Computername $adComputer.DNSHostName -ScriptBlock { get-hotfix } -asJob | Wait-Job -timeout $timeout 
            #after the timeout period has elapsed, receive whatever the job returned with - if it completed successfully it will be the results of the "get-hotfix" command on the remote host, if it did not complete within the timeout period, it will be $NULL
            $result = Receive-job $jobInfo
            #kill the job - even though script will continue, if it hangs on an individual host it will still be running in the background - this cleans it up
            Stop-Job $jobInfo
            $pingable = $true
	    }
        else
        {
            $pingable = $false
        }
    
    
        #if result is not null (which means the PC was reachable and returns a value within the timeout period, filter the results for the matching KB
        if($result)
        {
            $filteredResult = $result | where {$_.hotfixid -eq $kbNumber} 
        }
    

        #if the PC was reachable, but the variable $filtereResults is null it means that the update was not installed 
        if((!$filteredResult) -and ($pingable -eq $true))
        {
           
           if($reportMissing)
           {
                $computerResults.Add($adComputer.DNSHostName,"Update Not Installed")
           }

        }
   
       #if the variable $results is null but the PC was pingable, it means the operation timed out (or encountered another error)
        elseif((!$result) -and ($pingable -eq $true))
        {
           if($reportTimeouts)
           {
                $computerResults.Add($adComputer.DNSHostName,"Operation Timed Out")
           }
        }
    
        #host is unreachable
        elseif($pingable -eq $false)
        {
           
           if($reportUnreachable)
           {
                $computerResults.Add($adComputer.DNSHostName,"Host not reachable")
                #not reachable
           }
        }
    
        #if filteredResults contains a value, it must be the update that was queried for
        elseif($filteredResult)
        {
           
           if($reportPresent)
           {
                $computerResults.Add($adComputer.DNSHostName,"Update present")
                #update is installed
           }
        }
       
    
        else
        {
            if($reportUnknown)
            {
                   $computerResults.Add($adComputer.DNSHostName,"Unknown")
                   #no known outcome
            }
        }
   
    }
    if(!$hostnamesOnly)
    {
        $objComputerResults = $computerResults.getEnumerator() | foreach {new-object -typename psobject -property @{DNSName = $_.name ; Status = $_.value}} 
    }

    else
    {
        $objComputerResults = $computerResults.getEnumerator() | foreach {new-object -typename psobject -property @{DNSName = $_.name}} 
    }


    If($ExportToCSV)
    {
        $objComputerResults | export-csv $ExportToCSV -NoTypeInformation
    }
    else
    {
        $objComputerResults
    }
} 
