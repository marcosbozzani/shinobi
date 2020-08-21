$erroractionpreference = "stop"

$root = $PSScriptRoot

function setup-test($builder) {
    md -force $root\target\$builder | out-null
    cp $root\test\build.config $root\target\$builder
    cp -recurse -force $root\test\source $root\target\$builder
}

function run-shinobi($builder) {
    cd $root\target\$builder
    & $root\target\shinobi -b $builder
}

function compare-files($file1, $file2) {
    if (compare $(get-content $root\$file1) $(get-content $root\$file2)) {
        throw "files are different $file1, $file2"
    }
}

function run-test($builder, $target) {
    cd $root\target\$builder
        
    & $builder -f "$target.$builder"
    if ($lastexitcode -ne 0) { 
        throw "$builder error"
    }

    compare-files test\$target.$builder target\$builder\$target.$builder
    ls $root\test\declaration | % {
        $name = $_
        compare-files test\declaration\$name target\$builder\$target\declaration\$name
    }
}

try {
    pushd

    & $root\build

    $builders = $args
    if ($builders.length -eq 0) {
        $builders = "ninja", "make"
    }

    $builders | % {
        $builder = $_
        setup-test $builder
        run-shinobi $builder
        "debug", "release" | % { 
            $target = $_
            run-test $builder $target
            "[TEST PASSED] $builder $target"
        }
    }
}
catch {
    "[TEST FAILED] " + $_.exception.message
}
finally {
    popd
}



