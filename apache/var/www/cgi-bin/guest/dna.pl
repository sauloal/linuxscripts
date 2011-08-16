#!/usr/bin/perl


###################################################################
###		DNA CYPHER					###
### by MeowChow (código) e Saulo Alves (front end)		###
### primeira versao do codigo: 2002				###
### primeira versao do front-end: 01/2003			###
### versão atual: 2.0 (2006-02-19@2355)				###
###								###
###################################################################

#print "Content-type: text/html\n\n";
my $method = "POST";
header(); # cabecalho HTML
getform(); # obtem os dados enviados pelo formulario
foot(); # coloca o rodape do HTML








###############################################################
################ DECODIFICA O TEXTO EM DNA ####################
###############################################################
sub dnadecoder{
	$_ = $_[0]; # pegue o texto a ser codificado
	if ($info{'Formato'} eq "Cadeia") {
		print "<p><textarea rows=\"8\" name=\"TranscritoCadeia\" cols=\"85\" tabindex=\"5\">";
		
		$_ =~ s/\r/\r\n/g; # substitua o retorno de carro (linux) por retorno de carro + enter (windows)
		$_ .= "\r\n "; # coloque um retorno de carro + enter no final do texto
		
		$contador = 0; # Zere o contador
		@_{A=> C=> G=> T=>}=0..3; # atribua o valor a cada uma das letras
		
		$_ =~ s/.*(\w).*(\w).*\n/$_{$contador++\/8%2?$2:$1}/gex;
			# vamos por partes:
			# pegue uma letra antecedida por caracteres e salve como $1,
			# pegue a proxima letra antecedida por caracteres+letra($1)+caracteres+enter
			# e seguida de caracteres e salve essa segunda letra como $2
			# substitua a sentenca toda (caracteres+letra[$1]+caracteres+letra[$2]+caracteres+enter
			# se o numero da linha for divizivel por 8 ($contador/8%2 => se na divisao nao houver resto)
			# significa que estamos no lado externo da fita (primeira volta) e usaremos o $2
			# .. se nao for divizivel (houver resto) significa que estamos no lado interno da fita...
			# entao usa-se o $1
			# uma vez decidido qual nucleotideo ler, substitua ele pelo seu respectivo numero $_[n]
	};


#	if ($info{'Formato'} eq "Fasta") {
		print "<p><textarea rows=\"8\" name=\"TranscritoFasta\" cols=\"85\" tabindex=\"5\">";
		$_ =~ s/\r//g; # substitua o retorno de carro (linux) por nada
		$_ =~ s/\n//g; # substitua o enter por nada
		$_ =~ tr/ACGT/0123/;
#	};

	$_ =~ s/(.)(.)(.)(.)/chr(64*$1+16*$2+4*$3+$4)/gex;
		# sigamos os conselhos do sábio jack.. vamos por partes aqui tb
		# como cada letra eh substituida por 4 nucleotideos, pege de 4 em 4 numeros
		# e multiplique o primeiro por 64, o segundo por 16, o terceiro por 4 e o ultimo
		# por 1.. teremos assim a reversao da emcriptacao do codigo ascii em base 4

	print $_;
	print "</textarea></p>\n";
}





