#chmod 640 .createUser.sh
#/var/www/.createUser.sh

#chmod 640 .passwd
#chown root:apache .passwd

USERS=(  name1 name1 )
PASSS=(  pass1 pass2 )
REALM=Root
FILE=.passwd

rm ${FILE} 2>/dev/null 1>/dev/null
touch ${FILE}

for (( i = 0 ; i < ${#USERS[@]} ; i++ ))
do
        USER=${USERS[$i]}
        PASS=${PASSS[$i]}
        echo ${USER}:$REALM:${PASS}
        (echo -n "${USER}:${REALM}:" && echo -n "${USER}:${REALM}:${PASS}" | md5sum) | gawk '{print $1}' >> ${FILE}
done

chown root:apache $FILE
chmod 640 $FILE