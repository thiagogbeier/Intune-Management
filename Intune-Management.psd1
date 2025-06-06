@{
    # Module manifest for module 'Intune-Management'
    RootModule        = 'Intune-Management.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'f4c3b7e1-c3d2-4d1f-bffa-5a92f6dbf1e0'  # You can generate your own GUID if you want
    Author            = 'Thiago Beier'
    CompanyName       = 'BEIER IT'
    Description       = 'Module to manage Intune ImportPFX Connector display names and related functions.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Update-IntuneConnectorDisplayName', 'Get-IntuneConnectorServices', 'Connect-ToMgGraph')
    # No invalid members like FilesToInclude or FilesToExclude
}
