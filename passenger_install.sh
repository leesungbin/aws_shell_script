#!/bin/bash
echo -e "${CYAN}Passenger, Nginx 설치 및 설정 시작${NC}"
sudo apt-get install -y nginx-extras passenger
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
sudo adduser $myappuser
sudo mkdir -p ~$myappuser/.ssh
touch $HOME/.ssh/authorized_keys
sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~$myappuser/.ssh/authorized_keys"
sudo chown -R $myappuser: ~$myappuser/.ssh
sudo chmod 700 ~$myappuser/.ssh
sudo sh -c "chmod 600 ~$myappuser/.ssh/*"

sudo mkdir -p /var/www/$myapp
sudo chown $myappuser: /var/www/$myapp
echo -e "${CYAN}루비가 올라가 있는 깃헙 주소를 입력하세요\n(default : https://github.com/leesungbin/aws.git)\n${NC}"
printf "입력 :"
read github_address
if [ -z "$github_address" ] ; then
    github_address="https://github.com/leesungbin/aws.git"
fi
cd /var/www/$myapp
sudo -u $myappuser -H git clone --branch=end_result $github_address code