param(
    [switch]$OnlyName=$false
)
$mockRepositoryPath=Join-Path $PSScriptRoot -ChildPath Repository
$name="MOCK:"+(Split-Path -Path $PSScriptRoot -Parent|Split-Path -Leaf)
if($OnlyName)
{
    $name
}
else {
    @{
        SourceLocation=$mockRepositoryPath
        PublishLocation=$mockRepositoryPath
        Name=$name
    }
}
