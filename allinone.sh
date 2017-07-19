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
            echo "2" > ~/.progress;
        ;;
        "2")
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
            
            # echo -e "\n${CYAN}******* gem: command not found 오류가 난 경우, rvm reinstall ruby-(루비버전)\n후에 gem install bundler --no-rdoc --no-ri 을 실행하세요.${NC}"

            export RV=$ruby_version
            echo -e "${CYAN}Passenger, Nginx 설치 및 설정 시작${NC}"
            echo -e "${CYAN}설치중...${NC}"
            sudo apt-get install -y nginx-extras passenger >/dev/null
            echo -e "${CYAN}설치끝${NC}"
            sudo touch /etc/nginx/temp.txt
            sudo -i -H sh -c " sed -e '1,63d' /etc/nginx/nginx.conf > /etc/nginx/temp.txt; sed -i '63,93d' /etc/nginx/nginx.conf; printf '\tinclude /etc/nginx/passenger.conf;\n' >> /etc/nginx/nginx.conf; cat /etc/nginx/temp.txt >> /etc/nginx/nginx.conf; exit"
            sudo rm -r /etc/nginx/temp.txt
            echo -e "${CYAN}설정끝${NC}"
            sudo service nginx restart
            echo -e "${CYAN}nginx를 재시작 했습니다.\n${NC}"
            echo "3" > ~/.progress;
        ;;
        "3")
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
            # Load RVM into a shell session *as a function*
            # Loading RVM *as a function* is mandatory
            # so that we can use 'rvm use <specific version>'
            if [[ -s \"$HOME/.rvm/scripts/rvm\" ]] ; then
                # First try to load from a user install
                source \"$HOME/.rvm/scripts/rvm\";
                echo \"using user install $HOME/.rvm/scripts/rvm\";
            elif [[ -s \"/usr/local/rvm/scripts/rvm\" ]] ; then
                # Then try to load from a root install
                source \"/usr/local/rvm/scripts/rvm\";
                echo \"using root install /usr/local/rvm/scripts/rvm\";
            else
                echo \"ERROR: An RVM installation was not found.\n\";
            fi

            rvm use ruby-$RV;

            cd /var/www/$MA/code;
            bundle install --deployment --without development test -j 2;
            printf '  adapter: sqlite3' >> config/database.yml;
            secret_key=`bundle exec rake secret`;
            sudo sed -i '22s/' config/secrets.yml;
            echo '  secret_key_base: $secret_key' >> config/secrets.yml;

            chmod 700 config deb;
            chmod 600 config/database.yml config/secrets.yml;
            bundle exec rake assets:precompile db:migrate RAILS_ENV=production;
            COM=`passenger-config about ruby-command | grep -i \"Command:\" `;
            COM=${COM:12:100};
            export $COM;
            exit;
            "
            echo "4" > ~/.progress;
        ;;
        "4")
            echo "step4";
            echo -e "${CYAN}server 주소를 입력하세요(http:// 제외)"
            printf "입력 : ${NC}";
            read server;
            #need to edit /etc/nginx/sites-enabled/myapp.conf
            sed -i "3,11d" /etc/nginx/sites-enabled/$MA.conf;
            printf "\tserver_name $server;\n\n\troot /var/www/$MA/code/public;\n\n\tpassenger_enabled on;\n\tpassenger_ruby $COM;\n}" >> /etc/nginx/sites-enabled/$MA.conf;
            #finish;
            sudo service nginx restart;
            echo -e "${CYAN}서버 설정 끝, 오류가 없는지 확인하세요.${NC}";
        ;;
    esac

#excuted shell first time..
else
    echo -e "${CYAN}======여러가지 준비 시작======${NC}";
    echo -e "${CYAN}Repository 업데이트 중...${NC}";
    sudo apt-get update > /dev/null;
    echo -e "${CYAN}업데이트 끝\n${NC}";
    echo -e "${CYAN}아래에 오류가 발생하면, 명령이 다 끝난후,\nsudo -i -H sh -c \" echo 'LC_ALL=\\\"en_US.UTf-8\\\"' >> /etc/environment \"\n을 입력해주세요.${NC}";
    sudo apt-get install -y curl gnupg build-essential >/dev/null;
    echo -e "${CYAN}\ncurl, gnupg, build-essential 설치 끝\n${NC}";
    echo -e "${CYAN}Key를 받는 중입니다...${NC}";
    sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 > /dev/null;
    sudo curl -sSL https://get.rvm.io | sudo bash -s stable >/dev/null;
    sudo usermod -a -G rvm `whoami` >/dev/null;
    if sudo grep -q secure_path /etc/sudoers; then sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh" && echo Environment variable installed; fi
    echo -e "${CYAN}서버 터미널에 다시 접속하세요.${NC}";
    touch ~/.progress;
    echo 1 > ~/.progress;
fi
unset CYAN;
unset NC;
