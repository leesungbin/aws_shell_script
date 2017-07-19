#!/bin/bash
CYAN='\e[0;36m'
NC='\e[0m'
# 단계 : 1 : first setting ,2 : install ruby ,3 : 노드,passenger 설치, 4 : 깃-루비 준비, 5 : deploying 작업, 6 : swap file

cd ~

if [ -f ".progress" ] ; then
    step=`tail -n 1 .progress`;

    case $step in
        "1")
            printf "${CYAN}설치를 원하는 루비 버전을 입력하세요(ex 2.3.0 / 2.4.1)\n입력안하면 최신으로 설치합니다.\n";
            printf "입력 : ${NC}";
            read ruby_version;
            echo -e "${CYAN}다음에 실행되는 부분에서 오류가 발생하는지 확인해 주세요.${NC}";

            rvm install ruby-$ruby_version;
            # Load RVM into a shell session *as a function*
            # Loading RVM *as a function* is mandatory
            # so that we can use 'rvm use <specific version>'
            if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
                # First try to load from a user install
                source "$HOME/.rvm/scripts/rvm";
                echo "using user install $HOME/.rvm/scripts/rvm";
            elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
                # Then try to load from a root install
                source "/usr/local/rvm/scripts/rvm";
                echo "using root install /usr/local/rvm/scripts/rvm";
            else
                echo "ERROR: An RVM installation was not found.\n";
            fi

            rvm --default use ruby-$ruby_version;
            gem install bundler --no-rdoc --no-ri;

            echo -e "${CYAN}위에 로그를 통해, Ruby 설치를 확인해주세요.${NC}";
        ;;
        "2")
            echo "step 2";
        ;;
        "3")
            echo "step 3";
        ;;
    esac

#excuted shell first time..
else
    echo -e "${CYAN}======여러가지 준비 시작======${NC}";
    echo -e "${CYAN}Repository 업데이트 중...${NC}";
    sudo apt-get update > /dev/null;
    echo -e "${CYAN}업데이트 끝\n${NC}";
    echo -e "${CYAN}아래에 오류가 발생하면, 명령이 다 끝난후,\nsudo -i -H sh -c \" echo 'LC_ALL=\\\"en_US.UTf-8\\\"' >> /etc/environment \\\"\n을 입력해주세요.${NC}";
    sudo apt-get install -y curl gnupg build-essential >/dev/null;
    echo -e "${CYAN}\ncurl, gnupg, build-essential 설치 끝\n${NC}";
    echo -e "${CYAN}Key를 받는 중입니다...${NC}";
    sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 > /dev/null;
    sudo curl -sSL https://get.rvm.io | sudo bash -s stable >/dev/null;
    sudo usermod -a -G rvm `whoami` >/dev/null;
    if sudo grep -q secure_path /etc/sudoers; then sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh" && echo Environment variable installed; fi
    echo -e "${CYAN}서버 터미널에 다시 접속하세요.${NC}";
    touch .progress;
    echo 1 > .progress;
fi
unset CYAN;
unset NC;
