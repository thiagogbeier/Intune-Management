<#
    Module: Intune-Management.psm1
    Author: Thiago Beier
    Description: Functions for managing Intune ImportPFX Connector display name.
#>

function Get-IntuneConnectorServices {
    $results = Get-CimInstance -ClassName Win32_Service |
    Where-Object { $_.DisplayName -like "PFX*" } |
    Select-Object DisplayName, State, StartName

    if ($results) {
        Write-Host ""
        Write-Host "Intune Certificate Connector Services Status" -ForegroundColor Green
        $results | Format-Table -AutoSize
    }
    else {
        Write-Warning "Intune Certificate Connector Services Status not found."
    }
}

# Ensure the Microsoft Graph module is imported
function Connect-ToMsGraph {
    [CmdletBinding()]
    param ()

    Write-Host "Checking Microsoft Graph SDK module..."

    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Beta.DeviceManagement.Administration)) {
        try {
            Write-Host "Installing Microsoft.Graph.Beta.DeviceManagement.Administration module..."
            Install-Module -Name Microsoft.Graph.Beta.DeviceManagement.Administration -Force -Scope CurrentUser -AllowClobber -Confirm:$false
        }
        catch {
            Write-Error "Failed to install module: $_"
            return
        }
    }
    else {
        Write-Host "Module already installed."
    }

    try {
        Write-Host "Importing module..."
        Import-Module Microsoft.Graph.Beta.DeviceManagement.Administration -Force -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to import module: $_"
        return
    }

    if (-not (Get-MgContext)) {
        Write-Host "Connecting to Microsoft Graph..."
        try {
            Connect-MgGraph -NoWelcome
        }
        catch {
            Write-Error "Failed to connect: $_"
        }
    }
    else {
        Write-Host "Already authenticated to Microsoft Graph."
    }
}

function Get-IntuneCertificateConnectorInfo {
    [CmdletBinding()]
    param ()

    # Search for the connector
    Write-Host "Searching for Certificate Connector for Microsoft Intune..."
    $script:IntuneCertConnectorInfo = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -eq "Certificate Connector for Microsoft Intune" } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

    if ($script:IntuneCertConnectorInfo) {
        Write-Verbose "Certificate Connector for Microsoft Intune found."
    }
    else {
        Write-Verbose "Certificate Connector for Microsoft Intune not found."
        $script:IntuneCertConnectorInfo = @()
    }

    return $script:IntuneCertConnectorInfo
}


# Example usage
#Get-IntuneCertificateConnectorInfo

# Now you can reuse $script:IntuneCertConnectorInfo in other functions or logic


function Update-IntuneConnectorDisplayName {
    [CmdletBinding()]
    param ()

    # Ensure the Microsoft Graph module is imported
    Connect-ToMsGraph

    # Check for registry key
    $registryKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MicrosoftIntune\PFXCertificateConnector" -ErrorAction SilentlyContinue

    # Get the most recent certificate issued by Intune ImportPFX Connector CA
    $result = Get-ChildItem -Path Cert:\LocalMachine\My |
    Where-Object { $_.Issuer -match "CN=Microsoft Intune ImportPFX Connector CA" } |
    Sort-Object NotBefore -Descending |
    Select-Object -First 1 -Property NotBefore, NotAfter, Subject, Thumbprint -ErrorAction SilentlyContinue

    Write-Host ""

    if ($result.Thumbprint -and $registryKey.EncryptionCertThumbprint) {
        Write-Host "Certificate thumbprint matches registry key."

        # Extract local machine certificate subject to match with Intune Connector ID
        $ndesConnectorId = $result.Subject -replace "^CN=", ""

        # Get connector info from Microsoft Graph Beta API
        $intuneCertConnector = Get-MgBetaDeviceManagementNdeConnector -NdesConnectorId $ndesConnectorId
        Write-Host "Existing Connector DisplayName: $($intuneCertConnector.DisplayName)"

        # Check if the connector ID matches
        if ($intuneCertConnector.Id -eq $ndesConnectorId) {
            if ($intuneCertConnector.DisplayName -like "*$env:COMPUTERNAME*") {
                Write-Host "Intune Certificate Connector is up to date"
            }
            else {
                $combined = "$env:COMPUTERNAME" + "_" + $intuneCertConnector.DisplayName

                $params = @{
                    id          = $intuneCertConnector.Id
                    displayName = $combined
                }

                Write-Host "Updating Intune Certificate Connector DisplayName to '$combined'..."
                Update-MgBetaDeviceManagementNdeConnector -NdesConnectorId $ndesConnectorId -BodyParameter $params

                Write-Host "Updated Connector:"
                #Get-MgBetaDeviceManagementNdeConnector -NdesConnectorId $ndesConnectorId

                #return $params
            }
        }
        else {
            Write-Warning "Connector ID mismatch."
        }
    }
    else {
        Write-Warning "Certificate thumbprint does not match registry key or Intune Connector not installed."
    }
    Write-Host ""

    
}

# NOTE: Do NOT run any commands on import.  
# This module only defines functions.  
# Run installation, import, and authentication commands outside the module.
