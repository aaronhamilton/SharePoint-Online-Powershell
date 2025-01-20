# CONNECT
Connect-SPOService -Url https://octoeeo-admin.sharepoint.com


# --- LOOP ALL SITES ------------

# Get all site collections
$sites = Get-SPOSite -Limit All

Write-Host "Total Sites: " $sites.Count

# Loop through each site collection
[int]$None = 0
[int]$Direct = 0
[int]$Internal = 0
foreach ($site in $sites) {
    Write-Output "Site Title: $($site.Title)"
    Write-Output "Site URL: $($site.Url)"
    Write-Output "Default Sharing Link Type: $($site.DefaultSharingLinkType)"
    if ($site.DefaultSharingLinkType -eq "None") { $None++ }
    if ($site.DefaultSharingLinkType -eq "Direct") { $Direct++ }
    if ($site.DefaultSharingLinkType -eq "Internal") { $Internal++ }
    # Add any additional actions you want to perform on each site
}

Write-Host
Write-Host "Total Sites: " $sites.Count -ForegroundColor Yellow
Write-Host
Write-Host "Default Sharing Link" -ForegroundColor Yellow
Write-Host " - None = $None sites" -ForegroundColor Yellow
Write-Host " - Direct = $Direct sites" -ForegroundColor Yellow
Write-Host " - Internal = $Internal sites" -ForegroundColor Yellow


