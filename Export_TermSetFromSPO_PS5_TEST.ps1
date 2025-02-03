#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
   
#Variables for Processing
$AdminURL = "https://octoeeo-admin.sharepoint.com/"
$TermGroupName = "OCT\POLICY"
$TermSetName = "Legal Opinion Topics"
$CSVFile="C:\TermSetData_LegalOpinions.csv"
 
Try {
    #Get Credentials to connect
    $Cred = Get-Credential
    $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
 
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($AdminURL)
    $Ctx.Credentials = $Credentials
 
    #Get the term store
    $TaxonomySession=[Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($Ctx)
    $TermStore =$TaxonomySession.GetDefaultSiteCollectionTermStore()
    $Ctx.Load($TaxonomySession)
    $Ctx.Load($TermStore)
    $Ctx.ExecuteQuery()
 
    #Get the Term Group
    $TermGroup=$TermStore.Groups.GetByName($TermGroupName)
 
    #Get the term set
    $TermSet = $TermGroup.TermSets.GetByName($TermSetName)
 
    #Get all tersm from the term set
    $Terms = $TermSet.Terms
    $Ctx.Load($Terms)
    $Ctx.ExecuteQuery()
 
    Write-Output $TermsetName > $CSVFile
    #Export Terms to CSV
    Foreach($Term in $Terms)
    {
        Write-Output $Term.Name >> $CSVFile
    }    
    Write-host "Term Set Data Exported Successfully!" -ForegroundColor Green
}
Catch {
    write-host -f Red "Error Exporting Term Set!" $_.Exception.Message
}


#Read more: https://www.sharepointdiary.com/2016/12/sharepoint-online-powershell-to-export-term-set-to-csv.html#ixzz8zDkJXyGk