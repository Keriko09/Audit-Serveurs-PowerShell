#Calculer le taux d’utilisation CPU d’un serveur 

param ($serveur) #Même principe je vais utilisé la variable serveur dans mon code principal pour faire appel à ma fonction

try {
    # Utilisation de Get-WmiObject pour récupérer l'utilisation du processeur
    $cpuUsage = Get-WmiObject -Class Win32_Processor -ComputerName $serveur | Select-Object -ExpandProperty LoadPercentage
    return $cpuUsage
} catch {
    Write-Output "Erreur CPU $serveur : $_" | Out-File -Append "C:\AuditServeurs\ErreursAudit.log"#Création du log d'erreur, donc si il ne réussi pas à récuprer les données je vais avoir un entré dans mon log
    return $null
}
