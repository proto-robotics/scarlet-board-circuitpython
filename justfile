venv:
	[ ! -d ./venv ] || rm -rf ./venv
	python3 -m venv venv

reqs: venv
	./venv/bin/pip3 install --upgrade -r ./requirements-doc.txt
	./venv/bin/pip3 install --upgrade -r ./requirements-dev.txt

# fetches all git submodules --- if modules are missing, try running this
#
# need to run once to install the missing module huffman
#
# will take multiple minutes to complete
submodules:
	make fetch-all-submodules

# fetches CircuitPython version tags, needed since this is a fork
tags:
	make fetch-tags

# builds/rebuilds mpy-cross --- needed if micropython or the .mpy format
# changes
build-mpy-cross:
	make -C mpy-cross

install: reqs submodules tags build-mpy-cross
	echo "NOW INSTALL arm-none-eabi"

# builds the uf2 for the given board (default proto_v3.5.0) using the given
# number of CPU cores, and copies it to ./build/<board>.uf2
#
# find the number of available cores using `just numcpus`
#
# NOTE: must be ran after running `source ./venv/bin/activate`, which cannot be
# run from within just
uf2 CPUS BOARD="proto_v3.5.0":
	echo "MAKE SURE YOU HAVE ACTIVATED VENV"
	make -C ./ports/raspberrypi/ -j{{CPUS}} BOARD={{BOARD}}
	mkdir -p ./build
	cp ./ports/raspberrypi/build-{{BOARD}}/firmware.uf2 ./build/{{BOARD}}.uf2
	echo "UF2 ready: ./build/{{BOARD}}.uf2 (copy it to the RPI-RP2 drive)"

# returns the number of available CPU cores
numcpus:
	getconf _NPROCESSORS_ONLN
