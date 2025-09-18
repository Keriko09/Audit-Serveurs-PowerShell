#Calculer le taux d’utilisation de la mémoire d’un serveur 

param ($serveur)#Copié collé sur les autre fonctions 

try {
    $mem = Get-WmiObject Win32_OperatingSystem -ComputerName $serveur
    $memUsage = (($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100 #j'ai trouvé une formule de calcul qui est pratiquement la même que pour celle du disque dure exempté que j'utilise les paramètres des objests.
    return [Math]::Round($memUsage, 2) # j'ai utilisé la même formule que pour le disque dur
} catch {
    Write-Output "Erreur mémoire $serveur : $_" | Out-File -Append C:\AuditServeurs\ErreursAudit.log #Même principe si il ne trouve pas la mémoire j'ai un entré dans mon log
    return $null
}
