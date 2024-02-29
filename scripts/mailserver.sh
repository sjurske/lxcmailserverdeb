#!/usr/bin/env bash
source misc/color.func
clear
printf "\n${BGreen}-----Running Mailserver installation script-----${Color_Off}\n"
printf "${BGreen}---------Installing & Updating software---------${Color_Off}\n"
bash misc/main_deps.sh
bash misc/update_sources.sh
bash misc/mailserver_deps.sh
printf "${BGreen}------Start and enable required services...-----${Color_Off}\n"
systemctl start mariadb && systemctl enable mariadb
systemctl start postfix && systemctl enable postfix
systemctl start dovecot && systemctl enable dovecot
printf "${BGreen}----------Creating virtual mail user...---------${Color_Off}\n"
mkdir /home/vmail
useradd -u 5000 vmail -d /home/vmail/
groupadd -g 5000 vmail
usermod -a -G vmail vmail
chown -R vmail:vmail /home/vmail/
printf "${BGreen}----------Creating Dovecot SSL Cert...----------${Color_Off}\n"
openssl req -new -x509 -nodes -newkey rsa:4096 -keyout /etc/ssl/private/vmail.key -out /etc/ssl/private/vmail.crt -days 365
chmod 400 /etc/ssl/private/vmail.key
chmod 444 /etc/ssl/private/vmail.crt
printf "${BGreen}-----------Configuring server files...----------${Color_Off}\n"
bootstrapmysql () {
  mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS $DATABASE;
GRANT SELECT ON $DATABASE.* TO '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';
FLUSH PRIVILEGES;
USE $DATABASE;
CREATE TABLE IF NOT EXISTS virtual_domains (DomainId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,DomainName VARCHAR(50) NOT NULL);
CREATE TABLE IF NOT EXISTS virtual_mailboxes (MailId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,DomainId INT NOT NULL,password VARCHAR(255) NOT NULL,Email VARCHAR(100) UNIQUE KEY NOT NULL,FOREIGN KEY (DomainId) REFERENCES virtual_domains(DomainId) ON DELETE CASCADE);
CREATE TABLE IF NOT EXISTS virtual_aliases (AliasId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,DomainId INT NOT NULL,Source VARCHAR(100) NOT NULL,Destination VARCHAR(100) NOT NULL,FOREIGN KEY (DomainId) REFERENCES virtual_domains(DomainId) ON DELETE CASCADE);
INSERT INTO $DATABASE.virtual_domains(id, name) VALUES('1', '$DOMAIN'),('2', 'mail.$DOMAIN');
INSERT INTO $DATABASE.virtual_users(id, domain_id, password, email)VALUES('1', '1', ENCRYPT('$E_PASS', CONCAT('\$6\$', SUBSTRING(SHA(RAND()), -16))), '$EMAIL');
EOF
}
bootstrapmysql
printf "${BGreen}----------------MYSQL CONFIGURED----------------${Color_Off}\n"

postfix_main_cf=$(cat <<EOF
smtpd_banner = $DOMAIN ESMTP mail.$DOMAIN (Debian/GNU)
biff = no
append_dot_mydomain = no
readme_directory = no
compatibility_level = 2
append_dot_mydomain = no
biff = no
config_directory = /etc/postfix
dovecot_destination_recipient_limit = 1
smtpd_tls_cert_file=/etc/letsencrypt/live/mail.$DOMAIN/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/mail.$DOMAIN/privkey.pem
smtpd_sasl_auth_enable = yes
smtpd_sasl_security_options = noanonymous, noplaintext
smtpd_sasl_tls_security_options = noanonymous
smtpd_tls_auth_only = yes
smtpd_tls_security_level = may
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = $DOMAIN
mydomain = $DOMAIN
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = $DOMAIN
mydestination = $DOMAIN, localhost.$DOMAIN, localhost
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 $PUB_IP/31
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = ipv4
smtp_bind_address = $PUB_IP
smtpd_recipient_restrictions = permit_mynetworks
home_mailbox = Maildir/
virtual_transport = dovecot
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
virtual_mailbox_domains = mysql:/etc/postfix/virtual-mailbox-domains.conf
virtual_mailbox_maps = mysql:/etc/postfix/virtual-mailbox-users.conf
virtual_alias_maps = mysql:/etc/postfix/virtual-alias-maps.conf
relayhost = vps.transip.email:587
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_use_tls = yes
smtp_tls_security_level = encrypt
smtp_tls_note_starttls_offer = yes
EOF
)
echo "$postfix_main_cf" | sudo tee /etc/postfix/main.cf > /dev/null

