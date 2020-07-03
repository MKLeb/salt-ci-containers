FROM fedora:32

RUN dnf update -y && \
    dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
      libvirt-daemon-driver-qemu \
      libvirt-daemon-driver-storage-core \
      libvirt-client \
      qemu-kvm \
      qemu-img \
      selinux-policy \
      selinux-policy-targeted \
      nftables \
      iptables \
      libgcrypt \
      openssh-server \
      openssh-clients \
      python3 \
      python3-pip \
      python3-libvirt && \
    dnf clean all && \
    pip3 install --no-cache-dir \
      msgpack==0.5.6 \
      requests \
      distro \
      pycryptodomex \
      MarkupSafe \
      Jinja2 \
      pyzmq \
      PyYAML \
      urllib3 \
      chardet \
      certifi

RUN echo 'listen_tls = 0'     >> /etc/libvirt/libvirtd.conf; \
    echo 'listen_tcp = 1'     >> /etc/libvirt/libvirtd.conf; \
    echo 'tls_port = "16514"' >> /etc/libvirt/libvirtd.conf; \
    echo 'tcp_port = "16509"' >> /etc/libvirt/libvirtd.conf; \
    echo 'auth_tcp = "none"'  >> /etc/libvirt/libvirtd.conf; \
    # Disable default libvirt network \
    rm -f /etc/libvirt/qemu/networks/autostart/default.xml; \
    # SSH login fix. Otherwise user is kicked off after login \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
    mkdir -p /var/lib/libvirt/images /salt /root/.ssh

WORKDIR /salt

ADD http://tinycorelinux.net/11.x/x86/release/Core-current.iso /var/lib/libvirt/images/
COPY init.sh /init.sh
COPY core-vm.xml /core-vm.xml
COPY ssh/id_rsa /root/.ssh/id_rsa
COPY ssh/id_rsa /etc/ssh/ssh_host_rsa_key
COPY ssh/id_rsa.pub /etc/ssh/ssh_host_rsa_key.pub
COPY ssh/id_rsa.pub /root/.ssh/id_rsa.pub
COPY ssh/id_rsa.pub /root/.ssh/authorized_keys
COPY ssh/known_hosts /root/.ssh/known_hosts
CMD [ "/init.sh" ]
