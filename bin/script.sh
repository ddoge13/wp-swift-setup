#!/bin/bash

#CREATE "BIN" INSIDE /HOME/USER/
#ADD LINE TO ~./.profile:
#export PATH=$PATH:/root/bin/
#WHEN DONE DO chmod u+x file


waitForSeconds(){
    sleep $1
}

finallyDone(){
    clear
    echo congrats!
    echo
    echo wordpress successfully is installed with ssl!
    echo you should be able to access your website
    echo through your browser using your domain name provided!
    echo
    echo goodbye!
    exit
}

wordpress(){
    echo downloading wordpress...
    waitForSeconds 2
    cd /tmp && wget https://wordpress.org/latest.tar.gz
    tar -zxvf latest.tar.gz
    echo moving to /html/ and writing rights...
    waitForSeconds 2
    mv wordpress/* /var/www/html/wordpress
    chown -R www-data:www-data /var/www/html/wordpress/
    chmod -R 755 /var/www/html/wordpress/
    echo setting up wordpress database...
    waitForSeconds 2
    mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
    perl -pi -e 's/'database_name_here'/'"$db_name"'/g' /var/www/html/wordpress/wp-config.php
    perl -pi -e 's/'username_here'/'"$db_user"'/g' /var/www/html/wordpress/wp-config.php
    perl -pi -e 's/'password_here'/'"$db_pwd"'/g' /var/www/html/wordpress/wp-config.php
    echo check if cridentials are correct
    echo then save and exit file...
    waitForSeconds 2
    xterm -e emacs /var/www/html/wordpress/wp-config.php
    /etc/init.d/nginx restart
    echo did nginx successfully restart?
    repeat=true
    while [ $repeat = true ]
    do
	read -p "[y,n] " restart
	if [ $restart == "y" ]
	then
            finallyDone
            repeat=false
	elif [ $restart == "n" ]
	then
            echo open a new window and debug
	    echo then come back and type
	    repeat=false
	    ask=true
	    while [ $ask = true ]
	    do
		read -p "[continue] " progress
		if [ $progress == "continue" ]
		then
                    finallyDone
		    ask=false
		else
                    echo $progress is not a valid option
		    ask=true
		fi
	    done
	else
            echo $restart is not a valid option
	    repeat=true
	fi
    done        
    
}


autoRenew(){
    clear
    echo remember if you want your certificates to auto-renew
    echo add this line after [renew] inside /etc/cron.d/certbot
    echo
    echo --renew-hook systemctl reload nginx
    echo "(add doublequotes around systemctl reload nginx)"
    echo
    waitForSeconds 4
    wordpress
}


sslSetup(){
    clear
    echo generating certificates...
    cert=true
    while [ $cert = true ]
    do
	certbot certonly --agree-tos --email "$le_email" --webroot -w /var/lib/letsencrypt/ -d "$domain_name" -d www."$domain_name"
	echo did the certificates generate successfully?
	read -p "[y,n] " restart
	if [ $restart == "y" ]
	then
            rm /etc/nginx/sites-available/wordpress
	    rm /etc/nginx/sites-enabled/wordpress
	    mv $new_config /etc/nginx/sites-available/wordpress
	    ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
	    /etc/init.d/nginx restart
	    echo did nginx successfully restart?
	    repeat=true
	    while [ $repeat = true ]
	    do
		read -p "[y,n] " restart
		if [ $restart == "y" ]
		then
		    autoRenew
		    repeat=false
		elif [ $restart == "n" ]
		then
		    echo open a new window and debug
		    echo then come back and type
		    repeat=false
		    ask=true
		    while [ $ask = true ]
		    do
			read -p "[continue] " progress
			if [ $progress == "continue" ]
			then
			    autoRenew
			    ask=false
			else
			    echo $progress is not a valid option
			    ask=true
			fi
		    done
		else
		    echo $restart is not a valid option
		    repeat=true
		fi
	    done    
	elif [ $restart == "n" ]
	then
            echo open a new window and debug
	    echo then come back and type
	    cert=false
	    ask=true
	    while [ $ask = true ]
	    do
		read -p "[continue] " progress
		if [ $progress == "continue" ]
		then
                    cert=true
		    ask=false
		else
                    echo $progress is not a valid option
		    ask=true
		fi
	    done
	else
            echo $restart is not a valid option
	    cert=true
	fi
    done    


}


continueScript(){
    clear
    echo creating mySQL database with info provided...
    waitForSeconds 2
    echo "type in your mySQL root password"
    echo "in order to create a database for wordpress"
    echo
    mysql -p -u "root" -Bse "CREATE DATABASE $db_name;
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pwd';
GRANT ALL ON $db_name.* TO '$db_user'@'localhost' IDENTIFIED BY '$db_pwd' WITH GRANT OPTION;
FLUSH PRIVILEGES;"
    echo done!
    echo obtaining ssl...
    waitForSeconds 2
    echo installing certbot...
    waitForSeconds 2
    apt install certbot
    clear
    echo generating DH keys...
    waitForSeconds 2
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    echo verifying fqdn ownership...
    waitForSeconds 2
    mkdir -p /var/lib/letsencrypt/.well-known
    chgrp www-data /var/lib/letsencrypt
    chmod g+s /var/lib/letsencrypt
    echo creating webserver directory and setting rights...
    waitForSeconds 2
    mkdir /var/www/html/wordpress
    chown -R www-data:www-data /var/www/html/wordpress
    chmod -R 755 /var/www/html/wordpress

    mv $challenge /etc/nginx/snippets/letsencrypt.conf

    mv $ssl /etc/nginx/snippets/ssl.conf

    mv $config /etc/nginx/sites-available/wordpress

    ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/

    /etc/init.d/nginx restart

    echo did nginx successfully restart?
    repeat=true
    while [ $repeat = true ]
    do
	read -p "[y,n] " restart
	if [ $restart == "y" ]
	then
            sslSetup
            repeat=false
	elif [ $restart == "n" ]
	then
            echo open a new window and debug
	    echo then come back and type
	    repeat=false
	    ask=true
	    while [ $ask = true ]
	    do
		read -p "[continue] " progress
		if [ $progress == "continue" ]
		then
                    sslSetup
		    ask=false
		else
                    echo $progress is not a valid option
		    ask=true
		fi
	    done
	else
            echo $restart is not a valid option
	    repeat=true
	fi
    done

}

mainScript(){
    echo updating...

    waitForSeconds 2

    apt update

    clear

    echo installing nginx...

    waitForSeconds 2

    apt install nginx

    clear

    echo installing mariadb...

    waitForSeconds 2

    apt install mariadb-server mariadb-client

    clear

    echo when prompted hit enter, then keep pressing Y

    waitForSeconds 2

    mysql_secure_installation

    clear

    echo installing php modules...

    waitForSeconds 2

    apt install php-fpm php-common php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-ldap php-zip php-curl

    clear

    php -m | grep mcrypt

    echo mcrypt was not installed...
    echo manually installing...

    waitForSeconds 2

    apt install php-dev libmcrypt-dev php-pear

    pecl channel-update pecl.php.net

    pecl install mcrypt-1.0.1

    php -v

    echo "^ what is your php version ^"
    echo "only include the first two numbers (ex: 7.2)"
    echo
    read -p "php: " php_ver

    echo "extension=mcrypt.so" >> /etc/php/"$php_ver"/cli/php.ini

    echo "added extension=mcrypt.so to php.ini..."

    waitForSeconds 2

    echo mcrypt installed...

    php -m | grep mcrypt

    perl -pi -e 's/'7.2'/'"$php_ver"'/g' $config
    perl -pi -e 's/'7.2'/'"$php_ver"'/g' $new_config

    waitForSeconds 2

    echo temporarily installing xterm...

    waitForSeconds 2

    apt install xterm

    clear

    echo increasing php storage...

    waitForSeconds 2
    
    perl -pi -e 's/'post_max_size = 8M'/'post_max_size = 100M'/g' /etc/php/"$php_ver"/cli/php.ini
    perl -pi -e 's/'memory_limit = 128M'/'memory_limit = -1'/g' /etc/php/"$php_ver"/cli/php.ini
    perl -pi -e 's/'max_execution_time = 30'/'max_execution_time = 360'/g' /etc/php/"$php_ver"/cli/php.ini
    perl -pi -e 's/'upload_max_filesize = 2M'/'upload_max_filesize = 100M'/g' /etc/php/"$php_ver"/cli/php.ini        

    continueScript
}

#start of script


challenge=challenge.txt
ssl=ssl.txt
config=config.txt
new_config=config-cont.txt

if [ -f "$challenge" ]
then
    echo $challenge exists...
else
    echo "$challenge not found"
    exit
fi

if [ -f "$ssl" ]
then
    echo $ssl exists...
else
    echo "$ssl not found"
    exit
fi

if [ -f "$config" ]
then
    echo $config exists...
else
    echo "$config not found"
    exit
fi

if [ -f "$new_config" ]
then
    echo $new_config exists...
else
    echo "$new_config not found"
    exit
fi

root_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ":$root_path:" == *":/root/bin:"* ]]; then
    echo bin folder is inside of root...
    echo please type in desired cridentials for mySQL database
    echo
    read -p "database name: " db_name
    read -p "database user: " db_user
    read -p "user pwd: " db_pwd
    echo Thanks!
    waitForSeconds 2
    clear
    echo please type your desired email and domain name
    echo for use with lets encrypt and setup:
    read -p "email: " le_email
    read -p "domain: " domain_name
    echo Thanks!
    perl -pi -e 's/'example.com'/'"$domain_name"'/g' $config
    perl -pi -e 's/'example.com'/'"$domain_name"'/g' $new_config
    emacs /root/bin/"$config"
    emacs /root/bin/"$new_config"
    waitForSeconds 2
    mainScript
else
    echo place bin folder inside of root directory using mv bin/ ~/
    exit
fi
