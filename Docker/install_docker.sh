#/bin/bash



function install_docker_CenOS {

  #1.  Update the system and install necessary packages
  yum update -y
  yum install git -y

  #2. Enable and install Docker CE Repository
  yum install -y yum-utils device-mapper-persistent-data lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install docker-ce -y
  systemctl start docker
  systemctl enable docker

  #3. Install Docker Compose
  curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`$
  chmod +x /usr/local/bin/docker-compose
  #4. Clone the HES repository
  git clone https://github.com/HideezGroup/HES.git /opt/src/HES

}


OS=""
if grep -q  CentOS  /etc/os-release
        then OS="CentOS"
else
        if grep -q  Ubuntu  /etc/os-release
                then OS="Ubuntu"
        fi
fi
echo $OS

if $OS -q CentOS  
  install_docker_CenOS
fi

