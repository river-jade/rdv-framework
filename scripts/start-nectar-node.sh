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

cat << EOF >start-tzar.sh
export TZAR_DIR="/home/ubuntu/tzar"

if [ ! -d \$TZAR_DIR ]; then
  mkdir \$TZAR_DIR
fi

/sbin/start-stop-daemon --start --pidfile=\$TZAR_DIR/tzar.pid --startas /home/ubuntu/bin/tzar.sh >> \$TZAR_DIR/consolelog 2>&1
EOF

cat << EOF > stop-tzar.sh
#!/bin/bash
/sbin/start-stop-daemon --stop --pidfile=\$HOME/tzar/tzar.pid
EOF

cat << EOF > tzar.sh
#!/bin/bash
export TZAR_DIR="/home/ubuntu/tzar"

echo -n "Starting tzar node client:"

export TZAR_DB='$TZAR_DB'
if [ ! -d \$TZAR_DIR ]; then
  mkdir \$TZAR_DIR
fi

# run tzar
java -jar /home/ubuntu/bin/tzar.jar pollandrun --svnurl=https://rdv-framework.googlecode.com/svn/trunk/ --scpoutputhost=glass.eres.rmit.edu.au --scpoutputpath=/mnt/rdv/tzar_output --pemfile=/home/ubuntu/glass.pem &

# write the process id of the running process to a file
echo \$! > \$TZAR_DIR/tzar.pid
EOF

cd /home/ubuntu

# echo "HostKeyAlgorithms ssh-rsa" >> /etc/ssh/ssh_config
echo "|1|vsNQtnEsu8UD1ivBbbVmz9n/PI0=|AIFdBpKKfm+tYWPsecBdeqE/GL4= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3v38O1h9ZA7Fjbgi7yYJOOWxZWjkalm6fnDhtsUiApeAL7jbbBn0Am4JeDfC//Nfy2CthuBBYSGltsLDFfMRQ6sgGGRr4bHBngL6aIyAvKaBPSNpaIOQfG3IwinBtD1vP024kV6E38q62t2kdqpl6i7s0cHWCpexylrFkEtDUAnQ2OEeStMXtAdz13Czto2cu0mPm4e19OlRhofv5tEHR1n4wo+0lVnGi4lJCNqeT7VyzzPGhQygpUqJ3yv5VjQq5rOQfBzuxONyPssU4RcA8PDvcUmS4EHnBf0rl76UmbYtXDonMVcsAeTmQ9NJilzHjcF0kLUTuf1+AyTXsWgcdQ==
|1|tpDNZ3lpnc5BzhUUyM9+s3KWQs8=|V2nNY3hqboKoT7TqK/C73BnU65g= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3v38O1h9ZA7Fjbgi7yYJOOWxZWjkalm6fnDhtsUiApeAL7jbbBn0Am4JeDfC//Nfy2CthuBBYSGltsLDFfMRQ6sgGGRr4bHBngL6aIyAvKaBPSNpaIOQfG3IwinBtD1vP024kV6E38q62t2kdqpl6i7s0cHWCpexylrFkEtDUAnQ2OEeStMXtAdz13Czto2cu0mPm4e19OlRhofv5tEHR1n4wo+0lVnGi4lJCNqeT7VyzzPGhQygpUqJ3yv5VjQq5rOQfBzuxONyPssU4RcA8PDvcUmS4EHnBf0rl76UmbYtXDonMVcsAeTmQ9NJilzHjcF0kLUTuf1+AyTXsWgcdQ==" >> /home/ubuntu/.ssh/known_hosts

chmod +x bin/*

apt-get update && \
apt-get -y install default-jre r-base-core && \
Rscript bin/install.packages.R && \
su ubuntu -c '(crontab -l; echo "@reboot /home/ubuntu/bin/start-tzar.sh") | crontab -' && \
su ubuntu -c bin/start-tzar.sh

