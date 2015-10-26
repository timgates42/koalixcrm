#!/bin/bash

# Setup localizations
echo 'Configuring localizations'
echo 'export LANGUAGE="en_US.UTF-8"' | sudo tee -a /etc/profile.d/lang.sh
echo 'export LANG="en_US.UTF-8"' | sudo tee -a /etc/profile.d/lang.sh
echo 'export LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/profile.d/lang.sh
. /etc/profile.d/lang.sh
locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

# Install git for version control, pip for install python packages
echo 'Installing pip & virtualenv...'
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install -y automake build-essential curl firefox gettext graphviz-dev libbz2-dev libcairo2 libffi-dev libfreetype6-dev libgdk-pixbuf2.0-0 libjpeg8-dev liblcms1-dev libpango1.0-0 libpq-dev libreadline-dev libreadline6 libreadline6-dev libsqlite3-dev libssl-dev libtiff4-dev libtool libwebp-dev libxml2 libxml2-dev llvm postgresql python-dev python-pip python-setuptools python-virtualenv python3-dev python3-lxml python3-pip shared-mime-info wget zlib1g-dev

echo 'Configuring the project virtual enviroment'
mkdir ~vagrant/.virtualenvs
chown vagrant:vagrant ~vagrant/.virtualenvs
virtualenv --python=python3 --no-site-packages ~vagrant/.virtualenvs/env
source ~vagrant/.virtualenvs/env/bin/activate

# Postgres Setup
echo "Configuring Postgres DATABASE"
sudo -u postgres psql postgres -U postgres -c "CREATE ROLE db_user WITH LOGIN ENCRYPTED PASSWORD 'password' CREATEDB CREATEROLE REPLICATION SUPERUSER"
sudo -u postgres psql postgres -U postgres -c "CREATE DATABASE my_db"
sudo -u postgres psql postgres -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE my_db TO db_user"
echo "listen_addresses = '*' " >> /etc/postgresql/9.3/main/postgresql.conf
echo "host    all    all    all    password" >> /etc/postgresql/9.3/main/pg_hba.conf
sudo service postgresql restart

#Install the python requirements (inside the virtualenv)
# Config virtualenv

cd /vagrant/
./install_os_dependencies.sh install
# Commented this because we are already running the deployment process with this
# bash script, but will be available for the moment is needed.
# ./install_docker_dependencies.sh
echo "Installing requirements for python"
pip install -r requirements/local.txt
sudo chown -R vagrant:vagrant ~vagrant/.virtualenvs/

echo "Setting defaults for when using ssh"
echo "source ~vagrant/.virtualenvs/env/bin/activate" >> ~vagrant/.bashrc
echo "cd /vagrant" >> ~vagrant/.bashrc

# Commented because is creating conflicts over the migration process
# python manage.py makemigrations
python manage.py migrate

echo "Project setup finished."
