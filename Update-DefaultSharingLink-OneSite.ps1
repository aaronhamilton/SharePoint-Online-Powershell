
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




