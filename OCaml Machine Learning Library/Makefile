MLS=lib/archive.ml lib/differentiable.ml lib/loss.ml lib/num.ml lib/perceptron.ml \
lib/authors.ml lib/fstream.ml lib/matrix.ml lib/parse.ml lib/convolution.ml \
lib/layer.ml lib/network.ml lib/perceptron_biases.ml

MLIS=lib/archive.mli lib/convolution.mli lib/loss.mli lib/network.mli \
lib/num.mli lib/authors.mli lib/fstream.mli lib/matrix.mli

default:
	dune utop lib

build:
	dune build -p ann

basic:
	dune build examples/basic/main.exe

run:
	dune exec examples/$(ex)/main.exe

test:
	dune runtest --force

bisect:
	rm -f `find . -name 'bisect*.out'`
	BISECT_ENABLE=YES dune runtest --force
	bisect-ppx-report -I _build/default/ -html report/ \
		`find . -name 'bisect*.out'`

docs:
	dune build @doc

clean:
	dune clean
	rm -f `find . -name 'bisect*.out'`
