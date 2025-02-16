#!/usr/bin/env bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install packages
apt update
apt install -y jq

# Disable Uncomplicated Firewall (ufw)
ufw disable

# Disable AppArmor
systemctl stop apparmor.service
systemctl disable apparmor.service

# Add anthos group and user
addgroup \
--gid 2000 \
anthos

adduser \
--disabled-password \
--gecos "Anthos user" \
--gid 2000 \
--uid 2000 \
anthos

# Configure anthos user for passwordless sudo
echo -e "anthos\tALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/anthos

# Create the anthos user .ssh directory
mkdir --mode=700 -p ~anthos/.ssh
chown anthos:anthos ~anthos/.ssh

exit 0
