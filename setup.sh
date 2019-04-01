#!/usr/bin/env bash

set -euo pipefail

if ! [ -f "${HOME}/.ssh/id_rsa" ] && ! [ -f "${HOME}/.ssh/id_rsa.pub" ]; then
  echo "Generating new SSH key pair."
  ssh-keygen -N "" -t rsa -b 4096 -f "${HOME}/.ssh/id_rsa" > /dev/null
fi

github_ssh_known_host="github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="

if ! grep -F -q "$github_ssh_known_host" "${HOME}/.ssh/known_hosts" 2> /dev/null; then
  echo "Adding GitHub host to known_hosts."
  echo "${github_ssh_known_host}" >> "${HOME}/.ssh/known_hosts"
fi

printf "Enter GitHub Username: "
read -r username

github_ssh_response=$(ssh -T git@github.com 2>&1 || true)

if echo "${github_ssh_response}" | grep -q "Hi ${username}! You've successfully authenticated"; then
  echo "It seems that your Github SSH key is already setup."
  echo "Bye!" && exit 0
fi

printf "Enter GitHub Password: "
read -r -s password
echo

printf "Enter the name of the SSH key which will be displayed in GitHub: "
read -r key_name

headers=""
login="-u '${username}':'${password}'"

if eval "curl -s ${login} https://api.github.com/user -i" | grep -q "X-GitHub-OTP: required"; then
  echo "It seems that you have 2FA enabled."
  printf "Enter GitHub OTP: "
  read -r otp
  headers="-H 'X-GitHub-OTP: ${otp}'"
fi

public_key=$(cat "${HOME}/.ssh/id_rsa.pub")
payload="'{\"title\":\"${key_name}\",\"key\":\"${public_key}\"}'"

response=$(eval "curl -s ${login} ${headers} --data ${payload} https://api.github.com/user/keys")

if echo "${response}" | grep -E -q '\s+"id":\s+[0-9]+,'; then
  echo "Key successfully added to GitHub"
else
  echo "Something went wrong! this is the response I got:"
  echo "${response}"
fi
