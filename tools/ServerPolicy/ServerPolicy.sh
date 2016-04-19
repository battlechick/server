#!/bin/sh
while true; do echo '<?xml version="1.0"?>
<cross-domain-policy>
<allow-access-from domain="*" to-ports="1-65536"/>
</cross-domain-policy>' | nc -l 843; done
