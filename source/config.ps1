$null_char = [regex]::Unescape("\u0000")

function config-parse($file) {
  $config = @{}

  if (-not (test-path $file)) {
    throw "file not found: $file"
  }

  $input = get-content $file
  $input = $input -replace "::", $null_char

  $index = 0
  $name = $null

  $input | % { 
    $index++
    $line = $_.trim() 
    $splat = $line -split ":"
    if ($splat.length -gt 2) {
      throw "config error at line ${index}: $line"
    }
    if ($splat.length -eq 2) {
      $name, $value = $splat[0..1]
      config-set-value $config $name $value $index $line
    }
    elseif ($splat.length -eq 1) {
      $value = $splat[0]
      if (-not $name) {
        throw "config error at line ${index}: $line"
      }
      config-set-value $config $name $value $index $line
    }
  }

  $config.GetEnumerator() | % {
    $name = $_.name
    $target = $_.value
    if ($target.name -eq $null) {
      throw "missing config property: $name.name"
    }
    if ($target.name -eq "") {
      throw "missing config property: $name.name cannot be empty"
    }
    if ($target.cflags -eq $null) {
      throw "missing config property: $name.cflags"
    }
  }

  return $config
}

function config-set-value($config, $name, $value, $index, $line) {
  $name = ($name -replace $null_char, ":").trim()
  $value = ($value -replace $null_char, ":").trim()

  $splat = $name -split "\."
  if ($splat.length -lt 2) {
    throw "config error at line ${index}: $line"
  }

  $target = $splat[0]
  $property = $splat[1..$splat.length] -join "."

  if (-not $config[$target]) {
    $config[$target] = @{}
  }

  if ($config[$target][$property])
  {
    $config[$target][$property] += " " + $value
  }
  else
  {
    $config[$target][$property] = $value
  }
}
