#!/usr/bin/env python
# coding: utf-8

#usage :
# $ python aspiro+DL.py https://adresse.page/FreeBoxOS/ /chemin/de/fichier/local/optionnel/
# si aucun dossier local n'est indiqué (second argument), les fichiers se téléchargent dans
# le dossier courant.

from bs4 import BeautifulSoup
import requests
import sys
import subprocess


def recupLiens():
#passer le lien de la page de partage FreeBoxOS en argument du script (conserver le "/" final dans le lien):
    pageFree = requests.get(sys.argv[1])

    soup = BeautifulSoup(pageFree.text, features="lxml")

#création d'un fichier texte avec l'ensemble des liens de téléchargement contenus sur la page
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


#téléchargement des fichiers:
def download():
    try:
        destination = sys.argv[2]
    except IndexError:
        destination = None
    if destination == None:
        subprocess.call(["wget", "-c", "-i", "dlList.txt"])
#rajoute l'option "-P" pour indiquer un chemin de dossier personnalisé pour les téléchargement:
    else:
        subprocess.call(["wget", "-c", "-i", "dlList.txt", "-P", destination])
    subprocess.call(["rm", "dlList.txt"])



#pour s'assurer que le fichier temporaire avec les liens est effacé:
if __name__ == '__main__':    # Program entrance
    print ("C'est parti ..." + "\n")
    recupLiens()
    try:
        download()
    except KeyboardInterrupt:   # Press ctrl-c to end the program.
        subprocess.call(["rm", "dlList.txt"])
