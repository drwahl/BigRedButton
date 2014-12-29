vmload
============

Lid Open: Nothing  
Button Press: Create VM (each press)  
Lid Close: Nuke all VMs created by the above button press(es)  

Most notably about this script is the lack of usage of ruby's openstack module.
This is due to the fact that it doesn't support network definition and if a
tenant has more than 1 network, the APIs don't "find" a default network and
simply die.  The nova bash client, however, allows for specifying the network
ID.  As such, this is what I defaulted to.  Eventually, I may port this over
to use the v3 OpenStack APIs, but until then, the nova bash CLI is easy/low
effort.

Another thing to note: you can't slam the button like an idiot due to the lack
of parallelized VM creation.  You must give the app a moment or two to actually
submit the VM creation request before giving it another whack. Same goes for
the lid closure action.

Finally, this module logs to syslog, so you can get a little bit of insight in
your syslog log file (/var/log/messages or /var/log/syslog most likely).
