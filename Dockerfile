FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo curl git vim wget zip unzip dosfstools fdisk util-linux && \
    apt-get install -y systemd udev

# Create a new user "thingino" with a home directory and a bash shell,
# and then create a "bin" directory in its home.
RUN useradd -ms /bin/bash thingino && \
    mkdir -p /home/thingino/bin && \
    chown thingino:thingino /home/thingino/bin && \
    usermod -aG sudo thingino

# Configure passwordless sudo for thingino by creating a sudoers file for the user.
RUN echo "thingino ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/thingino && \
    chmod 0440 /etc/sudoers.d/thingino

# Switch to the new user
USER thingino

WORKDIR /home/thingino/bin

CMD ["bash"]