###############################################################
################# CODIFICA O TEXTO EM DNA #####################
###############################################################
sub dnaencoder{
	my $str = $_[0];
	my $BASE = 4;
	my %NUC_PAIRS = (
	  A => T =>
	  C => G =>
	  G => C =>
	  T => A =>
	);
	my @DIGIT_TO_NUC = qw( A C G T );
	print "<p><textarea rows=\"8\" name=\"TranscritoCadeia\" cols=\"10\" tabindex=\"5\">";
my $FMT_DNA = <<END;
 01
0--1
0---1
0----1
 0----1
  0---1
   0--1
    01
    10
   1--0
  1---0
 1----0
1----0
1---0
1--0
 10
END
	my @FMT_DNA = split "\n",$FMT_DNA; # separa a fita colocando cada linha em um array

	my @str_digits;
	for (split//, $str) { # separa a palavra a ser codificada letra por letra
		my $ord = ord($_); # obtem o codigo ascII da letra
		my @digits = (0) x 4; # cria o array @digits composto de 4 zeros
#		print "$ord:\t"; # imprime na tela o codigo ascII da letra
		my $i = 0; 
		while ($ord) { # loop para decompor o numero ascII em base 4
			       # por divisoes sucessivas ate se obter o resto 0
			$digits[4 - ++$i] = $ord % $BASE;
			$ord = int ($ord / $BASE);
		}
#		print "@digits\n"; @ imprime o codigo ascII transformado em base 4
		push @str_digits, [@digits];	# salva todos os codigos ascII em base
						# 4 gerados no array. cada elemento deste
						# array será um outro array de 4 elementos..
	}

	my $i = 0;
	my $adn;
	for (@str_digits) {	# para cada codigo ascII em base 4 gerado
				# (4 digitos para cada letra do texto original)
		for (@$_) {	# obtenha os 4 digitos q compoe o codigo relativo a 1 letra
			my $fmt = $FMT_DNA[$i++ % @FMT_DNA];	# decide qual linha da dupla helice
								# deve-se ler vendo qual o resto para o
								# multiplo do total de linhas da helice 
			my $nuc0 = $DIGIT_TO_NUC[$_]; # retorna o nucleotideo relativo ao numero
			$adn .= $nuc0; # salva sequencialmente os nucleotideos
			my $nuc1 = $NUC_PAIRS{$nuc0}; # verifica o nucleotideo que pareia
			$fmt =~ s/0/$nuc0/; # substitui o 0 pelo nucleotideo de valor
			$fmt =~ s/1/$nuc1/; # substitui o 1 pelo nucleotideo emparelhante
			print "$fmt\n"; #imprime a linha atual da cadeia
		}
	}
        print "</textarea></p>\n";
	print "<p><textarea rows=\"8\" name=\"TranscritoFasta\" cols=\"85\" tabindex=\"6\">";

	while ($I <= (int(length($adn) / 80))){ # imprima no formato FASTA
		print substr($adn,($I++*80),80) . "\n";
	};
	print "</textarea></p>\n";

}




###############################################################
################# IMPRIME O CABECALHO HTML ####################
###############################################################
sub header {
print "Content-type: text/html\n\n";
print <<HTML
	<html>
	<head>
		<meta http-equiv="Content-Language" content="pt-br">
		<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
		<title>DNA Cypher</title>
	</head>
	<body bgcolor="EEEEEE" text="black" link="#FFFFFF" vlink="#FF0000" alink="#FFFF00">
		<center>
		<table border="1" bordercolor="black" cellpadding="0" cellspacing="0">

			<tr bgcolor="black">
				<td align="centeR"><font size="5" face="verdana" color="white"><B>DNA Cypher</B></font></td>
			</tr>
HTML
;
}


###############################################################
################### IMPRIME O RODAPE HTML #####################
###############################################################
sub foot {
print <<HTML
	<br>
	<tr bgcolor="black">
		<td align="right">
		<small>
			<font size="2" face="verdana" color="white">
				DNA Cypher by <a target="_blank" href="http://www.perlmonks.org/?node_id=17251">MeowChow</a>,
				& Saulo Alves
			</font>
			</small>
		</td>
        </tr>
	</table>
	</body></html>
HTML
;
}


