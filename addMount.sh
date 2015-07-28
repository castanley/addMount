#!/bin/bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Script Name:	createMount.sh
# Script Desc:	add NFS mount point to TSM servers
# Script Date:	7-28-15
# Created By:	Christopher Stanley
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
startTime=$(date +%s)
date=$(date +"%m-%d-%Y")
timeNow=$(date +"%T")

user="cstanley@"
mountPoint="IP:/PATH /LOCALMOUNT              nfs     rw,bg,soft,intr,vers=3,proto=tcp,rsize=262144,wsize=262144   0 0"
hosts=`cat server.list`
directory="/LOCALMOUNT"

for i in $hosts
do
        echo "---------- Connecting to $i ----------" | tee -a addMount.log
        tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" "uname")

        if [[ $tmp == *"Linux"* || $tmp == *"AIX"* ]]; then
                echo "[$(date +%D_%T)] Creating mount directory $directory" | tee -a addMount.log
                tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" "sudo mkdir -p \"$directory\" >/dev/null; echo $?")
                echo "[$(date +%D_%T)] Mounting rc = $tmp" | tee -a addMount.log

                echo "[$(date +%D_%T)] Adding $directory to /etc/fstab" | tee -a addMount.log
                tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" "echo \"$mountPoint\" | sudo tee -a /etc/fstab; echo $?")
                echo "[$(date +%D_%T)] Echo rc = $tmp" | tee -a addMount.log

                echo "[$(date +%D_%T)] Mounting /etc/fstab" | tee -a addMount.log
                tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" "sudo mount -a >/dev/null; echo $?")
                echo "[$(date +%D_%T)] Mount -a rc = $tmp" | tee -a addMount.log

                echo "[$(date +%D_%T)] Checking to see if $directory is mounted" | tee -a addMount.log
                tmp=$(ssh -tt -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$user""$i" "mount | grep \"$directory\"")
                echo "[$(date +%D_%T)] Output of mount grep: $tmp"
        else
                echo "[$(date +%D_%T)] Could not connect to $i - Connection failed" | tee -a addMount.log
        fi
done

endTime=$(date +%s)
seconds=$(echo "$endTime - $startTime" | bc)
minutes=$(echo "($endTime - $startTime) / 60" | bc)

if [ "$minutes" -le "0" ]; then
echo "Time Taken: $seconds seconds"
else
echo "Time Taken: $minutes minute(s)"
fi

echo "[$(date +%D_%T)] Job Finished." | tee -a addMount.log
