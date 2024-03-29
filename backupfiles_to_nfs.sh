#!/bin/bash
#
# BackupNFS Tool 0.2
#
# Programm von Netstack GmbH written by Andreas Pfeiffer
#
# Dieses Programm führt Datei Backups zu einem NFS Share durch
#
################# CONFIG #####################

backupdir="$nfsmountdir/$hostname"		 		# Verzeichniss wo die Backups abgelegt werden, es werden automatisch unterordner "mysql" und "files" erstellt.
datadir=(/path/to/files /path/to/files/2 )		# Welche Ordner sollen gesichert werden
datenbank=(dbname dbnam2)						# Datenbanken welche gesichert werden sollen
date1=$(date +%a)								# Datumsformat welches an die Dateien angehangen wird
hostname=$(hostname -f)							# Hostname
dbuser=DBUSER									# Datenbank User
dbpass=DBPASS									# Datenbank Passwort
mailsubject="Backup - $hostname"				# Mail Betreff
mailtext=/tmp/mailtext.txt 						# Mailtext zum Versand
email=monitor@example.com 						# Empfaenger der Status Mails
date2=$(date +%A" "%d.%m.%Y)					# Datum für E-Mail
nfsmount="192.168.0.1:/backupshare"				# NFS server + mount mount
nfsmountdir=/path/to/backup/					# Ordner fuer NFS-Share

################# CONFIG END #################

#reset Error Variable
error="0";

#Clear mailtext

echo " " > $mailtext;

#Aktuelles Datum
echo "#############################################################" >> $mailtext
echo "Backup Script from $hostname - "$date2 >> $mailtext
echo "#############################################################" >> $mailtext
echo "" >> $mailtext

# Check Backupdir
if test -d $nfsmountdir
then
        echo "";
else
        echo -n "Create Backupdirectory ... " >> $mailtext
        mkdir -p $nfsmountdir
        if test -d $nfsmountdir
        then
                echo -n "done" >> $mailtext
                echo "\n" >> $mailtext
        else
                echo -n "Error - Cant create nfs directory" >> $mailtext
				# send mail on Error 
				cat $mailtext | mail -s "$mailsubject" $email
                exit 1;
        fi

fi

#mount NFS to backupdir
echo -n "mount nfs share $nfsmount ... " >> $mailtext;
mount $nfsmount $nfsmountdir
if [ $? == "0" ]
then
	echo -n " done" >> $mailtext
	echo "\n" >> $mailtext
else
	echo -n " error" >> $mailtext
	echo "\n" >> $mailtext
	# send mail on Error 
	cat $mailtext | mail -s "$mailsubject" $email
	exit 1;
fi

# Check Backupdir
if test -d $backupdir
then
        echo "";
else
        echo -n "Create Backupdirectory ... " >> $mailtext
        mkdir -p $backupdir
	if test -d $backupdir
	then
        	echo -n "done" >> $mailtext
		echo "\n" >> $mailtext
	else
		echo -n "Error - Cant create backupdirectory" >> $mailtext
		# send mail on Error 
		cat $mailtext | mail -s "$mailsubject" $email
		exit 1;
	fi

fi

# Check Backupdir for mysql
if test -d $backupdir/mysql
then
        echo "";
else
        echo -n "Create Backupdirectory for mysql ... " >> $mailtext
        mkdir $backupdir/mysql
	if test -d $backupdir/mysql
	then
        	echo -n "done" >> $mailtext
		echo "\n" >> $mailtext
	else
		echo -n "Error - Cant create backupdirectory for mysql" >> $mailtext
		# send mail on Error 
		cat $mailtext | mail -s "$mailsubject" $email
		exit 1;
	fi

fi

# Check Backupdir for files
if test -d $backupdir/files
then
        echo "";
else
        echo -n "Create Backupdirectory for files ... " >> $mailtext
        mkdir -p $backupdir/files
	if test -d $backupdir/files
	then
		echo -n "done" >> $mailtext
		echo "\n" >> $mailtext
	else
		echo -n "Error - Cant create backupdirectory for files" >> $mailtext
		# send mail on Error 
		cat $mailtext | mail -s "$mailsubject" $email
		exit 1;
	fi

fi

######################
# Start Files backup #
######################

#count datadir's from config
countdir=${#datadir[*]};

for (( j=0; j<$countdir; j++ ))
do
	filesdir=${datadir[$j]}
	#echo "";
	#make backup from files dir
	name=$(basename $filesdir)
	echo -n "make backup from $filesdir ..." >> $mailtext
	tar -Pczf  $backupdir/files/$name'_'$date1.tar.gz $filesdir
	if [ $? == "0" ]
	then
		echo -n " done" >> $mailtext
		echo "\n" >> $mailtext
	else
		echo -n " error" >> $mailtext
		echo "\n" >> $mailtext
		# send mail on Error 
		cat $mailtext | mail -s "$mailsubject" $email
		exit 1;
	fi
done

#umount NFS share
umount $nfsmountdir

# Mailversand

# cat $mailtext | mail -s "$mailsubject" $email

exit 0;
