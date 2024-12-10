#!/bin/bash -ex

rm -rf cbinding/install
rm -rf pybinding

REPO=guyutongxue/genius-invokation
RUN_ID=12248612441

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

cp -r cbinding/cbinding-library-Linux-x86_64 cbinding/install
pushd pybinding
uv run scripts/build_ffi.py
bash -ex scripts/build.sh Linux-x86_64
bash -ex scripts/build.sh Windows-x86_64
bash -ex scripts/build.sh macOS-x86_64
bash -ex scripts/build.sh macOS-arm64
popd
