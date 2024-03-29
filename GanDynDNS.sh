#!/bin/bash
#DNS dynamique avec Gandi.net, valide au 23/03/2020 (vive le confinement).
#Mis à jour le 29/10/2020, pour prendre en compte des sous-domaines multiples, gérés sur le même serveur.
#Utilise jq (https://stedolan.github.io/jq/) pour manipuler les JSON et le site ifconfig.me pour récupérer l'adresse publique de la box Internet.
#
#Docs de l'API LiveDNS:
#	https://doc.livedns.gandi.net
#	https://api.gandi.net/docs/livedns/

#vérification d'une connexion VPN, abandon le cas échéant
if protonvpn s | grep "Status:       Connected"
then echo "VPN connecté, on zappe la mise à jour du lien DNS (pour éviter d'y associer l'adresse temporaire)"
else

	#clé API, à générer dans le tableau de bord (https://admin.gandi.net/?locale=fr):
	apikey=XXX

	#nom du domaine enregistré (alias rrset_name)
	domaine="domaine.com"

	#nom des sous-domaines (aka fqdn)
	sousdomaines="sousdomaine1 sousdomaine2 etc"
	#comme en Python, possibilité de faire une boucle for sur des éléments autre que des chiffres (ici des strings)! Exercice réussi. :)
	for sousdomaine in $sousdomaines
	do
	adresserecords=$(echo https://api.gandi.net/v5/livedns/domains/${domaine}/records/${sousdomaine})

	oldiparray=$(curl -s -H "Content-Type: application/json" -H "Authorization: Apikey ${apikey}" $adresserecords | jq '.[0].rrset_values')

	oldip=$(echo $oldiparray | jq .[0])
	echo "IP enregistrée chez Gandi pour ${sousdomaine}.${domaine} :"
	echo $oldip

	currentip=$(curl -s ifconfig.me)
	currentipquote=$(curl -s ifconfig.me/all.json | jq '.ip_addr')

	echo "IP publique de la box à la maison:"
	echo $currentipquote

	if [ $currentipquote != $oldip ]
	then
		echo "houlala les IPs sont différentes, il est temps de mettre à jour l'adresse chez Gandi"
		zzz='{"items":[{"rrset_type": "A","rrset_values": []}]}'
		www=$(echo $zzz | jq --arg changedip "$currentip" ' ."items"[0]."rrset_values"[0]  = $changedip ')
		echo $www
		curl -X PUT -H "Content-Type: application/json" -H "Authorization: Apikey ${apikey}" -d "$www" $adresserecords

	    echo "la nouvelle IP enregistrée chez Gandi est:"
		newiparray=$(curl -s -H "Content-Type: application/json" -H "Authorization: Apikey ${apikey}" $adresserecords | jq '.[0].rrset_values')
	    newip=$(echo $newiparray | jq .[0])
		echo $newip
	else
		echo "Je n'ai rien fait, les IP sont toujours les bonnes."
	fi
	done

fi
