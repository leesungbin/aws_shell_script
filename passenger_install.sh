#!/bin/bash
CYAN='\e[0;36m'
NC='\e[0m'
echo -e "${CYAN}Passenger, Nginx 설치 및 설정 시작${NC}"
echo -e "${CYAN}설치중...${NC}"
sudo apt-get install -y nginx-extras passenger >/dev/null
echo -e "${CYAN}설치끝${NC}"
sudo touch /etc/nginx/temp.txt
sudo -i -H sh -c " sed -e '1,63d' /etc/nginx/nginx.conf > /etc/nginx/temp.txt; sed -i '63,93d' /etc/nginx/nginx.conf; printf '\tinclude /etc/nginx/passenger.conf;\n' >> /etc/nginx/nginx.conf; cat /etc/nginx/temp.txt >> /etc/nginx/nginx.conf; exit"
sudo rm -r /etc/nginx/temp.txt
echo -e "${CYAN}설정 끝${NC}"
sudo service nginx restart
echo -e "${CYAN}nginx를 재시작 했습니다.\n${NC}"

echo -e "${CYAN}서버에 루비를 올리기 위한 작업을 시작합니다.\n원하는대로 app이름과 추가할 username을 입력하세요(enter => default)${NC}"
printf "app이름 : "
read myapp
printf "username : "
read myappuser
if [ -z "$myapp" ] ; then
    myapp="myapp"
fi
if [ -z "$myappuser" ] ; then
    myappuser="myappuser"
fi
echo -e "${CYAN}=========================================="
echo -e "app 이름 : $myapp\nuser 이름 : $myappuser"
echo -e "==========================================${NC}"
sudo adduser $myappuser
sudo mkdir -p ~$myappuser/.ssh
touch $HOME/.ssh/authorized_keys
sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~$myappuser/.ssh/authorized_keys"
sudo chown -R $myappuser: ~$myappuser/.ssh
sudo chmod 700 ~$myappuser/.ssh
sudo sh -c "chmod 600 ~$myappuser/.ssh/*"

sudo mkdir -p /var/www/$myapp
sudo chown $myappuser: /var/www/$myapp
echo -e "${CYAN}루비가 올라가 있는 깃헙 주소를 입력하세요\n(default : https://github.com/leesungbin/uosHomework.git)\n${NC}"
printf "입력 :"
read github_address
if [ -z "$github_address" ] ; then
    github_address="https://github.com/leesungbin/uosHomework.git"
fi
cd /var/www/$myapp
sudo -u $myappuser -H git clone $github_address code

MA=$myapp

export MA
sudo -u $myappuser -H sh -c "
echo $RV;
echo $MA;
rvm use ruby-$RV;
cd /var/www/$MA/code;
bundle install --deployment --without development test -j 2;
printf '  adapter: sqlite3' >> config/database.yml;
secret_key=bundle exec rake secret;
sudo sed -i '22s/' config/secrets.yml;
echo '  secret_key_base: $secret_key' >> config/secrets.yml;

chmod 700 config debchmod 600 config/database.yml config/secrets.yml;
bundle exec rake assets:precompile db:migrate RAILS_ENV=production;
export COMMAND_ADDRESS= passenger-config about ruby-command | sed -e '2s/';
echo $COMMAND_ADDRESS;
exit;
"
echo $COMMAND_ADDRESS
printf "server name 입력 : "
read server_name
echo $server_name
echo "/var/www/$myapp/code/public"

export -n RV
unset RV
unset ruby_version
unset myappuser
export -n MA
unset MA
unset myapp
unset github_address
unset CYAN
unset NC
export -n COMMAND_ADDRESS
unset COMMAND_ADDRESS