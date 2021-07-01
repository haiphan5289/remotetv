#!/bin/bash
#remove_unused_arch.sh
# This script should be called from Xcode project as a post-build action when publishing bundle to
# AppStore. It removes unused simulator architectures from embedded frameworks.


APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

framework_paths=($(find "${APP_PATH}" -type d -name '*.framework'))
for framework_path in "${framework_paths[@]}"; 
do
	framework_executable_name=$(defaults read "${framework_path}/Info.plist" CFBundleExecutable)
	framework_executable_path="${framework_path}/${framework_executable_name}"

	echo "Extracting unused architectures from framework: ${framework_executable_name}"

	extracted_archs=()
	for arch in ${ARCHS}; 
	do
		extracted_path="${framework_executable_path}_${arch}"
		lipo "${framework_executable_path}" -extract "${arch}" -output "${extracted_path}"
		extracted_archs+=("${extracted_path}")
	done
	
	echo "Merging extracted architectures: $(ARCHS)"
	lipo "${extracted_archs[@]}" -create -output "${framework_executable_path}_sliced"
	rm -f "${extracted_archs[@]}"
	
	echo "Replacing original executable with sliced version"
	rm -f "${framework_executable_path}"
	mv "${framework_executable_path}_sliced" "${framework_executable_path}"
done
