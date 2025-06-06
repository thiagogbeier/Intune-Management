Hi again 👋🏻

After a few calls and talking to colleagues and clients and seeing some reddit comments I took some time to check on something that\'s called my attention when it comes to the Name of Intune Certificate Connectors after they get installed and starts to show and report back to Intune Portal.

When you access Intune Portal \\ Tenant Administration \\ Connector and tokens \\ Certificate Connectors or the following 👉🏻 link [**https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/TenantAdminConnectorsMenu/\~/certConnectors**](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/TenantAdminConnectorsMenu/~/certConnectors)

You should see something like the image below where you have the Connector Name, Status and Last Connected and also the \"\...\" the ellipsis that allows you to DELETE 🔥 the connector.

That begged some questions:

- Why I can not pause the connector from the Portal? 👈🏻Stop all related PFX\* windows services on the server and wait for the status to update in the Portal.

- Why is it showing this funky Name and nothing that correlates to the server where the connector is installed? 👈🏻For this I have the FIX 📃, please continue reading the article.

<img src="Images/Picture1.png" width="600" />

(Intune Certificate Connectors list)

A little bit of explanation and big thanks to [**Pedro Gonzalez Martinez**](https://www.linkedin.com/article/edit/7336429038325927937/) who walked me through the secrets behind the scene for this Intune Certificate Connector 🙏🏻

Every time the Intune Certificate Connector is installed in the device it creates a

<img src="Images/Picture2.png" width="600" />

( Correlation between Intune Certificate Connector - Microsoft Intune ImportPFX Connector CA ssl certificate and Portal)

For the sake of the script detection method I matched the Microsoft Intune ImportPFX Connector CA ssl certificate Thumbprint with its correspondent information retrieved from Registry.

---

Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\Microsoft\\MicrosoftIntune\\PFXCertificateConnector\" -ErrorAction SilentlyContinue

---

---

<img src="Images/Picture3.png" width="600" />

( Microsoft Intune ImportPFX Connector CA ssl certificate Thumbprint )

<img src="Images/Picture4.png" width="600" />

( Intune Certificate Connector registry key information )

I managed to create a PowerShell Script that:

- Detects and installs the required MS Graph PowerShell Module

- **New Naming Standard:** Injects as PREFIX the Server Name on the retrieved DisplayName from Graph Api updating it and keeping the Original default Naming convention from Microsoft/Intune. That comes with the feature (PFX), and MM/DD/YYYY and HH:MM format from when the service was installed. 🤯

- Lists all services starting with PFX status and service accounts

**Expected results**

_Server has no Intune Certificate Connector_

<img src="Images/Picture5.png" width="600" />

(When there\'s no Intune Certificate Connector installed on the specific server)

_Server has Intune Certificate Connector DisplayName up to date._

<img src="Images/Picture6.png" width="600" />

(When there\'s Intune Certificate Connector installed on the server and its DisplayName is already up to date in Intune Portal / Graph API)\*\*

_Server has Intune Certificate Connector and needs DisplayName to be updated to new Standard._

<img src="Images/Picture7.png" width="600" />

(When there\'s Intune Certificate Connector installed on the server and its DisplayName requires to be updated)

Powered by <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" alt="GitHub Logo" width="24" />
