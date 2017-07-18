#!/bin/bash
CYAN='\e[0;36m'
NC='\e[0m'
printf "${CYAN}설치를 원하는 루비 버전을 입력하세요(ex 2.3.0 / 2.4.1)\n입력안하면 최신으로 설치합니다.\n"
printf "입력 : ${NC}"
read ruby_version
echo "${CYAN}$ruby_version 이 설치 됩니다.${NC}"
rvm install ruby-$ruby_version
rvm --default use ruby-$ruby_version

gem install bundler --no-rdoc --no-ri
echo -e "${CYAN}****************bundle gem 설치(오류확인)************\n${NC}"
echo -e "${CYAN}노드 설치중${NC}"
sudo apt-get install -y nodejs > /dev/null

echo -e "${CYAN}루비, 노드js 설치 끝\n\n${NC}\n\n"
echo -e "${CYAN}======Passengers를 설치과정을 진행합니다.=====${NC}"

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 >/dev/null
sudo apt-get install -y apt-transport-https ca-certificates >/dev/null

# Add our APT repository
echo -e "${CYAN}Apt repository 추가${NC}"
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
echo -e "Repository 업데이트 중..."
sudo apt-get update > /dev/null
echo -e "${CYAN}Repository 업데이트 까지 끝${NC}"
echo -e "\n${CYAN}******* gem: command not found 오류가 난 경우, rvm reinstall ruby-(루비버전)\n후에 gem install bundler --no-rdoc --no-ri 을 실행하세요.${NC}"
unset ruby_version
unset CYAN
unset NC