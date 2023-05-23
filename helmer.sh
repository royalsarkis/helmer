#!/bin/bash

# check if yq is installed
function check_yq {
    which yq > /dev/null
    if [[ $? != 0 ]]; then
        echo -e "\033[1m\033[31mWarning: Please Install yq in order to ensure the script functions correctly\033[0m"
        echo "https://github.com/mikefarah/yq"
        exit 1
    fi
}
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
                #Check if the key exists in the YAML file
                if [[ $(yq eval ".${YAML_KEY}" "$FILEPATH") == "null" ]]; then
                    echo "ERROR: Key ${YAML_KEY} does not exist in YAML file" >&2
                    exit 1
                elif [[ $(yq eval ".${YAML_KEY} | type" "$FILEPATH") == *"map"* ]]; then
                    echo "ERROR: Key ${YAML_KEY} has subkeys. You cannot change the format of the YAML file" >&2
                    exit 1
                else
                    # Use yq to modify the value in the YAML file
                     yq eval --inplace ".${YAML_KEY} = \"$YAML_VALUE\"" $FILEPATH
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
    check_yq
    while [[ $# -gt 0 ]]; do
        case $1 in
            --set)
                helmer_args+=("--set $2")
                shift 2
                ;;
            *)
                helm_args+=("$1")
                shift
                ;;
        esac
    done

    FILEPATH="${helm_args[1]}/values.yaml"

    # set values with fill_values function
    fill_values ${helmer_args[@]}

    # Use eval to execute the helm command and check for errors
    if ! output=$(eval "helm ${helm_args[@]} 2>&1"); then
        echo "$output" >&2
        exit 1
    fi
}

function help {

    # Display Help
    echo "
    Usage:
        $0 package [chart directory] [--set key=value]...

    Flags:
            --set stringArray          set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
            --app-version string       set the appVersion on the chart to this version
        -u, --dependency-update        update dependencies from "Chart.yaml" to dir "charts/" before packaging
        -d, --destination string       location to write the chart. (default ".")
        -h, --help                     help for package
            --key string               name of the key to use when signing. Used if --sign is true
            --keyring string           location of a public keyring (default "$HOME/.gnupg/pubring.gpg")
            --passphrase-file string   location of a file which contains the passphrase for the signing key. Use "-" in order to read from stdin.
            --sign                     use a PGP private key to sign this package
            --version string           set the version on the chart to this semver version

    Global Flags:
        --burst-limit int                 client-side default throttling limit (default 100)
        --debug                           enable verbose output
        --kube-apiserver string           the address and the port for the Kubernetes API server
        --kube-as-group stringArray       group to impersonate for the operation, this flag can be repeated to specify multiple groups.
        --kube-as-user string             username to impersonate for the operation
        --kube-ca-file string             the certificate authority file for the Kubernetes API server connection
        --kube-context string             name of the kubeconfig context to use
        --kube-insecure-skip-tls-verify   if true, the Kubernetes API server's certificate will not be checked for validity. This will make your HTTPS connections insecure
        --kube-tls-server-name string     server name to use for Kubernetes API server certificate validation. If it is not provided, the hostname used to contact the server is used
        --kube-token string               bearer token used for authentication
        --kubeconfig string               path to the kubeconfig file
    -n, --namespace string                namespace scope for this request
        --registry-config string          path to the registry config file (default "$HOME/.config/helm/registry/config.json")
        --repository-cache string         path to the file containing cached repository indexes (default "$HOME/.cache/helm/repository")
        --repository-config string        path to the file containing repository names and URLs (default "$HOME/.config/helm/repositories.yaml")
      "
}


# Check for the argument and call the appropriate function
case $1 in
    package)
        package $@
        ;;
    --help) 
        help ;;
    *)
        help
        ;;
esac