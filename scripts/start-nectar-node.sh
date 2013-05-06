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

start-stop-daemon --start --pidfile=\$TZAR_DIR/tzar.pid --startas /home/ubuntu/bin/tzar.sh >> \$TZAR_DIR/consolelog 2>&1
EOF

cat << EOF > stop-tzar.sh
#!/bin/bash
start-stop-daemon --stop --pidfile=\$HOME/tzar/tzar.pid
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
java -jar /home/ubuntu/bin/tzar.jar pollandrun --svnurl=https://rdv-framework.googlecode.com/svn/trunk/ --scpoutputhost=glass.eres.rmit.edu.au --scpoutputpath=/mnt/rdv/tzar_output --pemfile=/home/ubuntu/rdv.pem &

# write the process id of the running process to a file
echo \$! > \$TZAR_DIR/tzar.pid
EOF

cd /home/ubuntu

# echo "HostKeyAlgorithms ssh-rsa" >> /etc/ssh/ssh_config
echo "|1|vsNQtnEsu8UD1ivBbbVmz9n/PI0=|AIFdBpKKfm+tYWPsecBdeqE/GL4= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3v38O1h9ZA7Fjbgi7yYJOOWxZWjkalm6fnDhtsUiApeAL7jbbBn0Am4JeDfC//Nfy2CthuBBYSGltsLDFfMRQ6sgGGRr4bHBngL6aIyAvKaBPSNpaIOQfG3IwinBtD1vP024kV6E38q62t2kdqpl6i7s0cHWCpexylrFkEtDUAnQ2OEeStMXtAdz13Czto2cu0mPm4e19OlRhofv5tEHR1n4wo+0lVnGi4lJCNqeT7VyzzPGhQygpUqJ3yv5VjQq5rOQfBzuxONyPssU4RcA8PDvcUmS4EHnBf0rl76UmbYtXDonMVcsAeTmQ9NJilzHjcF0kLUTuf1+AyTXsWgcdQ==
|1|tpDNZ3lpnc5BzhUUyM9+s3KWQs8=|V2nNY3hqboKoT7TqK/C73BnU65g= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3v38O1h9ZA7Fjbgi7yYJOOWxZWjkalm6fnDhtsUiApeAL7jbbBn0Am4JeDfC//Nfy2CthuBBYSGltsLDFfMRQ6sgGGRr4bHBngL6aIyAvKaBPSNpaIOQfG3IwinBtD1vP024kV6E38q62t2kdqpl6i7s0cHWCpexylrFkEtDUAnQ2OEeStMXtAdz13Czto2cu0mPm4e19OlRhofv5tEHR1n4wo+0lVnGi4lJCNqeT7VyzzPGhQygpUqJ3yv5VjQq5rOQfBzuxONyPssU4RcA8PDvcUmS4EHnBf0rl76UmbYtXDonMVcsAeTmQ9NJilzHjcF0kLUTuf1+AyTXsWgcdQ==" >> /home/ubuntu/.ssh/known_hosts


echo "-----BEGIN RSA PRIVATE KEY-----
MIIEoQIBAAKCAQEA2PjqhabZDLqizQOzgxyPaqb4CF+wfrJhz3PpjWTBtbQSA+d1
hLdsRhvTXfUEet69Zn+2soFgL0MkvEuEURl/fEa0VYf94+WesRjcuhWah362Yw2E
76wi1XTOE7XMR1Jk8SKdp5yqSYloqzmlCgNkEDg8Y93pbaKXotd5gyp8ZKkTRU9y
/YRkVFl8SDJI0Kcx+c5a+6F8isGWKdn0OJaqhfCKukHYwRrBU5sDCFoVstih02Ct
sQdYf4SD/0gzr9nhGUOQroQoD2fnpQro1E+58ZdXUZNCBeaL1QN39vqmXO7HGdcT
Hta982NHywJBfH3kjV5JDjgrYtRrRB6nCOkWUwIBIwKCAQAlMfxRbQ9EArzSsC1m
7vQDp5g78yWSD/OCpigJnD5266tRIF1J847ncnwBenXL66twqC3ytxfNlntTeqj3
9b4VTfMHWSQ1slW39aIuh1xRvfNhcAgpFjHbcxwDYP5yoGkTZQUVa1BkYLLbhjmM
sB/IRCecF2nYR8I5LEC3Zl53p6Pe2kABTOz57SsG9aRBGm92gqdvsDknIOS4TJ9W
rAGJ8JEgEE1GorQGk7VoE0tL+Novop5wypTteHMzYayD02O2Vgzq2lna+cXyZ/Pg
ziYiHmIUgVNCb815yMsbyveoClDWWgD7kPkVEfhHMBRaSjCZ3hUu5FD4flJJ8wvz
45L7AoGBAOu69Rb+pgOG4QAQgwvfVOxSCvSJs/8zl3fk7QEEEXj6OWSydCkQvMF0
phMMdGHPdVpDXr7H8EaahgAhBWvGLHfam9pznKpZh2boPOckeEP1YpF9nkgOJua4
pOvd7bW7Ww+RpoXIXll7h9TONbORBkpUcUouPszhF8Iilji3pbhnAoGBAOuhC+ah
8vpw5laPFlQgOBDJyUBmaYVIP5K8g1G67yiRu9d3bpeUU5BjQfhyH9H9jPl6IqgB
zq0mao6H3lmTXE5BscA2Qxw4hNNhb527JOzf2N8HApRJiMvV9etMQkv4AjVQeNzw
VWInnUqy3sHcxtQMstijxYYthnPHfqiX6S81AoGAUNJiqMxWLRhNJJfyanh0409U
NpWczIa3ltIlX28b7va0l42kK1YyFnEi/zd4XAydQ4TQBuV286KxmaTr6m/Uu2Dk
+nDH/+QubGzhrlWlk6SW0sv7wO7oxCIMqKPceNKFnvAb1hjP5CpadNj8eBR3L21o
q7gViBKpD1xQwv0i4CMCgYBycstEIsZ5pI0iuocwLOgIJ38CBdt7QFlkh3L7z9M/
lz368N3x2lR5VMhFeUKn0uyzsFn51P38VHzmJLx0pqktUxvSY3+unxvxpFrI9H+m
QNcNPetPVuqsJhhcWD11WzRFyAAwzIE+TcFtbNKYrRAd2kg9VtxIfIMiSvRghEyw
hwKBgQDmRKpCQXXH4VTxPpjYJpyNVH+eg05twNos6ihm/cKcv6viiWgOojqX9a8z
oyfgkvYKYMqF95znLW81u9MagTB79kciDotZM7gOxwEDEVCmGr/vl+oBCQ8dDixk
xrWs3wO9834SpWKSwhOy4u6897M6Ym3ZG11DcS090QapWpKAkg==
-----END RSA PRIVATE KEY-----" > /home/ubuntu/rdv.pem

chmod +x bin/*

apt-get update && \
apt-get -y install default-jre r-base-core && \
Rscript bin/install.packages.R && \
su ubuntu -c bin/start-tzar.sh

