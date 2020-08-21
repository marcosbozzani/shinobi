param([validateset("ninja", "make")] $builder = "ninja")

$erroractionpreference = "stop"

function is-ninja() {
  return $builder -eq "ninja"
}

function main() {
  try {
    $config = config-parse build.config
    $config.GetEnumerator() | % {
      $target_dir = $_.name
      $target_name = $_.value.name
      $target_cflags = $_.value.cflags
      $out_file = "${target_dir}.$builder"

      create-build source $target_dir $target_name $target_cflags | out-file $out_file -encoding ascii

      "$out_file created"
    }
  }
  catch {
    $_.exception.message
  }
}

function create-build($source_dir, $target_dir, $target_name, $target_cflags) {

  $sources, $objects, $declarations = get-files $source_dir $target_dir

  if (is-ninja) { "builddir = $target_dir" }
  
  "cflags = -Isource -I$target_dir/declaration $target_cflags"
  ""

  if (is-ninja) { rules_ninja } else { rules_make }
  ""
  
  if (is-ninja) { 
    add-target all phony $target_dir/$target_name
  } 
  else { 
    add-target all phony "directories $target_dir/$target_name"
    add-target directories phony "$target_dir $target_dir/declaration $target_dir/object"
    add-target $target_dir mkdirp
    add-target $target_dir/declaration mkdirp
    add-target $target_dir/object mkdirp
  }
  
  add-target $target_dir/${target_name} link (split-files $objects)
  add-target declarations phony (split-files $declarations)

  $sources | % { 
    add-target $target_dir/object/$_.o compile "$source_dir/$_.c | declarations"
    if (test-path source/$_.h) {
      add-target $target_dir/declaration/$_.c.decl headsup_c "$source_dir/$_.c $source_dir/$_.h"
      add-target $target_dir/declaration/$_.h.decl headsup_h "$source_dir/$_.c $source_dir/$_.h" 
    }
    else {
      add-target $target_dir/declaration/$_.c.decl headsup_c $source_dir/$_.c
    }
  }

  if (-not (is-ninja)) {
    $sources | % {
      "-include $target_dir/object/$_.d"
    }
    ""
  }

  if (is-ninja) { "default all" } else { ".DEFAULT_GOAL: all" }
}

function get-files($source_dir, $target_dir) {
  if (-not (test-path $source_dir)) {
    $root = pwd
    throw "could not find the '$source_dir' directory in '$root'"
  }
  $sources = ls source/*.c | % { $_.basename }
  $objects = $sources | % { ";$target_dir/object/$_.o" }
  $declarations = $sources | % { 
    ";$target_dir/declaration/$_.c.decl"
    if (test-path source/$_.h) {
      ";$target_dir/declaration/$_.h.decl" 
    }
  }

  return $sources, $objects, $declarations
}

function split-files($files) {
  $line_cont = if (is-ninja) { "$" } else { "\" }
  return $files -replace ";", "$line_cont`r`n  "
}

function add-target($out, $command, $in) {
  if (is-ninja) {
    "build ${out}: $command $in"
  }
  else {
    if ($command -eq "phony") {
      ".PHONY: $out"
      "${out}: $in"
    }
    else {
      "${out}: $in"
      "`t`$(call $command,`$@,`$^)"
    }
  }
  ""
}
