DEBUG: [SEC1N1]:                            [[WaitForAll]CreateLocalAdministrator] Get-RemoteResourceState ...
DEBUG: [SEC1N1]:                            [[WaitForAll]CreateLocalAdministrator] Get resource state on remoteMachine:
 CHDC01
DEBUG: [SEC1N1]:                            [[WaitForAll]CreateLocalAdministrator] Get-RemoteResourceStateOnMachine on
machine: CHDC01 and resource: ...
DEBUG: [SEC1N1]:                            [[WaitForAll]CreateLocalAdministrator] Exception: <f:WSManFault
xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859046"
Machine="SEC1N1.lab.com"><f:Message>WinRM cannot complete the operation. Verify that the specified computer name is
valid, that the computer is accessible over the network, and that a firewall exception for the WinRM service is enabled
 and allows access from this computer. By default, the WinRM firewall exception for public profiles limits access to
remote computers within the same local subnet. </f:Message></f:WSManFault>
VERBOSE: [SEC1N1]:                            [[WaitForAll]CreateLocalAdministrator] Remote resource
'[xADUser]CreateLocalAdministrator' is not ready.
VERBOSE: [SEC1N1]: LCM:  [ End    Test     ]  [[WaitForAll]CreateLocalAdministrator]  in 106.0470 seconds.
VERBOSE: [SEC1N1]: LCM:  [ Start  Set      ]  [[WaitForAll]CreateLocalAdministrator]
