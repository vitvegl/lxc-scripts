#!/usr/bin/env ruby
require 'optparse'
require 'fileutils'

POST_INSTALL_SCRIPT = File.expand_path('./setup.sh')
SSHDIR = '/home/ubuntu/.ssh'
SSH_PUBKEY = File.join [ENV['HOME'], '.ssh', 'id_rsa.pub']

opt = OptionParser.new do |o|
  o.on("--container=name", String) do |container|
    @container = container
  end
  o.on("--create=boolean", TrueClass) do |boolean|
    @create = boolean
  end
  o.on("--pubkey-copy=boolean", TrueClass) do |boolean|
    @key = boolean
  end
end

def __lxc_create_container container
  if container.is_a? String
    system "lxc-create -t download -n #{container}"
  else
    raise TypeError
  end
end

def __lxc_script_copying container
  if container.is_a? String
    raise "Script setup.sh not found in #{Dir.pwd}" unless File.exists? POST_INSTALL_SCRIPT
    destdir = File.join ['/var/lib/lxc', container, '/rootfs/root']
    begin
      FileUtils.cp POST_INSTALL_SCRIPT, destdir
      print "Script was copied into #{destdir}\n"
      print "Run this as root: \nlxc-attach -n #{container} && cd /root && . ./run.sh\n"
    rescue Errno::ENOENT, IOError => exception
      puts exception.message
    end
  else
    raise TypeError
  end
end

def __lxc_ssh_key_copying container
  if container.is_a? String
    begin
      destdir = File.join ['/var/lib/lxc', container, '/rootfs']
      destkeydir = File.join [destdir, SSHDIR]
      Dir.mkdir destkeydir, 0755 unless Dir.exists? destkeydir
      FileUtils.cp SSH_PUBKEY, "#{destkeydir}/authorized_keys"
      puts "authorized_keys was copied into #{destkeydir}"
    rescue Errno::ENOENT, IOError => exception
      puts exception.message
      puts "authorized_keys wasn't added ("
    end
  else
    raise TypeError
  end
end

def run
  if @create.nil? or @create == false
    __lxc_script_copying @container
  elsif @create == true
    __lxc_create_container @container
    __lxc_script_copying @container
    __lxc_ssh_key_copying @container if @key == true
  end
end

begin
  opt.parse!
  run
rescue TypeError, OptionParser::InvalidArgument, OptionParser::MissingArgument
  print opt.help
  exit 1
end
