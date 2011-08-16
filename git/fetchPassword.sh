FOLDER=$1
PASSFILE=$2

if [[ ! -d "$FOLDER" ]]; then
	echo "NO FOLDER"
	exit 1
fi

if [[ ! -f "$PASSFILE" ]]; then
        echo "NO PASSWORD FILE"
        exit 1
fi

PASS=`cat $PASSFILE`

if [[ -z "$PASS" ]]; then
	echo NO PASS
	exit 1
fi

echo SEARCHING FOR \"$PASS\" ON \"$FOLDER\"
CMD="find $FOLDER -xtype f \
	-exec bash -c 'GR=\`grep -i -P \"$PASS\" {}\`;\
	if [[ ! -z \"\$GR\" ]]; \
	then \
		echo \"  FOUND FORBIDDEN WORD IN {}\"; \
		echo \"\$GR\";\
		echo -e \"\n\"{} >> $FOLDER/.gitignorenew; \
	else \
		echo -n \"\"; \
	fi;' \
	\;"
echo "$CMD"
eval $CMD

#		echo \"  DID NOT FIND FORBIDDEN WORD IN {}\"; \


if [[ -f "$FOLDER/.gitignorenew" ]]; then
  cd $FOLDER
    cat .gitignorenew | perl -ne 'chomp; $seen{$_}++; END {foreach my $k (sort keys %seen) { print $k, "\n" if $k; };}' > .gitignoreuniq

    FIL=`cat .gitignoreuniq | perl -ne 'print "\t$_"'`
    echo -e "ADDING TO THE IGNORE LIST:\n$FIL"

    cat .gitignoreuniq >> .gitignore
    rm .gitignoreuniq

    cat .gitignore | perl -ne 'chomp; $seen{$_}++; END {foreach my $k (sort keys %seen) { print $k, "\n" if $k; };}' > .gitignoreuniq
    mv .gitignoreuniq .gitignore
    git add .gitignore
    rm .gitignorenew 
  cd ..
else
  echo "NO VIOLATIONS"
fi

