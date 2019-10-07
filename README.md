# GitHub SSH Setup

Create a new SSH key if one is not preset and upload it to GitHub

## Dependencies

This script requires [jq](https://stedolan.github.io/jq://stedolan.github.io/jq/) to parse the JSON response from Github when creating the token for hub.
You can install it via brew with:
```
$ brew install jq
```
Or download the binary from the offcial [site](https://stedolan.github.io/jq/download/)

## Usage

```
$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/eredi93/github-ssh-setup/master/setup.sh)"
```
