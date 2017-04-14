# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: <<-SHELL
        yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        yum install -y https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        yum -y update
        yum -y install puppet
        yum clean all
        ifup eth1
    SHELL
    config.vm.provision "copying in puppet", type: "file", source: "./puppet/", destination: "~/puppet/"
    config.vm.provision "moving into place", type: "shell", inline: <<-SHELL
        mv /home/vagrant/puppet/facts/* /usr/share/ruby/vendor_ruby/facter/
        mv /home/vagrant/puppet/* /etc/puppet/modules/
        rmdir /home/vagrant/puppet
    SHELL
    config.vm.provision "running puppet", type: "shell", inline: "puppet apply /etc/puppet/modules/manifests/default.pp"

  config.vm.define "master" do |master|
    master.vm.box = "centos/7"
    master.vm.hostname = "kubernetes-master"
    master.vm.network "private_network", ip: "192.168.50.3"
    master.vm.network "forwarded_port", guest: 8080, host: 8080
  end

  config.vm.define "worker-1" do |kw1|
    kw1.vm.box = "centos/7"
    kw1.vm.hostname = "kubernetes-worker-1"
    kw1.vm.network "private_network", ip: "192.168.50.4"
  end

  config.vm.define "worker-2" do |kw2|
    kw2.vm.box = "centos/7"
    kw2.vm.hostname = "kubernetes-worker-2"
    kw2.vm.network "private_network", ip: "192.168.50.5"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 1
  end

end
