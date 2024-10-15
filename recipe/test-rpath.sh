#!/bin/bash

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

errors=""

echo "\$PKG_NAME: ${PKG_NAME}"

for bin in `find ${PREFIX}/bin -type f`; do
    pkg_info=$(conda package -w "${bin}")
    echo "\$PKG_NAME: ${PKG_NAME}"
    echo "\$pkg_info: ${pkg_info}"
    if [[ ! "$pkg_info" == *"$PKG_NAME"* ]]; then
        echo "Not a match"
        echo "Skipping ${bin}"
        continue
    else
        echo "Match found"
        echo "Testing ${bin}"
    fi
    rpath=$(patchelf --print-rpath "${bin}")
    echo "${bin} rpath: ${rpath}"
    if [[ $rpath != "\$ORIGIN/../lib:\$ORIGIN/../${targetsDir}/lib" ]]; then
        errors+="${bin}\n"
    elif [[ $(objdump -x ${bin} | grep "PATH") == *"RUNPATH"* ]]; then
        errors+="${bin}\n"
    fi
done

if [[ $errors ]]; then
    echo "The following binaries were found with an unexpected RPATH:"
    echo -e "${errors}"

    exit 1
else
    exit 0
fi
