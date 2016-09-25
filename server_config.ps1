# Env Configuration
iex ((New-Object net.webclient).DownloadString("https://gist.githubusercontent.com/kenpb/c08f4afc6a78628d46d30e82080f24ba/raw/118eca310d12d46d302891c9510d5fbd35b8c8fd/enviroment_config.ps1"))

# Set the static IP for the rdp and port forwarding
$IP = "192.168.1.175" #  range 2-99 or 150-254 (this avoids any conflict with the default DHCP address range of 100-149).
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$Gateway = "192.168.1.1"
$Dns = ("8.8.8.8", "8.8.4.4")
$IPType = "IPv4"

# Retrieve the network adapter that you want to configure
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}

# Remove any existing IP, gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
    $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}

If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
    $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}

 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
    -AddressFamily $IPType `
    -IPAddress $IP `
    -PrefixLength $MaskBits `
    -DefaultGateway $Gateway

# Configure the DNS client server IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS

# Rename the pc and restart
Rename-Computer -computername (hostname) -newname kenpb-server; Restart-Computer -force
