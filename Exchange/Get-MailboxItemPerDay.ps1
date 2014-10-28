<# 
.SYNOPSIS 
	Calcualtes how many mailbox items (emails, calendar items, contacts etc) are created per day for a specified mailbox. 
.DESCRIPTION 
	Fetches the created date on the mailbox calculates how many days has passed since the mailbox was created. Divides "ItemCount" and "DeletedItemCount" by the total number of days the mailbox has existed. 
	This cmdlet returns the output of Get-MailBoxStatistics with an added property containing an average of how many items are created per day. 
.NOTES 
    File Name  : Find-ADEmailAddressOwner 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv3  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate2
    License: http://www.gnu.org/copyleft/gpl.html
.EXAMPLE 
	Get-MailboxItemPerDay -id "testUser" -cas "cas01.domain.com" 
	Returns the results of get-mailboxstatistics with the addition of how many mailbox items are generated per day on average (rounded up)
.EXAMPLE 
	Get-MailboxItemPerDay -id "testUser" -cas "cas01.domain.com" -nr
	Returns the results of get-mailboxstatistics with the addition of how many mailbox items are generated per day on average. This example includes the -nr switch will not round the result up.
#> 
function Get-MailboxItemPerDay 
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("id")]
		[string]$identity,
		
		[parameter(Mandatory=$true)]
		[alias("cas")]
		$casServer,
		
		[parameter(Mandatory=$false)]
		[alias("nr")]
		[switch]$doNotRound
	)
	
	#imports
	$session = New-PSSession -configurationname Microsoft.Exchange -connectionURI http://$casServer/PowerShell
	Import-PSSession $session 
	
	$mailbox = Get-Mailbox -id $identity 
	$totalTime = New-TimeSpan -start $($mailbox.whenCreated) -end (Get-Date)
	$mailboxStats = Get-MailboxStatistics -id $identity
	$totalItems = $mailboxStats.DeletedItemCount + $mailboxStats.ItemCount
	
	$ratio = [int]$totalItems/[int]$totalTime.TotalDays
	
	if($doNotRound -eq $false)
	{
		$ratio = [System.Math]::Round($ratio, 0)
	}
	
	$mailboxStats | Add-Member -Type NoteProperty -Name "ItemsPerDay" -Value $ratio
	Return $mailboxStats
	
}
