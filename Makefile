default: serve

build:
	julia --project make.jl

instantiate:
	julia --project -e 'using Pkg; Pkg.instantiate()'

serve: instantiate
	julia --project -e 'using LiveServer; LiveServer.servedocs(; foldername=pwd(), host="0.0.0.0", port=8080)'

.PHONY: build instantiate serve
