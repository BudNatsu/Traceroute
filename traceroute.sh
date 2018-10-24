
#!/bin/bash

		######Vérification qu'une adresse soit entrée######

if [ -z $@ ]
        then
                echo "Veuillez entrer une adresse IP ou le nom d'un site"
                exit -1
        else
                echo "Début du test pour $@"
fi

		######Déclaration des variables######

	######Création d'un dossier où stocker les information######

#On transforme le nom du site ou de l'adresse IP en remplaçant les "." par des "-" pour une meilleure lisibilité des fichiers

ipformate="$(echo $1 |sed 's/\./\-/g')"
echo "Création du répertoire  $ipformate"
rm -r -f $ipformate
mkdir $ipformate
sudo chmod 774 $ipformate
cd $ipformate


#Création de la variable "id" pour reconnaître le numéro du routeur
id=0

#Création de la variable TTL_max qui définira quel est le nombre de saut maximum par rapport à l'adresse


for adress in "$@"
do
#On récupère le nombre de sauts maximum en effectuant un premier Traceroute
TTL_max=$(sudo traceroute -n -I $adress|tail -n 1|cut -c1-2)

echo "Le TTL est de $TTL_max"

#Liste des options pour les tests Traceroutes
declare -a option=("-T -p 53" "-T -p 22" "-T -p 443" "-U -p 13" "-U -p 57" "-U -p 7" "-I")


for ttl in `seq 1 $TTL_max`
do

	#Pour chaque options
	for Noption in "${!option[@]}"
	do
	echo "-A -f $ttl -m $ttl ${option[Noption]} $@"
	rt=$(sudo traceroute -A -f $ttl -m $ttl ${option[Noption]} $@ |tail -n 1|awk '{print $2" "$3" "$4}')
	echo "$rt"
	echo "$ttl/$TTL_max"
#Vérification des résultats

	if echo "$rt" |awk '{print $1}' |grep "*"
	then
		echo "option utilisée : ${option[Noption]} TTL : $ttl"
# Si on arrive à la 7ème option et qu'on a toujours rien, on dit qu'il y a un routeur mais qu'on ne le connaît pas
	if [ $Noption -eq 6 ]
		then
			echo $Noption
			echo "NoID"$id" ""[ASINCONNU""$id""]" >> $ipformate.txt
			id=$((id+1))
			break
		fi
	else
		#Si on trouve un chemin valide on le met dans le fichier suivant
		echo "$rt" >> "$ipformate.route"
		echo "$rt" >> "$ipformate.txt"
		break
	fi


	chmod 764 $ipformate.txt
	chmod 774 $ipformate.route
done
done
done
cp ../$ipformate/$ipformate.route ../internet
cd ../internet

##################Utilisation de xDot###################


echo "digraph route { " > internet.dot

for file in $(ls *.route)
#Définition de la première case de départ
	do
 		echo -n "\"Nous [Départ]\" [shape=invhouse]" >> internet.dot
for (( lg=1; lg<$(cat $file |wc -l); lg++))
       	do
		echo -n "\"$(cat $file|head -n $lg|tail -n1|cut -d";" -f 1,2|tr ";" " ")\"" >> $ipformate.dot
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
