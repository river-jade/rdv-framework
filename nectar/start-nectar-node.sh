#!/bin/sh

TZAR_VERSION=${TZAR_VERSION:=0.4.2}

mkdir /usr/local/lib/tzar
wget http://tzar-framework.googlecode.com/files/tzar-${TZAR_VERSION}.jar -P /usr/local/lib/tzar
ln -s /usr/local/lib/tzar/tzar-${TZAR_VERSION}.jar /usr/local/lib/tzar/tzar.jar

wget http://rdv-framework.googlecode.com/svn/trunk/nectar/tzar -P /usr/local/bin/
chmod +x /usr/local/bin/tzar
wget http://rdv-framework.googlecode.com/svn/trunk/nectar/tzar.conf -P /etc/init/

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

mkdir /home/ubuntu/tzar
chown ubuntu /home/ubuntu/tzar

start tzar
