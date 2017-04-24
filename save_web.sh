#!/bin/bash
## Variables
DATE=`date +%Y-%m-%d_%H-%M`;
TEMPBACKUPDIR=/tmp;
## CREEZ AVANT TOUTE CHOSE LES DOSSIERS CI-DESSOUS SUR LE SERVEUR DE SAUVEGARDE AVANT DE LANCER LE BACKUP
BACKUPDIRDB=/home/backup/db;
BACKUPDIRSITE=/home/backup/site;
BACKUPDIRSRVWEB=/home/backup/srv;
SRVBACKUP=**xxx_CHANGE-ME_xxx**;
NGINXCONFDIR=/etc/nginx;
#APACHECONFDIR=/etc/apache2;
WWWDIR=**xxx_CHANGE-ME_xxx**;
NBBACKUP=10;

MYSQLDATABASE=**xxx_CHANGE-ME_xxx**;
MYSQLUSER=**xxx_CHANGE-ME_xxx**;
MYSQLUSERPASS=**xxx_CHANGE-ME_xxx**;

FILEDB=db_BLOG-$DATE.sql.gz;
FILESITE=$DATE-BLOG.tar.gz;
FILESRVWWW=$DATE-SRVWEB.tar.gz;

# PREPARATION SAUVEGARDE
cd $TEMPBACKUPDIR

# SAUVEGARDE FICHIERS WEB
## Dump de la base de donnée
mysqldump -u $MYSQLUSER -p$MYSQLUSERPASS $MYSQLDATABASE --log-error=/var/log/mysql/dump-error.log | gzip -f9 > $FILEDB

## Copie du fichier backup base de données vers le serveur de sauvegarde
scp $FILEDB root@$SRVBACKUP:$BACKUPDIRDB

## Compression & Copie du fichier backup fileroot "site web" vers le serveur de sauvegarde
tar zcf $FILESITE $WWWDIR
scp $FILESITE root@$SRVBACKUP:$BACKUPDIRSITE

## Compression & Copie du fichier backup fileroot "serveur web" vers le serveur de sauvegarde
tar zcf $FILESRVWWW $NGINXCONFDIR
scp $FILESRVWWW root@$SRVBACKUP:$BACKUPDIRSRVWEB
#tar zcf $FILESRVWWW $APACHECONFDIR

## VIDANGE DES FICHIERS SUR LE SERVEUR PRINCIPAL
rm $TEMPBACKUPDIR/$FILEDB
rm $TEMPBACKUPDIR/$FILESITE
rm $TEMPBACKUPDIR/$FILESRVWWW

## VIDANGE DES FICHIERS SUR LE SERVEUR DE BACKUP
    ### NE FONCTIONNE PAS ENCORE ###
#ssh root@$SRVBACKUP | find $BACKUPDIRDB -name "$FILEDB" -mtime +$NBBACKUP -exec rm -vf {} \;
#ssh root@$SRVBACKUP | find $BACKUPDIRSITE -name "$FILESITE" -mtime +$NBBACKUP -exec rm -vf {} \;
#ssh root@$SRVBACKUP | find $BACKUPDIRSRVWEB -name "$FILESRVWWW" -mtime +$NBBACKUP -exec rm -vf {} \;