postfix_master_cf=$(cat << "EOF"
smtp      inet  n       -       n       -       -       smtpd
submission inet n       -       n       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_tls_auth_only=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
pickup    unix  n       -       n       60      1       pickup
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr

tlsmgr    unix  -       -       n       1000?   1       tlsmgr
rewrite   unix  -       -       n       -       -       trivial-rewrite
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
trace     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
flush     unix  n       -       n       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       n       -       -       smtp
relay     unix  -       -       n       -       -       smtp
        -o syslog_name=postfix/$service_name
showq     unix  n       -       n       -       -       showq
error     unix  -       -       n       -       -       error
retry     unix  -       -       n       -       -       error
discard   unix  -       -       n       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       n       -       -       lmtp
anvil     unix  -       -       n       -       1       anvil
scache    unix  -       -       n       -       1       scache
maildrop  unix  -       n       n       -       -       pipe
  flags=DRXhu user=vmail argv=/usr/bin/maildrop -d ${recipient}
uucp      unix  -       n       n       -       -       pipe
  flags=Fqhu user=uucp argv=uux -r -n -z -a$sender - $nexthop!rmail ($recipient)
ifmail    unix  -       n       n       -       -       pipe
  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r $nexthop ($recipient)
bsmtp     unix  -       n       n       -       -       pipe
  flags=Fq. user=bsmtp argv=/usr/lib/bsmtp/bsmtp -t$nexthop -f$sender $recipient
scalemail-backend unix -       n       n       -       2       pipe
  flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store ${nexthop} ${user} ${extension}
mailman   unix  -       n       n       -       -       pipe
  flags=FRX user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py ${nexthop} ${user}
dovecot   unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -f ${sender} -d ${recipient}
EOF
)
echo "$postfix_master_cf" | sudo tee /etc/postfix/master.cf > /dev/null

mysql_virtual_mailbox_domains_cf=$(cat <<EOF
user = $DB_USER
password = $DB_PASS
hosts = 127.0.0.1
dbname = $DATABASE
query = SELECT 1 FROM virtual_domains WHERE name='%s'"
EOF
)
echo "$mysql_virtual_mailbox_domains_cf" | tee > /etc/postfix/mysql-virtual-mailbox-domains.cf
printf "${BGreen}---------------POSTFIX CONFIGURED---------------${Color_Off}\n"

