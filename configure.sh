#!/bin/bash
set -e

codename="$1"
if [[ "${codename}" != "hirsute" ]] && [[ "${codename}" != "impish" ]]; then
  echo "Usage: $0 <hirsute|impish>"
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

mapfile -t lines <<< "$(sudo apt-get install --dry-run libc6 | grep '^Inst')"

for line in "${lines[@]}"; do
  echo "${line}"
  parts=(${line})

  index=1
  package="${parts[${index}]}"
  index=$(expr ${index} + 1)
  existing=none
  new=
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
done

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
sudo sed -i "/^deb.*${codename}.*$/d" /etc/apt/sources.list
sudo apt-get update
EOF
chmod +x scripts/upgrade.sh

echo "Done"


echo "Reverting repositories..."
sudo sed -i "/^deb.*${codename}.*$/d" /etc/apt/sources.list
sudo apt-get update
