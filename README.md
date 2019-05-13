# wp-swift-setup

This is a bash script that automatically installs:

- Wordpress
- Nginx
- PHP 7
- MariaDB
- LetsEncrypt


## What does it do?


The script installs wordpress on Nginx and creates the database using
mariadb. This script also installs a **free ssl certificate** before the
wordpress website is installed to ensure encrypted connections from the beginning.
User input is required for some of the commands.

**THE FILES SHOULD NOT BE RENAMED OR MOVED OUTSIDE OF `bin/`**

**DO NOT EDIT *ANY* FILES UNLESS YOU KNOW WHAT YOU ARE DOING**

*If the program runs correctly, you should be able to access your wordpress website by
entering your domain name into the browser.*

You can check your ssl security by entering your domain into [SSL Labs](https://www.ssllabs.com/ssltest/)

**YOUR WEBSITE IS HSTS READY** You can preload your website by entering your domain
into the [Preload List](https://hstspreload.org/) which is supported in many browsers
see [here](https://caniuse.com/#feat=stricttransportsecurity).



##Prerequisites


**HAVE A FULLY QUALIFIED DOMAIN**

- Use a fqdn from a provider such as godaddy and create an A record that points to your public IP address
  as well as a CNAME record for your "www" prefix that points to the A record.
- Have port 80 and port 443 forwarded on your router for the host's local IP



## Script Setup


For the script to run properly the following is required:

- `bin/` folder is in root directory
- add `export PATH=$PATH:/root/bin` to your bash profile (located in `~/.profile` in Ubuntu)

**If everything is ready, the script should be able to start with:**

`./script.sh`

