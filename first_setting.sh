#!/bin/bash
CYAN='\e[0;36m'
NC='\e[0m'
echo -e "${CYAN}======여러가지 준비 시작======${NC}"
echo -e "${CYAN}Repository 업데이트 중...${NC}"
sudo apt-get update > /dev/null
echo -e "${CYAN}업데이트 끝\n${NC}"
echo -e "${CYAN}아래 에러 무시, 다른 거 또 설치중${NC}"
sudo apt-get install -y curl gnupg build-essential >/dev/null
echo -e "${CYAN}\ncurl, gnupg, build-essential 설치 끝\n${NC}"
echo -e "${CYAN}Key를 받는 중입니다...${NC}"
sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 > /dev/null
sudo curl -sSL https://get.rvm.io | sudo bash -s stable >/dev/null
sudo usermod -a -G rvm `whoami` >/dev/null
if sudo grep -q secure_path /etc/sudoers; then sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh" && echo Environment variable installed; fi
echo -e "${CYAN}터미널 나갔다가 다시 들어오세요.${NC}"

unset CYAN
unset NC
