#!/bin/bash
set -e
sudo apt-get install -y --allow-downgrades libfakeroot=1.24-1 fakeroot=1.24-1 libc-dev-bin=2.31-0ubuntu9.3 libc6-dev=2.31-0ubuntu9.3 libc6-dbg=2.31-0ubuntu9.3 locales=2.31-0ubuntu9.3 libc6=2.31-0ubuntu9.3 libc6:i386=2.31-0ubuntu9.3 libc-bin=2.31-0ubuntu9.3
sudo apt-get remove -y rpcsvc-proto libtirpc-common libtirpc3 libtirpc-dev libnsl2 libnsl-dev libtirpc3:i386 libnsl2:i386 libnss-nis:i386 libnss-nis libnss-nisplus:i386 libnss-nisplus || true
