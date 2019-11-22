# macStat

# Overview
A Mac menu bar tool that shows the state of various checks on the system.

![Image of app](https://www.dropbox.com/s/ahcjzpogcus5yjp/fullscreen.png?dl=0)

### What is the macStat application?  
This application is designed to provide a central view of your system compliance and configuration status. The various checks include status on wireless connectivity, Active Directory binding, certificate chain installation, and more.

## Status Tab

The status tab displays information regarding your laptop’s compliance, certificate, and network status. Each check runs commands in the background and returns text responses to describe the laptop’s current status. The macStat app runs eight checks which verify that your laptop is configured and working properly, reference the list below: 

- Software Updates
- Firewall
- Active Directory
- FileVault Encryption
- Jamf Connectivity
- Certificates & 802.1x
- Root Cert Chain 
- Configuration Profiles**


The app will also update icons once the checks complete, see the list below for definitions of the three icons: 
  - The green checkmark will display when the system check signals a passing status. 
  - The orange exclamation mark will display when the system check signals that there may be an issue.
  - The red X will display when the system check confirms a failure for a critical compliance component.
	
#### System Compliance
The System Compliance section checks four main components of the system. These checks are important for VPN connectivity and ensure the system meets Workday security policies.   

#### Mac OS Updates 
The Mac OS Updates check looks for new versions of Apple based software and Mac OS updates based on information about your computer and current software. This check will return information about any missing or pending updates. Your laptop should always have the latest updates to ensure all security requirements are met.

#### Firewall
The Firewall check verifies that the system’s firewall is enabled which prevents certain network access to the system. Your laptop should always have the Firewall enabled to follow basic security practice. 

#### Password Sync
The Password Sync check uses Enterprise Connect to validate that the local user’s password is in sync with their Active Directory password.  The check runs the Enterprise Connect command line tool to determine if the sync is valid and collects the days remaining until the next password change.  

#### FileVault Encryption
The FileVault Encryption check verifies that disk encryption is enabled which prevents unauthorized access to your Mac. FileVault is the Mac disk encryption tool.

#### Certificates & Network Compliance
The certificates & network compliance section provides status on network connectivity requirements and system management.

#### Jamf Connectivity
The Jamf Connectivity check verifies that Jamf is installed on the system and the system is enrolled. Jamf is the tool used to manage Mac devices and must be installed in order to receive supported applications, user certificates, and network connectivity. Jamf is an essential tool and security requirement that needs immediate attention in the event that this check fails. 

#### Certificates & 802.1x
The Certificate & 802.1x check validates that your laptop has the correct User Certificate in the right location. Certificates are used for the corporate wireless network access and VPN authentication. Without this certificate, your laptop will not be able to connect to wireless networks or some VPN.  

#### Root Cert Chain
The root Cert Chain check ensures that your laptop has the correct company Certificate chain which may validate the User Certificate mentioned above. In the event that any of the root Certificates are missing, the check will return and state which certificate is required.  The system will not be able to validate the user certificate required for VPN and WiFi access.  This will disable or make it difficult to connect to VPN or WiFi.

#### Configuration Profiles
The Configuration Profiles check looks to make sure both the User Cert Profile and WiFi 802.1x Profile exist, which are required in order to use your laptop for everyday work.  The Configuration Profiles contain a number of settings that configure your Mac. In the event that a Profile is missing, the check will return and state which profile is missing.   
If the user certificate profile is missing, it’s possible the certificate required for WiFi and VPN access will be missing and you will be unable to connect to either service.  Should the WiFi 802.1x Profile be missing, the system will not have the wireless settings configured and won’t connect to WiFi.


## Info Tab
The info tab collects basic networking, user, and system information and places it in a single window to assist in troubleshooting.  

### User Info
User info contains details about the current logged in user including administrative level, Active Directory group membership, and location.

#### Local Admin Rights
The check for local admin rights confirms that the current logged in user is part of the admin group.  When the user is part of the admin group, they can administer the local Mac.

#### SSH Group Member
When a user is SSH enabled, that user has the ability to login to the local machine remotely with the current logged in user’s credentials.  This is helpful when leaving this computer on and plugged in so that you can use the Secure Shell for remote administration.

#### Account Type
The account type signifies whether the local user is an Active Directory created account or a locally generated account.  The difference is how the password and group membership are affected.  Local accounts must sync their password with Active Directory with a tool like Enterprise Connect.  Mobile accounts are antiquated accounts that require an Active Directory bound system to access corporate resources.

### System Info

System info includes information regarding system data like hard drive space, available memory and network data such as the WiFi SSID, IP addresses, and DNS servers.  This assists in troubleshooting network connectivity as well as resources on the current Mac.

#### Current WiFi SSID
Displays the name of the current wireless SSID name.

#### WiFi IP Address
Displays the current IP address of the wireless interface adapter if a connection is established.

#### Access Point MAC
When connected to a wireless network, this address specifies which access point or antennae you are connected to.  Provide this to the network team when troubleshooting wireless issues.

#### Ethernet IP Address
Displays the IP address of a wired ethernet connection if a connection is established.

#### DNS Servers
Displays the currently assigned DNS servers either issued by DHCP or manually set in the Network preferences in System Preferences.

#### Available RAM
Displays the total RAM available to the system.

#### HD Space Available
Displays the unused size of the primary Hard Drive disk space.

#### AD Bound
Displays whether the system is currently joined to an Active Directory domain.

