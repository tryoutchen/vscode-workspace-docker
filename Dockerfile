FROM ubuntu:20.04
ARG timezone
ARG username

RUN ln -snf /usr/share/zoneinfo/$timezone /etc/localtime \
 && echo $timezone > /etc/timezone

RUN yes | unminimize

RUN apt-get update \
 && apt-get install -y git-core gnupg flex bison build-essential zip curl \
  zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
  x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
  xsltproc unzip fontconfig rsync libssl-dev ant bc xxd pkg-config \
  libglib2.0-dev libcap-dev libattr1-dev autoconf libtool locales \
  bash-completion man manpages-posix golang libncurses5 iputils-ping \
  dnsutils autossh socat ssvnc gitk libswitch-perl cmake cpio e2tools

RUN apt-get install -y openjdk-11-jdk-headless
RUN apt-get install -y vim tmux sudo net-tools netcat uml-utilities dnsmasq iptables iproute2 silversearcher-ag xsel doxygen graphviz
RUN apt-get install -y python python3 python3-pip
RUN pip3 install pipenv
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y meld adwaita-icon-theme-full

RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
 && chmod a+x /usr/local/bin/repo


RUN curl -fL -o /usr/local/bin/jiri.zip https://chrome-infra-packages.appspot.com/dl/fuchsia/tools/jiri/linux-amd64/+/git_revision:84a845b5c2aed329d36ede6c68786585f34a7932 \
 && unzip /usr/local/bin/jiri.zip jiri -d /usr/local/bin \
 && chmod a+x /usr/local/bin/jiri \
 && rm /usr/local/bin/jiri.zip

RUN curl -fL -o /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.9.0/bazelisk-linux-amd64 \
 && chmod a+x /usr/local/bin/bazel

RUN curl -fL -o /usr/local/bin/buildifier https://github.com/bazelbuild/buildtools/releases/download/4.0.1/buildifier-linux-amd64 \
 && chmod a+x /usr/local/bin/buildifier

RUN useradd -m $username -s /bin/bash
RUN adduser $username sudo
RUN sed -ri 's/^%sudo\s+ALL=\(ALL:ALL\)\s+ALL/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers


RUN mkdir -p /home/$username/.vscode-server/extensions \
        /home/$username/.vscode-server-insiders/extensions \
    && chown -R $username \
        /home/$username/.vscode-server \
        /home/$username/.vscode-server-insiders

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $username /commandhistory \
    && echo $SNIPPET >> "/home/$username/.bashrc"

RUN echo "[[ -f ~/.envsetup ]] && . ~/.envsetup" >> "/home/$username/.bashrc"


RUN locale-gen "en_US.UTF-8"

ENV LANG=en_US.UTF-8
ENV HOME=/home/$username
ENV USER=$username

COPY bazel-complete.bash /etc/bash_completion.d/

RUN apt-get install -y openssh-server
RUN sed -ri 's/^#?#X11UseLocalhost\s+.*/X11UseLocalhost no/' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
CMD ["/usr/sbin/sshd", "-D"]
