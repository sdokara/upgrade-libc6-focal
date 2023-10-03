#!/bin/bash
set -e

supported_codenames=("hirsute" "impish" "jammy" "kinetic" "lunar" "mantic")
codename="$1"
for supported_codename in "${supported_codenames[@]}"; do
  if [[ "${codename}" == "${supported_codename}" ]]; then
    supported=1
    break
  fi
done

if [[ -z ${supported} ]]; then
  echo "Usage: $0 <hirsute|impish|jammmy|kinetic|lunar|mantic>"
  exit 1
fi

echo "Injecting ${codename} repositories..."
sudo tee -a /etc/apt/sources.list >/dev/null <<EOF
deb http://ba.archive.ubuntu.com/ubuntu/ ${codename} main restricted
deb http://ba.archive.ubuntu.com/ubuntu/ ${codename}-updates main restricted
EOF
sudo apt-get update


echo "Evaluating dependencies to upgrade... "

install="sudo apt-get install -y --allow-downgrades"
remove="sudo apt-get remove -y"

mapfile -t lines <<< "$(sudo apt-get install --dry-run libc6 | grep '^\(Inst\|Remv\)' | sort)"

printf "%-30s %-30s %-30s\n" "Package" "Before" "After"
for line in "${lines[@]}"; do
  parts=(${line})

  index=1
  package="${parts[${index}]}"
  index=$(expr ${index} + 1)
  existing=none
  new=none
  if [[ "${parts[${index}]}" =~ "[" ]]; then
    existing="$(sed 's/\[\(.*\)\]/\1/' <<< "${parts[${index}]}")"
    index=$(expr ${index} + 1)
  fi
  if [[ "${parts[${index}]}" =~ "(" ]]; then
    new="$(sed 's/(\(.*\)/\1/' <<< "${parts[${index}]}" )"
    index=$(expr ${index} + 1)
  fi

  if [[ "${existing}" != "none" ]]; then
    install="${install} ${package}=${existing}"
  else
    remove="${remove} ${package}"
  fi

  if [[ "${existing}" != "none" ]]; then
    if [[ "${new}" != "none" ]]; then
      printf "\033[93m"
    else
      printf "\033[91m"
    fi
  else
    printf "\033[92m"
  fi
  printf "%-30s %-30s %-30s\n" "${package}" "${existing}" "${new}"
done
printf "\033[39m"

echo "Done"


echo -n "Generating scripts... "
mkdir -p scripts

tee scripts/downgrade.sh > /dev/null <<EOF
#!/bin/bash
set -e
${install}
${remove} || true
EOF
chmod +x scripts/downgrade.sh

tee scripts/upgrade.sh > /dev/null <<EOF
#!/bin/bash
set -e
sudo tee -a /etc/apt/sources.list >/dev/null <<EOF1
deb http://ba.archive.ubuntu.com/ubuntu/ ${codename} main restricted
deb http://ba.archive.ubuntu.com/ubuntu/ ${codename}-updates main restricted
EOF1
sudo apt-get update
sudo apt-get install -y libc6
sudo sed -i "/^deb http:\/\/ba.archive.ubuntu.com\/ubuntu\/ ${codename}\(-updates\)\? main restricted$/d" /etc/apt/sources.list
sudo apt-get update
EOF
chmod +x scripts/upgrade.sh

echo "Done"


echo "Reverting repositories..."
sudo sed -i "/^deb http:\/\/ba.archive.ubuntu.com\/ubuntu\/ ${codename}\(-updates\)\? main restricted$/d" /etc/apt/sources.list
sudo apt-get update
