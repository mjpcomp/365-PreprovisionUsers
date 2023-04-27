# Set your SharePoint Tenant name below, typically it's https://businessname-admin.sharepoint.com
# In this case, set the $tenantName varible to the BusinessName (without the -admin, we'll add that automatically)
# This script will require some PowerShell add-ins, mainly the SharePoint online management shell

$tenantName = "MyBizName"
# Connect-MsolService -Credential $Credential
Connect-SPOService -Url https://$tenantName-admin.sharepoint.com
Connect-AzureAD

#Get licensed users and initiate their OneDrive creation
$users = Get-AzureAdUser -All $true | ForEach { $licensed=$False ; For ($i=0; $i -le ($_.AssignedLicenses | Measure).Count ; $i++) { If( [string]::IsNullOrEmpty(  $_.AssignedLicenses[$i].SkuId ) -ne $True) { $licensed=$true } } ; If( $licensed -eq $true) { Return $_.UserPrincipalName} }
#total licensed users
$count = $users.count

Write-Host "There are $count Licensed Users that will have a OneDrive For Business initialized for them."
Write-Host "Please wait..."

Get-AzureAdUser -All $true | 
ForEach {
	$licensed=$False
	For ($i=0; $i -le ($_.AssignedLicenses | Measure).Count ; $i++) {
		If( [string]::IsNullOrEmpty(  $_.AssignedLicenses[$i].SkuId ) -ne $True) {
			$licensed=$true 
		} 
	}
	If( $licensed -eq $true) { 
	Write-Host "Setting up $_.UserPrincipalName"
    Request-SPOPersonalSite -UserEmails $_.UserPrincipalName -NoWait
    Start-Sleep -Milliseconds 655
	}
}

Write-Host "Process is Complete..."
