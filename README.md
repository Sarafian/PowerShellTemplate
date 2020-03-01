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

# Pending items

- Publishing with semantic versioning for AutoIncrement
- Azure DEVOPS yaml file
- Re-enable `InModuleScope` tests pending issue [With InModuleScope, cmdlets or modules loaded before InModuleScope throw CommandNotFoundException upon access within InModuleScope](https://github.com/pester/Pester/issues/1461)
- VSCode build actions
