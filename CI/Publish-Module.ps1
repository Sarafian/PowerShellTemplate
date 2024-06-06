<#PSScriptInfo

.VERSION 1.0

.LASTUPDATE 20240606

#>

#Requires -Modules @{ ModuleName="SemVerPS"; ModuleVersion="1.0" }

param(
    [Parameter(Mandatory=$false)]
    [string]$NuGetApiKey=$null,
    [Parameter(Mandatory=$false)]
    [string]$Repository="PSGallery",
    [Parameter(Mandatory=$false)]
    [switch]$AutoIncrementMinor=$false,
    [Parameter(Mandatory=$false)]
    [switch]$Mock=$false,
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf=$false
)

#region To be removed when copying to other repository. Supporting mock publishing functionality
if($Mock)
{
    if(-not $WhatIf)
    {
        $NuGetApiKey="anything"
    }
    $Repository=& $PSScriptRoot\..\Mock\Get-MockRepositoryInfo.ps1 -OnlyName
    & $MyInvocation.MyCommand.Path -NuGetApiKey $NuGetApiKey -Repository $Repository -AutoIncrementMinor:$AutoIncrementMinor
    return 
}
#endregion

$sourceModuleItems=Get-ChildItem -Path "$PSScriptRoot\..\Src\Modules" -Directory

$sourceModuleItems |ForEach-Object {
    $sourceModuleItem=$_

    $moduleName=$sourceModuleItem.Name
    $modulePath=Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath $sourceModuleItem.Name
    $psm1Path=Join-Path $modulePath "$moduleName.psm1"
    $psd1Path=Join-Path $modulePath "$moduleName.psd1"

    Write-Debug "moduleName=$moduleName"
    Write-Debug "modulePath=$modulePath"
    Write-Debug "psm1Path=$psm1Path"
    Write-Debug "psd1Path=$psd1Path"

    Remove-Item -Path $modulePath -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path $sourceModuleItem.FullName -Destination $modulePath -Recurse -Exclude "*.Tests.ps1"

    $progressSplat=@{
        Activity=$moduleName
    }
    
    try {
    
        Write-Progress @progressSplat -Status "Exporting manifest"
        $psm1Source=Get-Content -Path $psm1Path -Raw
        Write-Debug "psm1Source=$psm1Source"
        $contentRegEx="<\#PSManifest[\r\n]+(?<content>[\s\S]+)\#>"
        Write-Debug "contentRegEx=$contentRegEx"
    
        if($psm1Source -notmatch $contentRegEx)
        {
            Write-Error "$psm1Path doesn't contain PSManifest tag"
            return -1
        }
        $content=$Matches["content"]
        Write-Debug "content=$content"
        $moduleHash=Invoke-Expression $content
    
        Write-Debug "Querying repository $Repository"
        Write-Progress @progressSplat -Status "Querying repository $Repository"
    
        $publishedModule=Find-Module -Name $moduleName -Repository $Repository -ErrorAction SilentlyContinue
        Write-Verbose "Queried $moduleName on $Repository"
        $shouldTryPublish=$false
        if($publishedModule)
        {
            $publishedVersion=$publishedModule.Version
            
            # Implicitly check the version of powershell and PowerShellGet module
            if($publishedVersion -is [string])
            {
                $publishedVersion=ConvertTo-SemVer -Version $publishedVersion
                $sourceModuleVersion=ConvertTo-SemVer -Version $moduleHash.ModuleVersion
            }
            else {
                $sourceModuleVersion=[System.Version]::Parse($moduleHash.ModuleVersion)
            }
            Write-Debug "publishedVersion=$publishedVersion"
            Write-Debug "sourceModuleVersion=$sourceModuleVersion"
    
            if($publishedVersion -lt $sourceModuleVersion)
            {
                Write-Host "Module $moduleName has source version $sourceModuleVersion that is higher than found published version $publishedVersion"
                $shouldTryPublish=$true
            }
            elseif($AutoIncrementMinor)
            {
                $moduleHash.ModuleVersion="$($publishedVersion.Major).$($publishedVersion.Minor+1)"
                Write-Debug "moduleHash.ModuleVersion=$moduleHash.ModuleVersion"
                Write-Host "Module $moduleName has new autoincremented minor $($moduleHash.ModuleVersion) from found published version $publishedVersion"
                $shouldTryPublish=$true
            }
            else
            {
                Write-Warning "Module $moduleName has source version $sourceModuleVersion that is not higher than found published version $publishedVersion. Will skip publishing"
            }
        }
        else
        {
            Write-Host "Module $moduleName is not yet published to the $Repository"
            $shouldTryPublish=$true
        }
    
        #region manifest
        Write-Debug "Generating manifest"
        Write-Progress @progressSplat -Status "Generating manifest"
    
        Import-Module $psm1Path -Force 
        $newModuleManifestSplat=@{}+$moduleHash
        $exportedNames=Get-Command -Module $moduleName | Select-Object -ExpandProperty Name
        Write-Debug "exportedNames=$($exportedNames -join ',')"
        $newModuleManifestSplat.Add("CmdletsToExport",$exportedNames)
        $newModuleManifestSplat.Add("FunctionsToExport",$exportedNames)
    
    <#
        $hash=@{
            "Author"=""
            "CompanyName" = ""
            "Copyright"=""
            "RootModule"=$psm1Name
            "Description"=$moduleDescription
            "Guid"=$guid
            "ModuleVersion"=$sourceVersion
            "Path"=$psd1Path
            "LicenseUri"='https://github.com/Sarafian/PowerShellTemplate/blob/master/LICENSE'
            "ProjectUri"= 'https://github.com/Sarafian/PowerShellTemplate/'
    #        "ReleaseNotes"= $releaseNotes -join [System.Environment]::NewLine
            "CmdletsToExport" = $exportedNames
            "FunctionsToExport" = $exportedNames
        }
    #>    
        New-ModuleManifest @newModuleManifestSplat -Path $psd1Path
    
        Write-Verbose "Generated manifest $psd1Path"
        
        #endregion
    
        if($shouldTryPublish)
        {
            Write-Debug "Publishing  $modulePath to $Repository"
            Write-Progress @progressSplat -Status "Publishing  $modulePath to $Repository"
            if($NuGetApiKey)
            {
                Publish-Module -Repository $Repository -Path $modulePath -NuGetApiKey $NuGetApiKey -Force
            }
            else
            {
                $mockKey="MockKey"
                Publish-Module -Repository $Repository -Path $modulePath -NuGetApiKey $mockKey -WhatIf
            }
            Write-Host "Published $modulePath"
        }
    }
    finally{
        Write-Progress @progressSplat -Completed
    }
}