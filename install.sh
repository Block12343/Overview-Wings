#!/bin/bash

set -e

# https https://github.com/Block12343/Overview-Wings.git
GITHUB_REPO="Overview-Wings"
GITHUB_USER="Block12343"
GITHUB_URL="https://github.com/$GITHUB_USER/$GITHUB_REPO.git"

HTTP_ENGINE=''

LOG_PATH='/var/log/overview_wings_install.log'

INSTALL_PATH='install'

# check for curl
if ! command -v curl &> /dev/null
then
    echo "curl could not be found, please install curl and try again." | tee -a $LOG_PATH
    exit 1
fi

#check for git

if ! command -v git &> /dev/null
then
    echo "git could not be found, please install git and try again." | tee -a $LOG_PATH
    exit 1
fi

# check for python3
if ! command -v python3 &> /dev/null
then
    echo "python3 could not be found, please install python3 and try again." | tee -a $LOG_PATH
    exit 1
fi  

#check for venv
if ! python3 -m venv --help &> /dev/null
then
    echo "python3-venv could not be found, please install python3-venv and try again." | tee -a $LOG_PATH
    exit 1
fi

# check for nginx
if [ command -v nginx &> /dev/null ] && [ command -v apache2 &> /dev/null ]; then
    echo "Both nginx and apache2 are installed, please uninstall one of them and try again." | tee -a $LOG_PATH
    exit 1
elif command -v apache2 &> /dev/null; then
    echo "Using apache2..." | tee -a $LOG_PATH
    HTTP_ENGINE='apache2'
elif command -v nginx &> /dev/null;
then
    echo "Using nginx..." | tee -a $LOG_PATH
    HTTP_ENGINE='nginx'
else
    echo "Neither nginx nor apache2 could be found, nginx is being installed." | tee -a $LOG_PATH
    echo "Do you wish to continue? (y/n)" | tee -a $LOG_PATH
    read answer
    if [ "$answer" = "y" ] || [ "$answer" = "yes" ] || [ "$answer" = "1" ]; then
        echo "Installing nginx..." | tee -a $LOG_PATH
        if command -v apt-get &> /dev/null; then
            sudo apt-get update | tee -a $LOG_PATH
            sudo apt-get install -y nginx | tee -a $LOG_PATH
            HTTP_ENGINE='nginx'
        elif command -v yum &> /dev/null; then
            sudo yum install -y epel-release | tee -a $LOG_PATH
            sudo yum install -y nginx | tee -a $LOG_PATH    
            HTTP_ENGINE='nginx'
        else
            echo "Neither apt-get nor yum could be found, please install nginx manually and try again." | tee -a $LOG_PATH
            exit 1
        fi
    else
        echo "Aborting installation." | tee -a $LOG_PATH
        exit 0
    fi
fi


if [ -f /var/www/Overview/wings/main.py ]; then
    echo "Overview-Wings already installed, do you wissh to continue the setup?"
    echo "This will overwrite and delete ALL existing files."
    echo "Config files will not be preserved."
    echo "If you wish to continue, type 'yes' to confirm."

    read answer
    if [ "$answer" = "yes" ] || [ "$answer" = "1" ]; then
        echo "Continuing installation..." | tee -a $LOG_PATH
        rm -rf /var/www/Overview/wings
    else
        echo "Aborting installation." | tee -a $LOG_PATH
        exit 0 
    fi
fi
cd /var/tmp
# rm -rf "$GITHUB_REPO"

echo "Downloading Overview-Wings..." | tee -a $LOG_PATH


git clone "$GITHUB_URL" | tee -a $LOG_PATH

cd "$GITHUB_REPO" 

mkdir -p /var/www/Overview/wings
cp -r * /var/www/Overview/wings

rm -rf /var/tmp/"$GITHUB_REPO"

# now python env setup
echo "Setting up virtual environment..." | tee -a $LOG_PATH
cd /var/www/Overview/wings

python3 -m venv wings | tee -a $LOG_PATH
source wings/bin/activate

pip install --upgrade pip | tee -a $LOG_PATH
pip install -r /var/www/Overview/wings/$INSTALL_PATH/py_requirements.txt | tee -a $LOG_PATH

echo "Virtual environment setup complete." | tee -a $LOG_PATH

deactivate # leaves venv environment, returns to normal shell

# setup web server

# setup systemd service
echo "Setting up systemd service..." | tee -a $LOG_PATH

sudo cp $INSTALL_PATH/overview-wings.service /etc/systemd/system/overview-wings.service | tee -a $LOG_PATH
sudo systemctl daemon-reload | tee -a $LOG_PATH
sudo systemctl enable overview-wings | tee -a $LOG_PATH

echo "Systemd service setup complete." | tee -a $LOG_PATH
echo "You can start the service with 'sudo systemctl start overview-wings'" | tee -a $LOG_PATH


#delete install files