###############################################################
######### OBTEM OS DADOS ENVIADOS PELO FORMULARIO #############
###############################################################
sub getform{
	if ($ENV{"REQUEST_METHOD"} eq 'GET') { $buffer = $ENV{'QUERY_STRING'} }
	else { read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'}) };

	#if ($ENV{"REQUEST_METHOD"} eq 'GET') { print "get funcionou" } else { print "post" };

	@values = split /&/, $buffer;
	#print "@values";
	foreach $pair (@values)
	{
	         my ($command, $value) = split /=/, $pair;
	         $value =~ tr/+/ /;
	         $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	         chomp ($value);
	         $info{$command}=$value;
	};

    if ($info{'Texto'} eq "") # se nao houve texto inserido
    {
        emptyquery(); # coloque um formulario vazio
    }
    else
    {
        answerquery() # se houve texto submetido... coloque um formulario preenchido
    };

#foreach $var (sort(keys(%ENV))) {
#    $val = $ENV{$var};
#    $val =~ s|\n|\\n|g;
#    $val =~ s|"|\\"|g;
#    print "${var}=\"${val}\"\n";
#};
} # end of getting commands from URL



###############################################################
############# IMPRIME O FORMULARIO HTML VAZIO #################
###############################################################
sub emptyquery {
print <<EMPTY
	<tr>
		<td>
		<center>
			<b>INSERT YOUR SEQUENCE</b>
			<form method=GET action=dna.pl>
		</center>
		</td>
	</tr>
	<tr>
		<td>
		<textarea rows="8" name="Texto" cols="85" tabindex="1"></textarea>
		</td>
	<tr>
		<td>
		<center>
			<b><input type="submit" value="Submit Original" name="Original" tabindex="2"></b>
			<b><input type="submit" value="Submit Reverse"  name="Reverso"  tabindex="3"></b>
			<b><input type="reset"  value="Clear"           name="Limpar"   tabindex="4"></b>
		</center>
		</form>
		</td>
	</tr>
EMPTY
;

#		<center>
#			<b><input type="radio" value="Cadeia" checked name="Formato">Double Helix Format<\b>
#			<b><input type="radio" name="Formato" value="Fasta">FASTA Format</b>
#		</center>

#	print "<tr>\n<td><center><b>INSIRA SUA SEQUÊNCIA</b></td></tr>\n";
#	print "<tr><td>\n";
#	print "<form method=GET action=dna.pl>\n";
#	print "<p><textarea rows=\"8\" name=\"Texto\" cols=\"85\" tabindex=\"1\"></textarea></p>\n";
#	print "<p><center><b><input type=\"radio\" value=\"Cadeia\" checked name=\"Formato\">Formato de Cadeia Dupla<input type=\"radio\" name=\"Formato\" value=\"Fasta\">Formato FASTA</b></center>";
#	print "</center></td><tr>\n<td><center>";
#	print "<p><input type=\"submit\" value=\"Submeter Orignal\" name=\"Original\" tabindex=\"2\">\n";
#	print "<input type=\"submit\" value=\"Submeter Reverso\" name=\"Reverso\" tabindex=\"3\">\n";
#	print "<input type=\"reset\" value=\"Limpar\" name=\"Limpar\" tabindex=\"4\">\n";
#	print "</form></center></td></tr>";
}


###############################################################
########### IMPRIME O FORMULARIO HTML PREENCHIDO ##############
###############################################################
sub answerquery {
	print "<tr>\n<td><center><b>INSERT YOUR SEQUENCE</b></td></tr>\n";
	print "<tr><td>\n";
	print "<form method=$method action=dna.pl>\n";

	print "<p><textarea rows=\"8\" name=\"Texto\" cols=\"85\" tabindex=\"1\">";
       $info{'Texto'} =~ s/\r//g;
       print $info{'Texto'}; 
       print "</textarea></p>\n";
        
	#if ($info{'Formato'} eq "Cadeia") { print "<p><center><b><input type=\"radio\" value=\"Cadeia\" checked name=\"Formato\">Formato de Cadeia Dupla<input type=\"radio\" value=\"Fasta\"         name=\"Formato\">Formato FASTA</b></center>"; };
	#if ($info{'Formato'} eq "Fasta")  { print "<p><center><b><input type=\"radio\" value=\"Cadeia\"         name=\"Formato\">Formato de Cadeia Dupla<input type=\"radio\" value=\"Fasta\" checked name=\"Formato\">Formato FASTA</b></center>"; };
	
	print "</center></td><tr>\n<td><center>";
	print "<p><input type=\"submit\" value=\"Submit Original\" name=\"Original\" tabindex=\"2\">\n";
	print "<input type=\"submit\" value=\"Submit Reverse\" name=\"Reverso\" tabindex=\"3\">\n";
	print "<input type=\"reset\" value=\"Clear\" name=\"Limpar\" tabindex=\"4\">\n";
	print "</form></center></td></tr>";
	
	print "<tr>\n<td><center><b>TRANSCRIBED SEQUENCE</b></td></tr>\n";
	print "<tr><td>\n";
	       if ($info{'Original'}) { dnaencoder($info{'Texto'}) };
       	if ($info{'Reverso'})  { dnadecoder($info{'Texto'}) };
       print "</textarea></p></tr>\n";

#    if ($info{'Original'}) { print "O Botao Pressionado Foi o ORIGINAL\n" };
#    if ($info{'Reverso'}) { print "O Botao Pressionado Foi o REVERSO\n" };
#    print "Texto Digitado: " . $info{'Texto'} . "\n";
}

