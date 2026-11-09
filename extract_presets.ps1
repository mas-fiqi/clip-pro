$file = "c:\flater\video_clipper_app\lib\core\services\animation_presets_data.dart"
$lines = Get-Content $file
$currentId = ""
$currentName = ""
$currentCat = ""
$currentType = ""
$currentDesc = ""

$results = [System.Collections.Generic.List[PSObject]]::new()

foreach ($line in $lines) {
    if ($line -match "id:\s*'([^']+)'") { $currentId = $matches[1] }
    if ($line -match "name:\s*'([^']+)'") { $currentName = $matches[1] }
    if ($line -match "category:\s*AnimationCategory\.(\w+)") { $currentCat = $matches[1] }
    if ($line -match "type:\s*AnimationApplicationType\.(\w+)") { $currentType = $matches[1] }
    if ($line -match "description:\s*'([^']+)'") { 
        $currentDesc = $matches[1]
        $results.Add([PSCustomObject]@{
            Id = $currentId
            Name = $currentName
            Category = $currentCat
            Type = $currentType
            Desc = $currentDesc
        })
    }
}
$results | Export-Csv -Path "C:\flater\video_clipper_app\presets_catalog_raw.csv" -NoTypeInformation -Encoding utf8
Write-Output "Total extracted: $($results.Count)"
