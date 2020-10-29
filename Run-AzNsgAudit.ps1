    <#
    .SYNOPSIS
        Searches through every NSG in each subscription configured in Az Powershell for 3389 or 22 ports open.

    .OUTPUTS
        Creates a file called nsg-audit.csv in the users home folder.

    .EXAMPLE
        Example of how to run the script.

    #>

$azSubs = Get-AzSubscription

foreach ($azSub in $azSubs) {
    Set-AzContext -Subscription $azSub | Out-Null
    $azNsgs = Get-AzNetworkSecurityGroup

    foreach ($azNsg in $azNsgs) {
        Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg | Where-Object { ($_.DestinationPortRange -eq 22) -or ($_.DestinationPortRange -eq 3389) } | `
        Select-Object @{label = 'NSG Name'; expression= { $azNsg.Name } }, @{label = 'Rule Name'; expression = { $_.Name } }, `
        @{label = 'Port Range'; expression = { $_.DestinationPortRange } }, Access, Priority, Direction, `
        @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } `
        @{label = 'Subscription'; expression = { $azSub.Name } } | Export-Csv -Path "$($home)\nsg-audit.csv" -NoTypeInformation -Append
    }
}