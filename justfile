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

# builds/rebuilds mpy-cross --- needed if micropython or the .mpy format
# changes
build-mpy-cross:
	make -C mpy-cross

install: reqs submodules build-mpy-cross

# builds the uf2 using the given number of CPU cores
#
# find the number of available cores using `just numcpus`
#
# NOTE: must be ran after running `source ./venv/bin/activate`, which cannot be
# run from within just
uf2 CPUS:
	# make -C ./ports/raspberrypi/ -j{{CPUS}} BOARD=raspberry_pi_pico
	make -C ./ports/raspberrypi/ -j{{CPUS}} BOARD=proto_v1.1

# returns the number of available CPU cores
numcpus:
	getconf _NPROCESSORS_ONLN
