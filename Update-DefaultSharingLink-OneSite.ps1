
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

# CONNECT
Connect-SPOService -Url https://octoeeo-admin.sharepoint.com

    <# Enumerated options

    AnonymousAccess - anyone with link
    Direct - people with existing access
    Internal - people in org with link
    None - people in org with link

    #>

# --- UPDATE A SINGLE SITE --------



    # Update a site
    Set-SPOSite -Identity https://octoeeo.sharepoint.com/sites/AaronPrivate -DefaultSharingLinkType Direct

    # Check setting
    Get-SPOSite -Identity https://octoeeo.sharepoint.com/sites/AaronPrivate | Select DefaultSharingLinkType 

# --- LOOP ALL SITES ------------

# Get all site collections
$sites = Get-SPOSite -Limit All

Write-Host "Total Sites: " $sites.Count


# Loop through each site collection and update value
[int]$None = 0
[int]$Direct = 0
[int]$Internal = 0
foreach ($site in $sites) {
    Write-Output "Site Title: $($site.Title) | Site URL: $($site.Url) | Default Sharing Link Type: $($site.DefaultSharingLinkType)"
    Set-SPOSite -Identity https://octoeeo.sharepoint.com/sites/AaronPrivate -DefaultSharingLinkType Direct
}

# Loop through each site collection to collect information
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


