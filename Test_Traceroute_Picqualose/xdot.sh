#/bin/bash
cd ../Traceroute_Olivia/internet
echo "digraph route { " > internet.dot

for file in $(ls *.route)
#Définition de la première case de départ 
	do
 		echo -n "\"Nous [Départ]\" [shape=invhouse]" >> internet.dot
for (( lg=1; lg<$(cat $file |wc -l); lg++))
       	do
		echo -n "\"$(cat $file|head -n $lg|tail -n1|cut -d";" -f 1,2|tr ";" " ")\"" >> internet.dot
       done


#Pour toutes les adresses par lesquelles il passe
#Boucle qui passe en revue toutes les lignes : affiche IP et AS 
	echo -n "\"Nous [Départ]\" ->" >> internet.dot
	for (( lg=1; lg<$(cat $file |wc -l); lg++))
	do
	
	echo -n "\"$(cat $file|head -n $lg|tail -n1|cut -d";" -f 1,2|tr ";" " ")\" ->" >> internet.dot
	done
#Pour la dernière adresse : affiche IP + AS (sans retour à la ligne)
	echo -n "\"$(cat $file|head -n $lg|tail -n1|cut -d";" -f 1,2|tr ";" " ")\"" >> internet.dot
	done
			
echo "}" >> internet.dot
xdot internet.dot
