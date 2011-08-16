ROOT="http://fungalgenomes.org/data/NT/"

#wget --base=http://fungalgenomes.org/data/NT/ --continue --force-directories --recursive --level=2 --convert-links --mirror --page-requisites --restrict-file-names=unix -A .bz2 -np --html-extension http://fungalgenomes.org/data/NT/index.html

cat index.html* | perl -ne 'my $r = '$ROOT'; if (/\<h1\>Index of (\S+)\<\/h1\>/) { $io = $1; }; if (/\<a href\=\"(\S+)\"\>/) { print $r, $io, $1, "\n"; }' | grep -E "bz2|gz|README" > index.lst
#wget -i index.lst
