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
그 후, script가 부탁하는 대로 입력하면 됩니다.
<br><br>

c9에서 쓰는 루비 버전은 2.3.0 입니다.(2017.07.20)
