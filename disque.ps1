#Calculer le taux d’espace disque disponible d’un serveur 

param ($serveur) #Je passe en paramètre une variable serveur que je vais utiliser dans mon code principal

try {
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" -ComputerName $serveur #ici je viens chercher le % d'utilisation du disque que j'ai filter avec le c: seulement puis le nom de l'ordi va être les donnés que j'ai pris dans la variable serveur
    $freeDisk = ($disk.FreeSpace / $disk.Size) * 100 # j'ai trouvé cette formule pour calculé le nombre de donné restantes
    return [Math]::Round($freeDisk, 2) #je retourne l'espace libre et j'ai mis en décimal avec deux chiffre après la virgule
} catch {
    Write-Output "Erreur disque $serveur : $_" | Out-File -Append C:\AuditServeurs\ErreursAudit.log #Puisqu'il fallait faire un Log d'erreur j'ai ajouté cette clause, si il y a un erreur avec le disque et bien j'ai une trace 
    return $null #ici je retourne rien puisque de toute façon si il y a un erreur je vais l'envoyer vers mon fichier d'audit
}
