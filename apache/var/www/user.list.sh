USERS=(  user1 user2 user3 )
PASSS=(  pass2 pass2 pass3 )
REALM=proxy
FILE=user.list

rm ${FILE} 2>/dev/null 1>/dev/null
touch ${FILE}

for (( i = 0 ; i < ${#USERS[@]} ; i++ ))
do
        USER=${USERS[$i]}
        PASS=${PASSS[$i]}
        echo ${USER}:$REALM:${PASS}
        (echo -n "${USER}:${REALM}:" && echo -n "${USER}:${REALM}:${PASS}" | md5sum) | gawk '{print $1}' >> ${FILE}
done