# Audit Serveurs en PowerShell

## Description
Ce projet PowerShell automatise l’audit de serveurs à partir d’une liste dans un fichier CSV.  
Il vérifie :
- la connectivité,
- l'utilisation du cpu,
- l’utilisation de la ram,
- et l’espace disque libre.  

Le script génère ensuite un rapport CSV et un log de l’exécution.

---

## Installation / Prérequis
- PowerShell 5+  
- Module [ImportExcel](https://www.powershellgallery.com/packages/ImportExcel)  

```powershell
Install-Module -Name ImportExcel -Scope CurrentUser -Force

## Structure du projet

 AuditServeurs.ps1 → script principal

cpu.ps1, memoire.ps1, disque.ps1 → scripts secondaires

servers.csv → liste des serveurs à auditer

parametres.csv → seuils pour CPU, mémoire et disque

Transcript.log → log d’exécution généré

ErreursAudit.log → erreurs rencontrées

ResultatsAudit.csv → résultats générés

Les chemins sont actuellement absolus (I:\Session3\Script\tp2\).
Pour exécuter le projet sur une autre machine, il faut adapter les chemins dans le script et placer les fichiers CSV et
mettre les  scripts secondaires au bon endroit.



## Utilisation

1. Ouvrir PowerShell dans le dossier du projet.

2. Lancer le script principal :

.\AuditServeurs.ps1

3. Consulter les fichiers générés :

    . Transcript.log → log complet

    . ErreursAudit.log → erreurs rencontrées

    . ResultatsAudit.csv → résumé par serveur


## Exemple de sortie console

Audit du serveur: SRV1
Valeurs récupérées : CPU=45%, Mémoire=60%, Disque=80%

Résumé :
 - Serveurs scannés : 3
 - Serveurs en alerte : 1

## Compétence démontrées 


PowerShell scripting avancé

Gestion CSV et logs

"Automatisation d'audit de serveurs"

"Vérification et gestion d’erreurs"
