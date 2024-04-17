#menu_action_utilisateur.ps1

# En attendant le script final
$NomDistant = "wilder"
$IpDistante = "172.16.10.20"
$Credentials = Get-Credential -Credential $NomDistant
$PathInfoUser = "C:\Users\Administrator\Documents\Info_$UserInf_$(Get-Date -Format "yyyyMMdd").txt"

function InfoConnexion { 
    # Demande quel utilisateur?
    $userInf = Read-Host "Quel compte utilisateur souhaitez-vous vérifier?"
    
    # Vérification si l'utilisateur existe
    $userExists = ssh $NomDistant@$IpDistante "net user $userInf"
    if ($userExists) {
        # Si oui -> affichage date de dernière connexion
        Write-Host "Date de dernière connexion de l'utilisateur $userInf."
        $Call = Invoke-Command -ComputerName $IpDistante -ScriptBlock { Get-WinEvent -FilterHashtable @{
                LogName = 'Security'
                ID      = 4624
            } | Where-Object { $_.Properties[5].Value -eq $using:userInf } | Select-Object -ExpandProperty TimeCreated -First 1 
        } -Credential wilder
        $Call
        Start-Sleep -Seconds 2
        # Enregistrement des données
        Write-Host "Les données sont enregistrées dans le fichier" $PathInfoUser
        "Voici les droits sur le dossier spécifié : " | Out-File -Append -FilePath $PathInfoUser
        $Call | Out-File -Append -FilePath $PathInfoUser
    
        Read-Host "Appuyez sur Entrée pour continuer ..."

    }
    else {
        # Si non, sortie du script
        Write-Host "Le compte utilisateur n'existe pas." -ForegroundColor Red
    }
}

function InfoModificationMdp { 
    # Demande quel utilisateur?
    Write-Host "Date de dernière modification du mdp"
    $userInf = Read-Host "Tapez le nom d'utilisateur souhaité "

    # Vérification si l'utilisateur existe
    $userExists = ssh $NomDistant@$IpDistante "net user $userInf"
    if ($userExists) {
        # Si oui -> affichage date de dernière connexion
        $Call = Write-Host "Date de dernière modification du mot de passe l'utilisateur $userInf."
        Invoke-Command -ComputerName $IpDistante -ScriptBlock { (Get-LocalUser -Name $using:userInf).PasswordLastSet
        } -Credential wilder
        $Call
        Start-Sleep -Seconds 2
        # Enregistrement des données
        Write-Host "Les données sont enregistrées dans le fichier" $PathInfoUser
        "Voici les droits sur le dossier spécifié : " | Out-File -Append -FilePath $PathInfoUser
        $Call | Out-File -Append -FilePath $PathInfoUser
    
        Read-Host "Appuyez sur Entrée pour continuer ..."
    }
    else {
        # Si non, sortie du script
        Write-Host "Le compte utilisateur n'existe pas." -ForegroundColor Red
    }
}

function InfoLogSession { 
    Clear-Host
    $InfLog = Read-Host "Voulez-vous voir les sessions actives sur le poste distant? [O pour valider]"

   
    if ($Inflog -eq "O") {
        # Si oui -> affichage liste sessions ouvertes
        Write-Host "Session ouverte(s) sur le poste distant."
        Invoke-Command -ComputerName $IpDistante -ScriptBlock { (Get-WmiObject -class win32_ComputerSystem | select username).username } -Credential wilder
        Start-Sleep -Seconds 2
    }
    else {
        # Si non, sortie du script
        Write-Host "Mauvais choix - Retour au menu précédent" -ForegroundColor Red
    }
}

function droitsDossier {
    # Demande quel utilisateur
    Write-Host ""
    Write-Host "Visualisation des droits sur un dossier"
    Write-Host ""
    $UserInf = Read-Host "Tapez le nom d'utilisateur souhaité "

    # Vérifie si l'utilisateur existe sur le serveur distant
    $userExists = ssh $NomDistant@$IpDistante "net user $UserInf"
    if ($userExists) {
        # si oui -> demande quel dossier à vérifier
        $Dossier = Read-Host "Sur quel dossier souhaitez-vous vérifier les droits ? (spécifiez le chemin du dossier)"

        # Vérifie si le dossier existe sur le serveur distant
        if ($Dossier) {
            # affichage des droits
            $Call = Invoke-Command -ComputerName $IpDistante -Credential $NomDistant -ScriptBlock {
                param($FolderPath)
                Get-Acl -Path $FolderPath } -ArgumentList $Dossier
            $Call
            Start-Sleep -Seconds 2     
            # Enregistrement des données
            Write-Host "Les données sont enregistrées dans le fichier" $PathInfoUser
            "Voici les droits sur le dossier spécifié : " | Out-File -Append -FilePath $PathInfoUser
            $Call | Out-File -Append -FilePath $PathInfoUser
    
            Read-Host "Appuyez sur Entrée pour continuer ..."
        }
        else {
            # si non -> sortie du script
            Write-Host "Le dossier $Dossier n'existe pas"
            Start-Sleep -Seconds 2
        }
    }
    else {
        # si non -> sortie du script
        Write-Host "L'utilisateur $UserInf n'existe pas"
        Start-Sleep -Seconds 2
    }
}

function droitsFichier {
    # Demande quel utilisateur
    Write-Host ""
    Write-Host "Visualisation des droits sur un fichier"
    Write-Host ""
    $UserInf_ = Read-Host "Tapez le nom d'utilisateur souhaité "

    # Vérifie si l'utilisateur existe sur le serveur distant
    $userExists = ssh $NomDistant@$IpDistante "net user $UserInf"
    if ($userExists) {
        # si oui -> demande quel fichier à vérifier
        $Fichier = Read-Host "Sur quel fichier souhaitez-vous vérifier les droits ? (spécifiez le chemin du fichier)"

        # Vérifie si le fichier existe sur le serveur distant
        if ($Fichier) {
            # affichage des droits
            $Call = Invoke-Command -ComputerName $IpDistante -Credential $NomDistant -ScriptBlock {
                param($FilePath)
                Get-Acl -Path $FilePath } -ArgumentList $Fichier
            $Call
            Start-Sleep -Seconds 2     
            # Enregistrement des données
            Write-Host "Les données sont enregistrées dans le fichier" $PathInfoUser
            "Voici les droits sur le dossier spécifié : " | Out-File -Append -FilePath $PathInfoUser
            $Call | Out-File -Append -FilePath $PathInfoUser
        }
        else {
            # si non -> sortie du script
            Write-Host "Le fichier $Fichier n'existe pas"
            Start-Sleep -Seconds 2
        }
    }
    else {
        # si non -> sortie du script
        Write-Host "L'utilisateur $UserInf n'existe pas"
        Start-Sleep -Seconds 2
    }
}

