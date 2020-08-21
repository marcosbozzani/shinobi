$erroractionpreference = "stop"

$new_line = "`r`n"

function include-script($name) {
    $content = get-content $PSScriptRoot\source\${name}.ps1
    return "$($content -join $new_line)$new_line$new_line"
}

function create-rules($name) {
    $rules = get-content $PSScriptRoot\source\rules.$name -encoding byte
    $rules_b64 = [convert]::tobase64string($rules)
    $result = "function rules_$name {$new_line"
    $result += "  return [Text.Encoding]::UTF8.GetString([convert]::frombase64string(`"$rules_b64`"))$new_line"
    $result += "}$new_line$new_line"
    return $result
}

$output = include-script main
$output += include-script config
$output += create-rules ninja 
$output += create-rules make
$output += "main$new_line"

md -force $PSScriptRoot\target | out-null
$output | out-file $PSScriptRoot\target\shinobi.ps1 -encoding ascii