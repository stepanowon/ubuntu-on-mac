# Ubuntu-24.04 리눅스 3개 노드 설정 (MacOS)
 
## 설정 내용
* user1/asdf 로 사용자 생성
* user1을 sudoer로 등록
* git, docker 설치
* hostname : server1 ~ server3
* ip 주소 : 192.168.56.101~103
* 모든 vm에 hosts 파일 등록 : server1~3

## 설치방법
* Oracle VirtualBox - 다음 경로에서 다운로드받아 설치합니다.
  - https://www.virtualbox.org/wiki/Downloads
    * VirtualBox Extension Pack 도 함께 다운로드 받습니다.
  - intel chip : macOS / Intel hosts
  - M1,M2,M3 chip : macOS / Apple Silicon hosts

  - 설치 시 주의사항
    * 설치 도중 Python을 설치하는 과정이 진행될 수 있음
    * 설치 도중 또는 직후에 다음과 같은 오류가 발생하는 경우 조치사항
    ```sh
    system Extension Blocked
    A program tried to load new system extension(s) signed by "Oracle America, Inc." ...

    # Mac의 '시스템 설정' > '개인정보 보호 및 보안' 으로 이동
    # '보안' 섹션에서 VirtualBox 응용프로그램 '허용' 하고 재부팅
    ```
  - 설치가 완료된 후에 VirtualBox를 실행하고 도구의 '三'을 클릭한 후 '확장'을 추가합니다.
  - 앞에서 다운로드 받은 확장 팩을 설치합니다.
* Vagrant 설치 - 다음 경로에서 다운로드받아 설치합니다.
  - https://developer.hashicorp.com/vagrant/install
  - intel chip : AMD64
  - M1,M2,M3 chip : ARM64

* Vagrantfile과 script를 다운로드하여 설치
```sh
git clone https://github.com/stepanowon/ubuntu-on-mac
cd ubuntu-on-mac
vagrant up

# 모두 설치 후 
vagrant reload

# 사용자 계정/패스워드 --> user1/asdf
```
---
## Jenkins 설치

#### JDK 설치
```sh
# server1, 2, 3 모두에서 실행
sudo apt update 
sudo apt install openjdk-21-jdk-headless -y
```

#### Jenkins 설치
```sh
# server1에서만 실행
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y
```

#### docker 설치(혹시 설치하지 않았다면)
```sh
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -a -G docker jenkins  

sudo systemctl enable docker
sudo systemctl start docker
sudo chmod 666 /var/run/docker.sock     
```

#### jenkins 초기 패스워드 획득
```sh
# server1에서 실행
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### Jenkins 서버 접속
* 브라우저를 열고 http://192.168.56.101:8080 으로 접속함


---
## Jenkins 분산 에이전트 추가
#### 사전 조건
* Agent Node로 등록할 호스트, 인스턴스에는 JDK가 미리 설치되어 있어야 함

#### SSH 키 생성(server1 에서)
```ssh
# ssh-keygen -t rsa 명령어로 키페어 생성
# 생성된 키페어 중 Public Key를 server, server3으로 복사
   ssh-copy-id 192.168.56.102
   ssh-copy-id 192.168.56.103
# jenkins의 Jenkins관리-Credential에 ssh Private Key 등록
```

#### 노드 추가 시작(Jenkins UI 화면에서)
```sh
# Jenkins 관리 - Nodes 로 이동하여 New Node 버튼 클릭
# 노드명은 적절히 예) 서버명 입력하고 Type을 Permanent Agent 지정 ---> Create

# ---다음 단계로---
# 설명은 간단히 알아보기 쉽게 : 서버명, IP 주소등 입력
# Number of executors : 2
# Remote Root Directory : /home/user1/jenkins-agent   (사용자 홈디렉토리에 생성)
   * 디렉토리 미리 생성해두어야 함
   * 디렉토리가 명령 실행시에 접근할 수 있는 권한이 있어야 함.
   * 루트에 디렉토리를 생성했다면 sudo!!
# Labels : agent 지정시 사용할 레이블
# launch method : launch agent via SSH
# Host : 192.168.56.102(연결하려는 Agent의 주소)
# Credentials : Jenkins Credentials에 등록한 자격증명 지정
# Host Key Verification Strategy : Manually trusted key Verification Strategy
# Availability : Keep this agent online as much as posiible
```

#### 노드간 시간이 일치하지 않을 때
```sh
# 모든 노드에서 다음 명령어 실행
sudo timedatectl set-ntp yes
```