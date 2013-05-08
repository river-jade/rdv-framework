#!/bin/sh

if [[ -z $TZAR_DB ]];
then
  echo "The TZAR_DB environment variable must be set for tzar to function correctly"
fi

cd /home/ubuntu

mkdir bin
cd bin

wget http://tzar-framework.googlecode.com/files/tzar-0.3.0.jar
ln -s tzar-0.3.0.jar tzar.jar

wget http://rdv-framework.googlecode.com/svn/trunk/R/install.packages.R
wget http://rdv-framework.googlecode.com/svn/trunk/scripts/start-tzar.sh
wget http://rdv-framework.googlecode.com/svn/trunk/scripts/stop-tzar.sh
wget http://rdv-framework.googlecode.com/svn/trunk/scripts/tzar.sh

cd /home/ubuntu

# echo "HostKeyAlgorithms ssh-rsa" >> /etc/ssh/ssh_config
echo "|1|vsNQtnEsu8UD1ivBbbVmz9n/PI0=|AIFdBpKKfm+tYWPsecBdeqE/GL4= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3v38O1h9ZA7Fjbgi7yYJOOWxZWjkalm6fnDhtsUiApeAL7jbbBn0Am4JeDfC//Nfy2CthuBBYSGltsLDFfMRQ6sgGGRr4bHBngL6aIyAvKaBPSNpaIOQfG3IwinBtD1vP024kV6E38q62t2kdqpl6i7s0cHWCpexylrFkEtDUAnQ2OEeStMXtAdz13Czto2cu0mPm4e19OlRhofv5tEHR1n4wo+0lVnGi4lJCNqeT7VyzzPGhQygpUqJ3yv5VjQq5rOQfBzuxONyPssU4RcA8PDvcUmS4EHnBf0rl76UmbYtXDonMVcsAeTmQ9NJilzHjcF0kLUTuf1+AyTXsWgcdQ==
|1|tpDNZ3lpnc5BzhUUyM9+s3KWQs8=|V2nNY3hqboKoT7TqK/C73BnU65g= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3v38O1h9ZA7Fjbgi7yYJOOWxZWjkalm6fnDhtsUiApeAL7jbbBn0Am4JeDfC//Nfy2CthuBBYSGltsLDFfMRQ6sgGGRr4bHBngL6aIyAvKaBPSNpaIOQfG3IwinBtD1vP024kV6E38q62t2kdqpl6i7s0cHWCpexylrFkEtDUAnQ2OEeStMXtAdz13Czto2cu0mPm4e19OlRhofv5tEHR1n4wo+0lVnGi4lJCNqeT7VyzzPGhQygpUqJ3yv5VjQq5rOQfBzuxONyPssU4RcA8PDvcUmS4EHnBf0rl76UmbYtXDonMVcsAeTmQ9NJilzHjcF0kLUTuf1+AyTXsWgcdQ==" >> /home/ubuntu/.ssh/known_hosts

chmod +x bin/*

# update the package list
apt-get update && \
\
# install java \
apt-get -y install default-jre $EXTRA_PACKAGES

# run whatever code is specified to run after installing packages
eval $POST_APT_INSTALL

# add start-tzar to the crontab so that it will run on reboot, or when started \
# from an image. \
su ubuntu -c '(crontab -l; echo "@reboot EXTRA_TZAR_FLAGS=$EXTRA_TZAR_FLAGS /home/ubuntu/bin/start-tzar.sh") \
    | crontab -' && \
\
# start tzar \
su ubuntu -c bin/start-tzar.sh

