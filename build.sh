#!/bin/bash -ex

rm -rf cbinding/install
rm -rf pybinding

REPO=guyutongxue/genius-invokation
RUN_ID=12219664086

if [ ! -d "pybinding" ]; then
	gh run download ${RUN_ID} \
		-R ${REPO} \
		-n pybinding-source \
		-D pybinding
fi

if [ ! -d "cbinding" ]; then
	gh run download ${RUN_ID} \
		-R ${REPO} \
		-p 'cbinding-library-*' \
		-D cbinding
fi

pushd pybinding
rm -f pyproject.toml requirements.txt setup.py
cp ../pyproject.toml .
mkdir src
mv gitcg src
uv sync

mkdir ../cbinding/install
cp -r ../cbinding/cbinding-library-Linux-x86_64/include ../cbinding/install
uv run scripts/build_ffi.py
mv gitcg/_gitcg_cffi.py src/gitcg

cp ../cbinding/cbinding-library-Linux-x86_64/lib/libgitcg.so gitcg && uv build && rm gitcg/libgitcg.*
uv run wheel tags --remove --platform-tag=manylinux_2_27_x86_64 dist/*any.whl
cp ../cbinding/cbinding-library-Windows-x86_64/lib/gitcg.lib gitcg && uv build && rm gitcg/gitcg.*
uv run wheel tags --remove --platform-tag=windows_x86_64 dist/*any.whl
cp ../cbinding/cbinding-library-macOS-x86_64/lib/libgitcg.dylib gitcg && uv build && rm gitcg/libgitcg.*
uv run wheel tags --remove --platform-tag=macosx_12_0_x86_64 dist/*any.whl
cp ../cbinding/cbinding-library-macOS-arm64/lib/libgitcg.dylib gitcg && uv build && rm gitcg/libgitcg.*
uv run wheel tags --remove --platform-tag=macosx_12_0_arm64 dist/*any.whl
popd