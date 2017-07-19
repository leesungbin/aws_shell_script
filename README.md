# aws setting for rails
* for EC2, ubuntu
* security group 에서 HTTP,HTTPS 를 추가해주세요.

ssh를 통해 서버 터미널로 접속한 후,<br><br>
<strong>git clone https://github.com/leesungbin/awset<strong><br><br>
명령으로 서버에 shell script 파일을 가져 옵니다.

<strong>cd awset;</strong><br>
<strong>chmod 777 *;</strong><br>
//권한은 그냥 다 줍시다.

<strong>./set_rails.sh</strong><br><br>

로 script를 실행해 줍니다.<br>
그 후, script가 부탁하는 대로 입력하면 됩니다.<br>
중간에 뜨는 warning 은 무시하셔도 됩니다...<br>
<br>
server 주소는 현재 IPv4 public IP 로 입력했을 때만 서버가 정상적으로 세팅 됩니다.
왜 그런지는 아직 잘 모르겠습니다.

c9에서 쓰는 루비 버전은 2.3.0 입니다.(2017.07.20)
========================================================================
shell을 한번만 딱 실행해서 서버 세팅이 완료되게 끔 만들고 싶었는데, 포기하고,<br>
같은 파일을 여러번 실행해서 서버가 세팅될 수 있도록 만들었습니다.<br>
home 경로에 .progress 파일을 만들어서, 여러번 실행될 때 마다 다른 작업을 하도록 하였습니다.<br>
실행이 끝나고 나면 .progress 파일은 삭제집니다.
