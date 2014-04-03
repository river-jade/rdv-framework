#!/bin/bash

if [[ -z $TZAR_DB ]];
then
  echo "The TZAR_DB environment variable must be set for tzar to function correctly"
fi

TZAR_VERSION=${TZAR_VERSION:-0.5.2}

mkdir /usr/local/lib/tzar
cd /usr/local/lib/tzar

if [[ "${TZAR_VERSION}" < "0.5.0" ]]; then
  wget http://tzar-framework.googlecode.com/files/tzar-${TZAR_VERSION}.jar
else
  wget https://tzar-framework.atlassian.net/wiki/download/attachments/4980739/tzar-${TZAR_VERSION}.jar
fi

ln -s tzar-${TZAR_VERSION}.jar tzar.jar

wget http://rdv-framework.googlecode.com/svn/trunk/scripts/tzar -O /usr/local/bin/tzar
chmod +x /usr/local/bin/tzar

cd /home/ubuntu
mkdir /home/ubuntu/tzar
chown ubuntu /home/ubuntu/tzar

# echo "HostKeyAlgorithms ssh-rsa" >> /etc/ssh/ssh_config
echo "|1|vsNQtnEsu8UD1ivBbbVmz9n/PI0=|AIFdBpKKfm+tYWPsecBdeqE/GL4= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3v38O1h9ZA7Fjbgi7yYJOOWxZWjkalm6fnDhtsUiApeAL7jbbBn0Am4JeDfC//Nfy2CthuBBYSGltsLDFfMRQ6sgGGRr4bHBngL6aIyAvKaBPSNpaIOQfG3IwinBtD1vP024kV6E38q62t2kdqpl6i7s0cHWCpexylrFkEtDUAnQ2OEeStMXtAdz13Czto2cu0mPm4e19OlRhofv5tEHR1n4wo+0lVnGi4lJCNqeT7VyzzPGhQygpUqJ3yv5VjQq5rOQfBzuxONyPssU4RcA8PDvcUmS4EHnBf0rl76UmbYtXDonMVcsAeTmQ9NJilzHjcF0kLUTuf1+AyTXsWgcdQ==
|1|tpDNZ3lpnc5BzhUUyM9+s3KWQs8=|V2nNY3hqboKoT7TqK/C73BnU65g= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3v38O1h9ZA7Fjbgi7yYJOOWxZWjkalm6fnDhtsUiApeAL7jbbBn0Am4JeDfC//Nfy2CthuBBYSGltsLDFfMRQ6sgGGRr4bHBngL6aIyAvKaBPSNpaIOQfG3IwinBtD1vP024kV6E38q62t2kdqpl6i7s0cHWCpexylrFkEtDUAnQ2OEeStMXtAdz13Czto2cu0mPm4e19OlRhofv5tEHR1n4wo+0lVnGi4lJCNqeT7VyzzPGhQygpUqJ3yv5VjQq5rOQfBzuxONyPssU4RcA8PDvcUmS4EHnBf0rl76UmbYtXDonMVcsAeTmQ9NJilzHjcF0kLUTuf1+AyTXsWgcdQ==" >> /home/ubuntu/.ssh/known_hosts

# update the package list
apt-get update && \
\
# install java \
apt-get -y install default-jre $EXTRA_PACKAGES

# run whatever code is specified to run after installing packages
eval $POST_APT_INSTALL

# Create init script so that tzar starts on startup.
cat << EOF > /etc/init/tzar.conf 
# tzar pollandrun service
#
# This service starts the tzar node polling the database until shutdown.

start on (local-filesystems and net-device-up IFACE!=lo)

stop on runlevel [016]

respawn
respawn limit 10 5

setuid ubuntu

script
    export HOME=/home/ubuntu
    exec /usr/local/bin/tzar > /home/ubuntu/tzar/consolelog 2>&1
end script
EOF

# start tzar!
start tzar
