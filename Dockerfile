FROM ubuntu:16.04

RUN apt update
RUN apt install -y git

RUN apt-add-repository ppa:fish-shell/release-2
RUN apt update

# Build things from source first
RUN mkdir /src
WORKDIR /src

# Install OMF
RUN apt install -y fish man
RUN git clone https://github.com/oh-my-fish/oh-my-fish.git

# Install node
RUN apt install -y curl
RUN curl -O https://nodejs.org/download/release/v6.12.0/node-v6.12.0-linux-x64.tar.gz
RUN tar -C /usr/local --strip-components 1 -xzf node-v6.12.0-linux-x64.tar.gz

# Set the locale
RUN apt install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 
 
# Setup user access
RUN apt install -y sudo
RUN useradd -ms $(which fish) developer
RUN echo "developer:$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)" | chpasswd
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/developer
RUN su developer -c '/src/oh-my-fish/bin/install --offline --noninteractive --yes'
RUN su developer -c 'omf i bobthefish'

# Setup git
RUN su developer -c 'git config --global user.name "Tanner Engbretson"'
RUN su developer -c 'git config --global user.email "tanner@redoxengine.com"'

# Setup ssh access
RUN apt install -y openssh-server vim
RUN mkdir /var/run/sshd

EXPOSE 22

CMD ["/usr/sbin/sshd -D -o AuthorizedKeysFile <(echo $PUBLIC_KEY)"]
