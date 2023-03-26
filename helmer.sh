#!/bin/bash

# Define the path to the YAML file you want to modify
function fill_values {
    # Parse the key-value pairs from the command line arguments
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            --set)
                YAML_KEY="${2%%=*}"
                YAML_VALUE="${2#*=}"
                shift # past key=value
                # Check if the key exists in the YAML file
                if [[ $(yq eval ".${YAML_KEY}" "$FILEPATH") == "null" ]]; then
                    echo "ERROR: Key ${YAML_KEY} does not exist in YAML file" >&2
                    exit 1
                elif [[ $(yq eval ".${YAML_KEY} | type" "$FILEPATH") == *"map"* ]]; then
                    echo "ERROR: Key ${YAML_KEY} has subkeys. You cannot change the format of the YAML file" >&2
                    exit 1
                else
                    # Use yq to modify the value in the YAML file
                    yq eval --inplace ".${YAML_KEY} = \"$YAML_VALUE\"" "$FILEPATH"
                fi
                ;;
            *)
                # unknown option
                shift # past argument
                ;;
        esac
    done
}

function package {
    args=("$@")
    helm_command="${args[0]} ${args[1]}"
    FILEPATH="${args[1]}/values.yaml"
    shift 2

    fill_values "$@"

    # Use eval to execute the helm command and check for errors
    if ! output=$(eval "helm $helm_command 2>&1"); then
        echo "$output" >&2
        exit 1
    fi
}

# Check for the argument and call the appropriate function
case $1 in
    package)
        package $@
        ;;
    *)
        echo "Usage: $0 package [helm command] [chart directory] [--set key=value]..."
        ;;
esac