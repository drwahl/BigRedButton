require 'rubygems'
require 'dream_cheeky'
require 'syslog'
require 'espeak'

include ESpeak

$SPEAK_VM_DEPLOYED = Speech.new("V M deployed!")
$SPEAK_VM_DELETED = Speech.new("V Ems deleted!")
$SPEAK_PREPARED = Speech.new("Prepared to launch V Ems!")

#OpenStack variables
$OS_USERNAME = 'user'
$OS_API_KEY = 'pass'
$OS_TENANT_ID = 'uuid'
$OS_TENANT_NAME = 'tenant'
$OS_AUTH_URL = 'https://keystone.dream.io/v2.0'
$OS_IMAGE_ID = 'uuid'
$OS_FLAVOR_ID = '100'
$OS_NETWORK_ID = 'uuid'
$OS_SSH_KEY_NAME = 'key'

#GLOBAL CONSTANTS, do not modify
$OS_CREDS = "--os-password='#{$OS_API_KEY}' --os-tenant-id='#{$OS_TENANT_ID}' --os-auth-url='#{$OS_AUTH_URL}' --os-username='#{$OS_USERNAME}' --os-tenant-name='#{$OS_TENANT_NAME}'"
$VM_PREFIX = 'BigRedButtonVM-'

#if we don't set this here and the app is started with the lid open, this
#variable isn' instantiated, which breaks ruby
$vmcount = 0

DreamCheeky::BigRedButton.run do
  #on open, prepare temp file for VM tracking
  open do
    $vmcount = 0
    $vmhash = Hash.new({})
    $SPEAK_PREPARED.speak
  end

  #on close, nuke VMs and close the file handle
  close do
    $vmhash.each do |key, value|
      Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.info "Deleteing VM with UUID of #{value['uuid']}" }
      `nova #{$OS_CREDS} delete #{value['uuid']}`
    end
    $SPEAK_VM_DELETED.speak
    $vmhash = Hash.new({})
    $vmcount = 0
  end

  #for each button press, create a new VM
  push do
    $vmcount += 1
    vm_uuid = `nova #{$OS_CREDS} boot --flavor #{$OS_FLAVOR_ID} --image #{$OS_IMAGE_ID} --key-name #{$OS_SSH_KEY_NAME} --nic net-id=#{$OS_NETWORK_ID} '#{$VM_PREFIX}#{$vmcount}' | grep '| id' | awk '{print $4}'`
    $SPEAK_VM_DEPLOYED.speak
    Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.info "Created VM with UUID of #{vm_uuid}" }
    newvmhash = Hash.new({})
    newvmhash['uuid'] = vm_uuid.tr('\n','')
    newvmhash['name'] = "#{$VM_PREFIX}#{$vmcount}"
    $vmhash[:"vm#{$vmcount}"] = newvmhash
  end
end
