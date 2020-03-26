#!/bin/bash
#DNS dynamique avec Gandi.net, valide au 23/03/2020 (vive le confinement)
#Utilise jq (https://stedolan.github.io/jq/) pour manipuler les JSON et le site ifconfig.me pour récupérer l'adresse publique de la box Internet.
#
#Docs de l'API LiveDNS:
#	https://doc.livedns.gandi.net
#	https://api.gandi.net/docs/livedns/

#clé API, à générer dans le tableau de bord (https://admin.gandi.net/?locale=fr):
apikey=XXX

#nom du domaine enregistré (alias rrset_name)
domaine="domaine.com"

#nom du sous-domaine (aka fqdn)
sousdomaine="sous-domaine"

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
