if $osfamily == 'RedHat' and $operatingsystemmajrelease == '7' {
    if $hostname =~ /^(.*)master/ {
        file { "/etc/yum.repos.d/virt7-docker-common-release.repo":
            ensure => file,
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            source => "/etc/puppet/modules/files/virt7-docker-common-release.repo",
        } ->
        package { [ 'kubernetes', 'etcd', 'flannel' ]:
            ensure => 'installed',
        } ->
        file { "/etc/etcd/etcd.conf":
          ensure => file,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          source => "/etc/puppet/modules/files/master/etcd_config",
        } ->
        file { "/etc/kubernetes/config":
          ensure => file,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template("/etc/puppet/modules/templates/master/k8s_config.erb"),
        } ->
        file { "/etc/kubernetes/apiserver":
          ensure => file,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template("/etc/puppet/modules/templates/master/k8s_apiserver_config.erb"),
        } ->
        service { 'etcd':
            ensure => 'running',
            enable => true,
        } ->
        exec { 'etcd bootstrap check':
            command => 'etcdctl mkdir /kube-centos/network; etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"',
            path   => '/usr/bin:/usr/sbin:/bin:/sbin',
            unless  => 'etcdctl ls /kube-centos/network',
        } ->
        file { "/etc/sysconfig/flanneld":
          ensure => file,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template("/etc/puppet/modules/templates/master/k8s_flanneld_config.erb"),
        } ->
        service { [ 'kube-apiserver', 'kube-controller-manager', 'kube-scheduler', 'flanneld' ]:
            ensure => 'running',
            enable => true,
        }
    }
    elsif $hostname =~ /^(.*)worker/ {
        file { "/etc/yum.repos.d/virt7-docker-common-release.repo":
            ensure => file,
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            source => "/etc/puppet/modules/files/virt7-docker-common-release.repo",
        } ->
        package { [ 'kubernetes', 'etcd', 'flannel' ]:
            ensure => 'installed',
        } ->
        file { "/etc/kubernetes/config":
          ensure => file,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template("/etc/puppet/modules/templates/master/k8s_config.erb"),
        } ->
        file { "/etc/kubernetes/kubelet":
          ensure => file,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template("/etc/puppet/modules/templates/worker/k8s_kublet_config.erb"),
        } ->
        file { "/etc/sysconfig/flanneld":
          ensure => file,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template("/etc/puppet/modules/templates/worker/k8s_flanneld_config.erb"),
        } ->
        service { [ 'kube-proxy', 'kubelet', 'flanneld', 'docker' ]:
            ensure => 'running',
            enable => true,
        }
    }
    else {
        fail('Expecting a hostname that contains master or worker.')
    }
}
else {
    fail('This module is designed for RedHat/CentOS/OEL 7.')
}
