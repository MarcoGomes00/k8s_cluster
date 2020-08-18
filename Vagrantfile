# Make sure required plugins are installed
# ex: required_plugins = %w({:name => "vagrant-hosts", :version => ">= 2.8.0"})
required_plugins = [{:name => "vagrant-hosts", :version => ">= 2.8.0"}, {:name => "vagrant-vbguest", :version => ">= 0.16.0"}]

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin?(plugin[:name], plugin[:version]) }
if not plugins_to_install.empty?
  plugins_to_install.each { |plugin_to_install|
    puts "Installing plugin: #{plugin_to_install[:name]}, version #{plugin_to_install[:version]}"
    if system "vagrant plugin install #{plugin_to_install[:name]} --plugin-version \"#{plugin_to_install[:version]}\""
    else
      abort "Installation of one or more plugins has failed. Aborting."
    end
  }
  exec "vagrant #{ARGV.join(' ')}"
end

require 'yaml'
conf_file = File.join(File.dirname(__FILE__), 'vagrant_overrides.yaml')
conf = File.exists?(conf_file)? YAML.load_file(conf_file) : {}

MEM_MASTER         = conf['MEM_MASTER'] || 2048
MEM_WORKER         = conf['MEM_WORKER'] || 4096
CPU_MASTER         = conf['CPU_MASTER'] || 2
CPU_WORKER         = conf['CPU_WORKER'] || 2
DISTRO             = conf['DISTRO'] || "centos/7"
GUI                = conf['GUI'] || false
NETWORK            = conf['NETWORK'] || "10.0.0."
NETMASK            = conf['NETMASK'] || "255.255.255.0"
NUMBER_MASTERS     = conf['NUMBER_MASTERS'] || 1
NUMBER_WORKERS     = conf['NUMBER_WORKERS'] || 1
KUBEADM_VERSION    = conf['KUBEADM_VERSION'] || "1.18.8-0"
MASTER_EXPOSE_PORT = conf['MASTER_EXPOSE_PORT'] || false
WORKER_EXPOSE_PORT = conf['WORKER_EXPOSE_PORT'] || false

Vagrant.configure("2") do |config|
  (1..NUMBER_MASTERS).each do |node|
    config.vm.define :"k8smaster-#{node}" do |master|
      master.vm.box = DISTRO
      master.vm.provider :virtualbox do |vbox|
        vbox.name = "k8smaster-#{node}"
        vbox.memory = MEM_MASTER
        vbox.cpus = CPU_MASTER
        vbox.gui = GUI
      end
    master.vm.hostname = "k8smaster#{node}"
    master.vm.network 'private_network', ip: NETWORK + "1#{node}", netmask: NETMASK
    master.vm.provision :hosts, :sync_hosts => true
    master.vm.provision :hosts, :add_localhost_hostnames => false
    master.vm.provision "shell", path: "install_kubeadm.sh", args: ["k8smaster#{node}"]
    master.vm.provision "shell", path: "kubeadm_init.sh", privileged: false
    end
  end

  (1..NUMBER_WORKERS).each do |node|
    config.vm.define :"k8sworker-#{node}" do |worker|
      worker.vm.box = DISTRO
      worker.vm.provider :virtualbox do |vbox|
        vbox.name = "k8sworker-#{node}"
        vbox.memory = MEM_WORKER
        vbox.cpus = CPU_WORKER
        vbox.gui = GUI
      end
    worker.vm.hostname = "k8sworker#{node}"
    worker.vm.network 'private_network', ip: NETWORK + "1#{node}", netmask: NETMASK
    worker.vm.provision :hosts, :sync_hosts => true
    worker.vm.provision :hosts, :add_localhost_hostnames => false
    worker.vm.provision "shell", path: "install_kubeadm.sh"
    end
  end
end