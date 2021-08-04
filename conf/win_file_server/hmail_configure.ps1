# Configure and install hMailServer for SMTP and IMAP
# Created for ISTS 16
# Author: Micah Martin (mjm5097@rit.edu)
# Copied for IRSEC 2020
#
# To install hMailServer run the installer as follows:
#
#	.\hMailServer-x.x.x-Bxxx.exe /verysilent
#
# To view the COM API configurations, check out the documentation:
#
#	https://www.hmailserver.com/documentation/latest/?page=com_objects
#
# Configure hmail with a new user to use SMTP and IMAP
#

param (
    [string]$domainName = "{{ hmail_domain_name }}",
    [array]$newUsers = @("{{ hmail_users|join('\", \"') }}"),
    [string]$defaultPassword = "{{ hmail_password }}",
    [string]$ipAddr = "10.2.{{ team_number }}.4"
)

# Add users to the server
function Add-UserAccount($user, $accounts, $password) {
    Try
    {
        $account = $accounts.ItemByAddress("$user")
        # Set the password and activate the account
        $account.Password = $password
        $account.Active = $true
        $account.Save()
        Write-Host "[+] $user exists already."
    }
    Catch
    {
        $account = $accounts.Add()
        # Set the email address, password, and activate the account
        $account.Address = "$user"
        $account.Password = $password
        $account.Active = $true
        $account.Save()
        Write-Host "[*] $user created with default password"
    }
}

# Add domain alias to the hMail server
function Add-DomainAlias($domain, $alias) {
    Try {
        $a = $domain.DomainAliases.Add()
        $a.AliasName = $alias
        $a.Save()
    } 
    Catch
    {
        Write-Host "[+] $alias alias exists"
    }
}


# Get the COM Object for hMailServer, If this fails, install hMail
Try
{
    $hMailCom = New-Object -ComObject 'hMailServer.Application'
}
Catch
{
    Install-hMail
    Try
    {
        $hMailCom = New-Object -ComObject 'hMailServer.Application'
    }
    Catch
    {
        Write-Error "[!] Cannot connect hMailServer. Make sure service is installed and re-run script"
        Throw
    }
}

# Print info
Write-Host "[*] Configuring hMail with following settings:"
Write-Host "    - Domain Name: $domainName"
Write-Host "    - Username: $newUser"
Write-Host "    - Default Password: $defaultPassword"
Write-Host ""

# Login. After a fresh install, the password will be blank. Otherwise it is defaultPassword
Write-Host "[*] Logging in..."
$hMail = $hMailCom.Authenticate("Administrator","")
if ($hMail -eq $null) {
    $hMail = $hMailCom.Authenticate("Administrator",$defaultPassword)
    if ($hMail -ne $null) {
        Write-Host "[+] Logged in with default password"
    } else {
        Write-Error "[!] Cannot Log in"
        Throw
    }
} else {
    Write-Host "[+] Logged in with blank password" 
}

##########################################
##
## Add domains and users
##
##########################################

$domains = $hMailCom.Domains
Try
{
    # Check if the domain already exists
    $domain = $domains.ItemByName($domainName)
    # Enable the domain
    $domain.Active = $true
    $domain.Save()
	# Add an alias for the IP address and localhost
    Add-DomainAlias $domain $ipAddr
    Add-DomainAlias $domain "localhost"
    Write-Host "[+] Domain Exists. Moving on" 
}
Catch
{
    # Create a new domain name
    $domain = $domains.Add()
    # Set the name
    $domain.Name = $domainName
    # Enable the domain
    $domain.Active = $true
    $domain.Save()
    # Add an alias for the IP address and localhost
    Add-DomainAlias $domain $ipAddr
    Add-DomainAlias $domain "localhost"
    Write-Host "[*] Domain does not exists. Creating domain"
}

# Get the accounts of the domain
$accounts = $domain.Accounts
foreach ($user in $newUsers) {
    Add-UserAccount "$user@$domainName" $accounts "$defaultPassword"
}

##########################################
##
## Configure key settings
##
##########################################

$settings = $hMailCom.Settings

Write-host "[*] Resetting Admin password"
$settings.SetAdministratorPassword($defaultPassword)

Write-Host '[*] Enabling services'
$settings.ServiceIMAP = $true
$settings.ServicePOP3 = $false
$settings.ServiceSMTP = $true

Write-Host "[*] Configuring services"
$settings.AllowSMTPAuthPlain = $true
$settings.HostName = $domainName
$settings.DefaultDomain = $domainName
$settings.IMAPIdleEnabled = $true
$settings.AutoBanOnLogonFailure = $false

$log = $settings.Logging
Write-Host "[*] Enabling logging"
$log.Enabled = $true
$log.AWStatsEnabled = $true
$log.LogApplication = $true
$log.LogIMAP = $true
$log.LogSMTP = $true
$log.LogTCPIP = $true
$log.MaskPasswordsInLog = $false

Write-Host "[+] Complete. hMail installed"