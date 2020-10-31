#!/usr/bin/env python
# coding: utf-8
from bs4 import BeautifulSoup
import requests
import sys

#passer le lien de la page de partage FreeBoxOS en argument du script (conserver le "/" final dans le lien):
pageFree = requests.get(sys.argv[1])

soup = BeautifulSoup(pageFree.text)

#création d'un fichier texte avec l'ensemble des liens de téléchargement contenus sur la page
#(passer ce fichier comme argument de la commande wget avec l'option -i déclenchera les téléchargements)
dlList = open(r"dlList.txt","a")

#variable de comparaison pour éviter d'inclure deux fois le même lien
#(le modèle des pages Free inclut le lien texte et une icône poitant vers le même fichier)
linkcompare = ""
for link in soup.find_all('a'):
    if linkcompare != link.get('href'):
#permet d'ignorer le lien "Partagé sur ma Freebox": 
       if link.get('href') != "http://www.free.fr/adsl/":
            dlList.write(sys.argv[1] + link.get('href')[2:] + '\n')
    linkcompare=link.get('href')
dlList.close()
