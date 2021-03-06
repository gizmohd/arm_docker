FROM ubuntu:latest

USER 0

RUN apt-get update && apt-get install -y apt-transport-https  apt-utils
RUN apt-get install git wget software-properties-common -y
 

#setup repos

#RUN echo 'http://ppa.launchpad.net/heyarje/makemkv-beta/ubuntu bionic main' >> /etc/apt/sources.list
#RUN cat /etc/apt/sources.list
RUN add-apt-repository ppa:heyarje/makemkv-beta
RUN add-apt-repository ppa:stebbins/handbrake-releases
RUN add-apt-repository ppa:mc3man/bionic-prop

#create the arm user 
RUN useradd -rm -d /home/arm -s /bin/bash -g root -G cdrom -u 1000 arm

#install dependancies
RUN apt-get update -y
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get install makemkv-bin makemkv-oss -y
RUN apt-get install handbrake-cli libavcodec-extra -y

RUN echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections
RUN echo "postfix postfix/mailname string example.org" | debconf-set-selections
RUN apt-get install --assume-yes postfix -yq
RUN apt-get install abcde flac imagemagick glyrc cdparanoia -yq
RUN apt-get install at -y

RUN apt-get install python3 python3-pip -y
RUN apt-get install libcurl4-openssl-dev libssl-dev -y

RUN echo "libdvd-pkg      libdvd-pkg/title_u        note" | debconf-set-selections
RUN echo "libdvd-pkg      libdvd-pkg/first-install        note" | debconf-set-selections
RUN echo "libdvd-pkg      libdvd-pkg/upgrade      note" | debconf-set-selections
RUN echo "libdvd-pkg      libdvd-pkg/post-invoke_hook-install     boolean true" | debconf-set-selections
RUN echo "libdvd-pkg      libdvd-pkg/build        boolean true" | debconf-set-selections
RUN echo "libdvd-pkg      libdvd-pkg/title_b-i    note" | debconf-set-selections
RUN echo "libdvd-pkg      libdvd-pkg/first-install        note" | debconf-set-selections


RUN DEBIAN_FRONTEND=noninteractive apt-get install libdvd-pkg -yq
RUN dpkg-reconfigure libdvd-pkg 
RUN apt install default-jre-headless -y

#Setup Drives
RUN mkdir -p /mnt/dev/sr0
RUN echo '/dev/sr0  /mnt/dev/sr0  udf,iso9660  user,noauto,exec,utf8  0  0' >> /etc/fstab

RUN mkdir /opt/arm
RUN chown arm:cdrom /opt/arm
RUN chmod 775 /opt/arm
RUN git clone https://github.com/gizmohd/automatic-ripping-machine.git /opt/arm
#RUN git clone https://github.com/automatic-ripping-machine/automatic-ripping-machine.git /opt/arm

WORKDIR /opt/arm
RUN git checkout v2_master

RUN pip3 install -r requirements.txt 
RUN ln -s /opt/arm/setup/51-automedia.rules /lib/udev/rules.d/
RUN ln -s /opt/arm/setup/.abcde.conf /home/arm/

COPY arm.yaml .

#Clean up existing packages to save space
RUN apt-get clean

#change user to the arm user
USER arm