##NOT-FINISHED
IFS=""
echo "user = $DB_USER
password = $DB_USER_PASS
hosts = 127.0.0.1
dbname = $DATABASE
query = SELECT 1 FROM virtual_domains WHERE name='%s'" > /etc/postfix/mysql-virtual-mailbox-domains.cf
service postfix restart
status=`postmap -q $DOMAIN mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf`
if [ "$status" -ne 1 ]; then
        echo "Virtual Domains config failed."
fi
echo "user = $DB_USER
password = $DB_USER_PASS
hosts = 127.0.0.1
dbname = $DATABASE
query = SELECT 1 FROM virtual_users WHERE email='%s'" > /etc/postfix/mysql-virtual-mailbox-maps.cf
service postfix restart
status=`postmap -q $EMAIL mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf`
status=`postmap -q mail.$DOMAIN mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf`
if [ "$status" -ne 1 ]; then
        echo "Virtual users config failed."
fi
echo "user = $DB_USER
password = $DB_USER_PASS
hosts = 127.0.0.1
dbname = $DATABASE
query = SELECT destination FROM virtual_aliases WHERE source='%s'" > /etc/postfix/mysql-virtual-alias-maps.cf
service postfix restart
#master.cf config
postconf -M submission/inet="submission       inet       n       -       -       -       -       smtpd"
postconf -P submission/inet/syslog_name=postfix/submission
postconf -P submission/inet/smtpd_tls_security_level=may
postconf -P submission/inet/smtpd_sasl_auth_enable=yes
postconf -P submission/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject
service postfix restart
##Dovecot
cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.orig
cp /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.orig
cp /etc/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf.orig
cp /etc/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext.orig
cp /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.orig
cp /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.orig
#uncomment !include conf.d/*.conf
sed -i '/\!include conf\.d\/\*\.conf/s/^#//' /etc/dovecot/dovecot.conf
status = `grep "protocols = imap lmtp" /etc/dovecot/dovecot.conf`
if [ -z "$status" ];then
        echo "protocols = imap lmtp pop3" >> /etc/dovecot/dovecot.conf
fi
sed -i '/^mail_location =.*/s/^/#/g' /etc/dovecot/conf.d/10-mail.conf #comment default mail_location
echo "mail_location = maildir:/var/mail/vhosts/%d/%n" >> /etc/dovecot/conf.d/10-mail.conf
sed -i '/^mail_privileged_group =.*/s/^/#/g' /etc/dovecot/conf.d/10-mail.conf
echo "mail_privileged_group = mail" >> /etc/dovecot/conf.d/10-mail.conf
mkdir -p /var/mail/vhosts/"$DOMAIN"
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/mail
chown -R vmail:vmail /var/mail
sed -i '/^auth_mechanisms =.*/s/^/#/g' /etc/dovecot/conf.d/10-auth.conf
echo "auth_mechanisms = plain login" >> /etc/dovecot/conf.d/10-auth.conf
sed -i '/\!include auth-system\.conf\.ext/s/^/#/g' /etc/dovecot/conf.d/10-auth.conf
sed -i '/\!include auth-sql\.conf\.ext/s/^#//g' /etc/dovecot/conf.d/10-auth.conf
if [[ ! -f /etc/dovecot/conf.d/auth-sql.conf.ext.orig ]]; then
        mv /etc/dovecot/conf.d/auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext.orig
fi
auth10="
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
  driver = static
  args = uid=vmail gid=vmail home=/var/mail/vhosts/%d/%n
}
"
echo $auth10 > /etc/dovecot/conf.d/auth-sql.conf.ext
sed -i '/^driver =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "driver = mysql" >> /etc/dovecot/dovecot-sql.conf.ext
sed -i '/^connect =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "connect = host=127.0.0.1 dbname=$DATABASE user=$DB_USER password=$DB_USER_PASS" >> /etc/dovecot/dovecot-sql.conf.ext
sed -i '/^default_pass_scheme =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "default_pass_scheme = SHA512-CRYPT" >> /etc/dovecot/dovecot-sql.conf.ext
sed -i '/^password_query =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "password_query = SELECT email as user, password FROM virtual_users WHERE email='%u';" >> /etc/dovecot/dovecot-sql.conf.ext
chown -R vmail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot
if [[ ! -f /etc/dovecot/conf.d/10-master.conf.orig ]]; then
        mv /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.orig
fi
dovecotmaster="service imap-login {
  inet_listener imap {
    port = 0
  }
  inet_listener imaps {
    #port = 993
    #ssl = yes
  }
}
service pop3-login {
  inet_listener pop3 {
    #port = 110
  }
  inet_listener pop3s {
    #port = 995
    #ssl = yes
  }
}
service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
   mode = 0600
   user = postfix
   group = postfix
  }
}
service imap {
}
service pop3 {
}
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }
  unix_listener auth-userdb {
   mode = 0600
   user = vmail
   #group =
  }
  # Auth process is run as this user.
  user = dovecot
}
service auth-worker {
  user = vmail
}
service dict {
  unix_listener dict {
  }
}"
echo $dovecotmaster > /etc/dovecot/conf.d/10-master.conf
service dovecot restart
service postfix restart
printf "\n\n${BGreen}Your mail server should accessible after reboot...${Color_Off}\n\n"
printf "${BWhite}\nBYE BYE (⌐■_■)\n\n"
unset $IFS