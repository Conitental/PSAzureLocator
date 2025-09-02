# Module manifest docs: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests

@{

  RootModule = 'PSAzureLocator.psm1'
  ModuleVersion = '0.0.1'
  GUID = 'c051482a-094e-4b8b-b0c3-26c508e02adb'
  Author = 'Conitental'
  Description = 'Module to locate a given Azure resource region based on its dns name or ip address'

  PrivateData = @{
    PSData = @{
      ProjectUri = 'https://github.com/Conitental/PSAzureLocator'
    }
  }

  RequiredModules = @(
    @(
        'Az.Accounts',
        'Az.Network'
    )
  )

  FunctionsToExport = @(
    'Get-AzResourceLocaton'
  )

}