#DOVECOT MAIN CONF
dovecot_conf=$(cat <<EOF
!include_try /usr/share/dovecot/protocols.d/*.protocol
listen = *, ::
dict {
}
!include conf.d/*.conf
!include_try local.conf
EOF
)
echo "$dovecot_conf" | sudo tee /etc/dovecot/dovecot.conf > /dev/null

dovecot_sql=$(cat <<EOF
driver = mysql
connect = "host=127.0.0.1 dbname=$DATABASE user=$DB_USER password=$DB_PASS"
default_pass_scheme = SHA512-CRYPT
password_query = SELECT Email as User, password FROM virtual_mailboxes WHERE Email='%u';
EOF
)
echo "$dovecot_sql" | sudo tee /etc/dovecot/dovecot-sql.conf.ext > /dev/null

# DOVECOT CONF.D CONFIG FILES
dovecot_10_auth=$(cat <<EOF
disable_plaintext_auth = yes
auth_mechanisms = plain login
!include auth-sql.conf.ext
EOF
)
echo "$dovecot_10_auth" | sudo tee /etc/dovecot/conf.d/10-auth.conf > /dev/null

dovecot_10_mail=$(cat <<EOF
mail_location = maildir:/home/vmail/%d/%n/Maildir
namespace inbox {
inbox = yes
}

mail_privileged_group = mail
protocol !indexer-worker {
}
mbox_write_locks = fcntl
EOF
)
echo "$dovecot_10_mail" | sudo tee /etc/dovecot/conf.d/10-mail.conf > /dev/null

dovecot_10_master=$(cat <<EOF
service imap-login {
  inet_listener imap {
    port = 143
  }
  inet_listener imaps {
  port = 993
  ssl = yes
  }
}
service pop3-login {
  inet_listener pop3 {
    port = 110
  }
  inet_listener pop3s {
  port = 995
  ssl = yes
  }
}
service lmtp {
 unix_listener /var/spool/postfix/private/dovecot-lmtp {
   mode = 0600
   user = postfix
   group = postfix
 }
}
service auth {
  unix_listener auth-userdb {
    mode = 0600
    user = vmail
  }
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }
  user = dovecot
}
service auth-worker {
  user = vmail
}
service dict {
  unix_listener dict {
  }
}
EOF
)
echo "$dovecot_10_master" | sudo tee /etc/dovecot/conf.d/10-master.conf > /dev/null

dovecot_10_ssl=$(cat <<EOF
ssl = yes
ssl_cert = </etc/dovecot/private/dovecot.pem
ssl_key = </etc/dovecot/private/dovecot.key
ssl_client_ca_dir = /etc/ssl/certs
ssl_dh = </usr/share/dovecot/dh.pem
ssl_cert = </etc/letsencrypt/live/mail.$DOMAIN/fullchain.pem 
ssl_key = </etc/letsencrypt/live/mail.$DOMAIN/privkey.pem
EOF
)
echo "$dovecot_10_ssl" | sudo tee /etc/dovecot/conf.d/10-ssl.conf > /dev/null

dovecot_20_imap=$(cat <<EOF
protocol imap {
}
EOF
)
echo "$dovecot_20_imap" | sudo tee /etc/dovecot/conf.d/20-imap.conf > /dev/null

dovecot_20_pop3=$(cat <<EOF
protocol pop3 {
}
EOF
)
echo "$dovecot_20_pop3" | sudo tee /etc/dovecot/conf.d/20-pop3.conf > /dev/null

dovecot_20_lmtp=$(cat <<EOF
protocol lmtp {
}
EOF
)
echo "$dovecot_20_lmtp" | sudo tee /etc/dovecot/conf.d/20-lmtp.conf > /dev/null

dovecot_auth_master=$(cat <<EOF
passdb {
  driver = passwd-file
  master = yes
  args = /etc/dovecot/master-users
  pass = yes
}
EOF
)
echo "$dovecot_auth_master" | sudo tee /etc/dovecot/conf.d/auth-master.conf.ext > /dev/null

dovecot_auth_master=$(cat <<EOF
passdb {
  driver = passwd-file
  master = yes
  args = /etc/dovecot/master-users
  pass = yes
}
EOF
)
echo "$dovecot_auth_master" | sudo tee /etc/dovecot/conf.d/auth-master.conf.ext > /dev/null

dovecot_auth_sql=$(cat <<EOF
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
  driver = static
  args = uid=vmail gid=vmail home=/home/vmail/%d/%n/Maildir
}
EOF
)
echo "$dovecot_auth_sql" | sudo tee /etc/dovecot/conf.d/auth-sql.conf.ext > /dev/null
printf "${BGreen}---------------DOVECOT CONFIGURED---------------${Color_Off}\n"

# CREATE AND CONFIGURE VIRTUAL MAILBOX FILES
echo 'user = '$DB_USER'' > /etc/postfix/virtual-mailbox-domains.conf
echo 'password = '$DB_PASS'' >> /etc/postfix/virtual-mailbox-domains.conf
echo 'hosts = 127.0.0.1' >> /etc/postfix/virtual-mailbox-domains.conf
echo 'dbname = '$DATABASE'' >> /etc/postfix/virtual-mailbox-domains.conf
echo "query = SELECT 1 FROM virtual_domains WHERE DomainName ='%s'" >> /etc/postfix/virtual-mailbox-domains.conf
echo 'user = '$DB_USER'' > /etc/postfix/virtual-mailbox-users.conf
echo 'password = '$DB_PASS'' >> /etc/postfix/virtual-mailbox-users.conf
echo 'hosts = 127.0.0.1' >> /etc/postfix/virtual-mailbox-users.conf
echo 'dbname = '$DATABASE'' >> /etc/postfix/virtual-mailbox-users.conf
echo "query = SELECT 1 FROM virtual_mailboxes WHERE Email='%s'" >> /etc/postfix/virtual-mailbox-users.conf
echo 'user = '$DB_USER'' > /etc/postfix/virtual-alias-maps.conf
echo 'password = '$DB_PASS'' >> /etc/postfix/virtual-alias-maps.conf
echo 'hosts = 127.0.0.1' >> /etc/postfix/virtual-alias-maps.conf
echo 'dbname = '$DATABASE'' >> /etc/postfix/virtual-alias-maps.conf
echo "query = SELECT Destination FROM virtual_aliases WHERE Source='%s'" >> /etc/postfix/virtual-alias-maps.conf

# CONFIGURE PERMISSIONS
chmod 640 /etc/postfix/virtual-mailbox-domains.conf
chmod 640 /etc/postfix/virtual-mailbox-users.conf
chmod 640 /etc/postfix/virtual-alias-maps.conf

### WHEN COMPLETE
printf "${BGreen} ---------------------------------------------- ${Color_Off}\n"
printf "${BGreen}|              SCRIPT COMPLETED                |${Color_Off}\n"
printf "${BGreen}|              SERVICES ENABLED                |${Color_Off}\n"
printf "${BGreen}|               RESTART MACHINE                |${Color_Off}\n"
printf "${BGreen} ---------------------------------------------- ${Color_Off}\n"
