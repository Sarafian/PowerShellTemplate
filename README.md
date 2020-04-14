[![Build status](https://ci.appveyor.com/api/projects/status/1awhp4jaw94ed4m3/branch/master?svg=true)](https://ci.appveyor.com/project/Alex61243/powershelltemplate/branch/master)

# PowerShell Template 

This is a template repository for PowerShell modules and scripts. Template contains concepts such as

- Directory structure
  - Modules
  - Scripts
  - Tests
- CI
  - Testing
  - Manifest generation
  - Publishing

There are two main folders within the `src` directory

- `Modules` that contains the root folder for each module. Within the folder, the manifest `.psd1` is not present and is excluded from source control. During publishing, the manifest file will be generated by leveraging the information found in the `.psm1` file. Because the publish engine support auto-increment on the minor version, for this reason the manifest is not source controlled.
- `Scripts` that contains different script files. Each file must contain a `<#PSScriptInfo #>` tag that is required by the publishing engine of `Publish-Script`. For this reason auto-increment is not supported as the information is source controlled.

Each module has a `Public` and `Private` sub folder that contain the exported and not functions of the module respectively. The publish engine will figure out the public functions and include them in the manifest. Each cmdlet can be paired with a `.Tests.ps1` file that contains the tests for [Pester].

In a similar fashion, there is the `Tests` folder that contains the module and script tests. The helper function `Get-RandomValue` is provided in two forms.
1. As an independent script to import with dot sourcing e.g. in [Test-M1.Tests.ps1](Src/Tests/Modules/M1/Test-M1.Tests.ps1) with `. $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1`.
1. As a cmdlet within the `Helper` module to be used in e.g.  [Test-M1.Tests.ps1](Src/Tests/Modules/M1/Test-M1.Tests.ps1) with `& $PSScriptRoot\..\..\Helpers\Import-Helper.ps1` instead of `. $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1`.

Notice that the implementation of the independent function to dot source [Test-M1.Tests.ps1](Src/Tests/Modules/M1/Test-M1.Tests.ps1) is declaring the function with `global` until the raised issue [With InModuleScope, cmdlets or modules loaded before InModuleScope throw CommandNotFoundException upon access within InModuleScope] is resolved.

The `CI` folder contains scripts to run tests and publish modules. For the purpose of this repository, there is a `Mock` folder as well that allows publishing to a local file based PowerShell repository. This mocked concept should not be copied elsewhere and the related functionality should be removed by the mock scripts. When the publish scripts are invoked without a `NuGetAPIKey` then the flow will execute as normal and if the flow would new to publish a module or a script it will invoke `Publish-Module` and `Publish-Script` with the `-WhatIf` parameter.

# AppVeyor specifics

The included `AppVeyor.yml` will execute the publish scripts but without any `NuGetAPIKey`. When copying the structure you need to follow the instruction for secure variables in AppVeyor's [Build Configuration]. Then the variable needs to be passed to the publish script. Also, you would probably want to publish only when building the master branch.

```yaml
version: 1.0.{build}
image: Ubuntu1804
init:
- pwsh: Get-ChildItem ENV:\
install:
- pwsh: # Install-Module -Name Pester -Scope CurrentUser -Force  
build: off
test_script:
- pwsh: '& .\CI\Invoke-Test.ps1 -AppVeyor'
for:
-
  branches:
    only:
      - master 
    environment:
        NuGetAPIKey:
            secure: <encrypt_value>
    deploy_script:
    - pwsh: >-
        & .\CI\Publish-Module.ps1 -NuGetAPIKey $env:NuGetAPIKey

        & .\CI\Publish-Script.ps1 -NuGetAPIKey $env:NuGetAPIKey
```


# Pending items

- Publishing with semantic versioning for AutoIncrement
- Azure DEVOPS yaml file
- VSCode build actions

[Pester]: https://github.com/pester/Pester
[With InModuleScope, cmdlets or modules loaded before InModuleScope throw CommandNotFoundException upon access within InModuleScope]: https://github.com/pester/Pester/issues/1461
[Build configuration]: https://www.appveyor.com/docs/build-configuration/#secure-variables