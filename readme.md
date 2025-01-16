# Helmer

Helmer is a bash-based application that provides functionality similar to the helm package command, with the added benefit of allowing you to override the values.yaml file. The primary use of Helmer is with CI/CD pipelines.

## Prerequisites
* **Helm 3** installed
* **yq** installed: https://github.com/mikefarah/yq

## Installation
`curl -s https://raw.githubusercontent.com/royalsarkis/helmer/main/helmer.sh -o ~/bin/helmer && chmod +x ~/bin/helmer && export PATH=$PATH:~/bin
`
## Usage
`helmer package [chart directory] [--set key1=value] [--set key2=value] [--set key3.subkey1=value] ... 
`
## Docker
`docker run --rm -v $PWD:/out royalsarkis/helmer package [chart directory] [--set key1=value] [--set key2=value] [--set key3.subkey1=value] ...
`
## Contributing
If you wish to contribute to Helmer, please feel free to submit a pull request. Contributions are always welcome!
