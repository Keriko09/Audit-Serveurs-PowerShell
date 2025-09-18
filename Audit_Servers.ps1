<#
Ce projet était dans l'intention d'améliorer mes compétences en sécurité et powershell.
Le programe suivant va vérifier les serveurs à partir d'un fichier csv (entrer vos adresses ip), vérifier que le serveur est bien en ligne,
puis prendre l'utilisation du cpu,ram et disque dur puis les envoyés dans un fichier
Ensuite je créé mes règles par rapport à l'utilisation des ressources que j'ai mit dans un csv, 
donc par exemple si l'utilisation du cpu est plus grand que mes données dans mon csv il me génère un alerte.

#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8 #j'ai testé cette ligne pour avoir mes accent. 


# Charger le module ImportExcel
Install-Module -Name ImportExcel -Force -Scope CurrentUser 

# Début de la transcription
Start-Transcript -Path "I:\Session3\Script\tp2\Transcript.log" -Append 

# Vérification des fichiers de configuration
$serveursFile = "I:\Session3\Script\tp2\servers.csv" #Donc je récupère mes fichiers d'adresse de serveurs que je stocke dans ma variable
$parametresFile = "I:\Session3\Script\tp2\parametres.csv"#Ici je récupère mon cpu, mémoire et ram dans mon fichier
if (-not (Test-Path $serveursFile) -or -not (Test-Path $parametresFile)) { #J'ai créé une condition ici comme si il ne trouve pas le fichier avec les serveurs de créé un erreur et de la mettre dans mon fichier erreurs
    Write-Output "Erreur: Fichiers de configuration manquants !" | Out-File -Append I:\Session3\Script\tp2\ErreursAudit.log #J'ai utilisé le OUt-File -append pour ajouté une ligne et non écrire par dessus
    Stop-Transcript
    exit
}

# Chargement des serveurs - Donc ma variable serveurs est = au infos que j'ai stocké dans mon fichier csv
$serveurs = Import-Csv -Path $serveursFile | Select-Object -ExpandProperty servers

# Chargement des paramètres avec vérification des colonnes
$parametres = @{ } #je créé un hasmark pour stocké les donnée clé et valeur de mes propriété cpu,mémoire et disque
$csvData = Import-Csv -Path $parametresFile #j'ai créé une variable csvData qui va contenir les informations de mon csv

<#
Vérifier l’existence des deux fichiers de configuration. S’ils sont manquants, affichez un message d’erreur et arrêtez 
l’exécution. donc j'ai créé la condition qui dit que si les dans le tableau ma clé à la position 0 n'a rien ou que ma valeur n'a rien
on écrit un erreur dans mon fichier erreurs et on arrête le programme
#>
if (-not $csvData[0].PSObject.Properties.Name -contains 'Key' -or -not $csvData[0].PSObject.Properties.Name -contains 'Value') {
    Write-Output "Erreur: Colonnes Key et Value non trouvées dans parametres.csv" | Out-File -Append I:\Session3\Script\tp2\ErreursAudit.log
    Stop-Transcript
    exit
}
$csvData | ForEach-Object { $parametres[$_.Key] = [int]$_.Value } #ici on parcour les données de mon fichier csv et on les stock dans csv

# Stockage des résultats dans mon array
$resultats = @{ } 

foreach ($serveur in $serveurs) { #Je fais parcourir une variable dans chaque ligne de ma variable serveurs qui contient les adresses 
    Write-Output "Audit du serveur: $serveur"
    
    # Vérification de la connexion
    $online = Test-Connection -ComputerName $serveur -Count 2 -Quiet #test de connection simple j'ai donné un deux seconde de pause
    Write-Output "Test-Connection pour $serveur : $online"

    if (-not $online) { #
        $resultats[$serveur] = @{ Online = "No"; CPU = "N/A"; Memory = "N/A"; FreeDiskSpace = "N/A" }
        Write-Output "Échec de connexion pour $serveur - Enregistré comme Offline."| Out-File -Append I:\Session3\Script\tp2\ErreursAudit.log #si il n'Es pas en ligne je l'enregistre dans mon fichier
        continue
    }

    # Exécution des scripts et affichage des valeurs récupérées
    $cpu = & I:\Session3\Script\tp2\cpu.ps1 -serveur $serveur 
    $memoire = & I:\Session3\Script\tp2\memoire.ps1 -serveur $serveur
    $disque = & I:\Session3\Script\tp2\disque.ps1 -serveur $serveur

    Write-Output "Valeurs recuperees pour $serveur : CPU = $cpu%, Mémoire = $memoire%, Disque = $disque%"

    # Stockage des résultats - Automatiquement si il n'était pas offline il est online et j'ai créé ce hashtable que mon $resultat array
    $resultats[$serveur] = @{
        Online = "Yes"
        CPU = $cpu
        Memory = $memoire
        FreeDiskSpace = $disque
    }
}

# Exportation des résultats, j'ai trouvé le Get.Enumarator qui me permet de réupérer mes clées et mes valeurs dans hashtable
$resultats.GetEnumerator() | ForEach-Object {
    [PSCustomObject]@{
        Serveur = $_.Key
        Online = $_.Value.Online
        CPU = $_.Value.CPU
        Memory = $_.Value.Memory
        FreeDiskSpace = $_.Value.FreeDiskSpace
    }
} | Export-Csv -Path I:\Session3\Script\tp2\ResultatsAudit.csv -NoTypeInformation

# Résumé en console - Principalement por l'affichage des alertes, donc si le CPU différent et plus grand que le chiffre de mon fichier 
$totalServeurs = $resultats.Count
$serveursAlertes = $resultats.Values | Where-Object {
    ($_.CPU -ne "N/A" -and $_.CPU -gt $parametres["CPU"]) -or
    ($_.Memory -ne "N/A" -and $_.Memory -gt $parametres["Memory"]) -or
    ($_.FreeDiskSpace -ne "N/A" -and $_.FreeDiskSpace -lt $parametres["FreeDiskSpace"])
} | Measure-Object | Select-Object -ExpandProperty Count #c'Est ici que je compte les alertes - donc il vérifie avec le résultat.values si une donnée est plus haute il va généré un alerts 

#Résumé 
Write-Output "Resume :"
Write-Output " - Serveurs scannes : $totalServeurs"
Write-Output " - Serveurs en alerte : $serveursAlertes"
Write-Output " - Details :"

#L'affichage dans la condole 
$resultats.GetEnumerator() | ForEach-Object {
    Write-Output "$($_.Key) - Online: $($_.Value.Online), CPU: $($_.Value.CPU)%, Memory: $($_.Value.Memory)%, FreeDiskSpace: $($_.Value.FreeDiskSpace)%"
}

# Fin de la transcription
Stop-Transcript
