<# Run this script in VS Code #>

#Install-Module -Name MSAL.PS

$Scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
cd $dir


$AdminCenterURL="https://octoeeo-admin.SharePoint.com"
$ClientID = '0d41b098-a79a-4288-a366-b4b8811c1d52' # Microsoft Graph PowerShell - High Privilege admin use only - Microsoft Azure 
$TenandID = '403b5de9-f888-4fef-9eea-bd256ecec060' # octoeeo
$MSGraphConnection = @()

function ConnectMSGraph() {
    if($null -eq $MSGraphConnection.Account ){
        #$connection = Connect-MgGraph -ClientId $ClientID -TenantId $TenandID -Scopes Group.Read.All,Directory.ReadWrite.All,Group.ReadWrite.All
        $connection = Connect-MgGraph -ClientId $ClientID -TenantId $TenandID -Scopes Group.Read.All,Directory.ReadWrite.All,Group.ReadWrite.All, User.ReadWrite.All, UserActivity.ReadWrite.CreatedByApp
        return $connection
    }
}

Import-Module PnP.PowerShell
#Import-Module Microsoft.Graph
#Import-Module Microsoft.Graph.Beta
Import-Module Microsoft.Graph.Identity.SignIns

# PnP.Powershell version 1.10
#$connection = Connect-PnPOnline -Interactive -Url $url -ReturnConnection 

# PnP.Powershell version 1.11


$url = "https://octoeeo.sharepoint.com/sites/TestTeam958"

Write-Host 
Write-Host "Connecting via PnPOnline..." -ForegroundColor Yellow
Write-Host 
if (-not($connection)) {
    Connect-PnPOnline -Url $url -UseWebLogin 
    $connection = Get-PnPConnection 
}

$connection
Write-Host; Write-Host "You are connected to $($connection.Url)"
Write-Host

# only proceed if connection has been established
if($null -eq $connection ){
    ShowMessage -text "Connection to PnP Online has not been establish. Please run the script again and enter your credentials" -MessageType Error
    return
}

Write-Host 
Write-Host "Connecting to MS Graph..." -ForegroundColor Yellow
Write-Host 
$MSGraphConnection = ConnectMSGraph

if ([Environment]::Is64BitProcess -ne [Environment]::Is64BitOperatingSystem)
{
    ShowMessage "Please run 64-bit version of PowerShell" -MessageType Error
}

#$Libraries = Get-PnPList

#Provide name of your List/Document library
$ListName = "Documents"

#Retrieve all Files from the document library
#$ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize 1000 | Where {$_["FileLeafRef"] -like "*.*"}

#$AllFiles = @() # Result array to keep all file details

$Ctx = Get-PnPContext
$Results = @()
$global:counter = 0
 
#Get all list items in batches
$ListItems = Get-PnPListItem -List $ListName -PageSize 2000
$ItemCount = $ListItems.Count


#Iterate through each list item
ForEach($Item in $ListItems)
{
    Write-Progress -PercentComplete ($global:Counter / ($ItemCount) * 100) -Activity "Getting Shared Links from '$($Item.FieldValues["FileRef"])'" -Status "Processing Items $global:Counter to $($ItemCount)";
 
    #Check if the Item has unique permissions
    $HasUniquePermissions = Get-PnPProperty -ClientObject $Item -Property "HasUniqueRoleAssignments"
    If($HasUniquePermissions)
    {       
        #Get Shared Links
        $SharingInfo = [Microsoft.SharePoint.Client.ObjectSharingInformation]::GetObjectSharingInformation($Ctx, $Item, $false, $false, $false, $true, $true, $true, $true)
        $ctx.Load($SharingInfo)
        $ctx.ExecuteQuery()
         
        ForEach($ShareLink in $SharingInfo.SharingLinks)
        {
            If($ShareLink.Url)
            {           
                If($ShareLink.IsEditLink)
                {
                    $AccessType="Edit"
                }
                ElseIf($shareLink.IsReviewLink)
                {
                    $AccessType="Review"
                }
                Else
                {
                    $AccessType="ViewOnly"
                }
                 
                #Collect the data
                $Results += New-Object PSObject -property $([ordered]@{
                Name  = $Item.FieldValues["FileLeafRef"]           
                RelativeURL = $Item.FieldValues["FileRef"]
                FileType = $Item.FieldValues["File_x0020_Type"]
                ShareLink  = $ShareLink.Url
                ShareLinkAccess  =  $AccessType
                ShareLinkType  = $ShareLink.LinkKind
                AllowsAnonymousAccess  = $ShareLink.AllowsAnonymousAccess
                IsActive  = $ShareLink.IsActive
                Expiration = $ShareLink.Expiration
                })
            }
        }
    }
    $global:counter++
}

$Results | Export-CSV ".\SharePoint-Files2.CSV" -NoTypeInformation -Encoding UTF8
Write-Host "SharePoint files report exported successfully" –f Green
