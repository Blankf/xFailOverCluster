<#
.EXAMPLE
    This example shows how to add an additional node to the failover cluster
    when the cluster was assigned an IP address from a DHCP.
#>

Configuration Example
{
    param(
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $ActiveDirectoryAdministratorCredential
    )

    Import-DscResource -ModuleName xFailOverCluster

    Node localhost
    {
        WindowsFeature AddFailoverFeature
        {
            Ensure = 'Present'
            Name   = 'Failover-clustering'
        }

        WindowsFeature AddRemoteServerAdministrationToolsClusteringPowerShellFeature
        {
            Ensure    = 'Present'
            Name      = 'RSAT-Clustering-PowerShell'
            DependsOn = '[WindowsFeature]AddFailoverFeature'
        }

        WindowsFeature AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature
        {
            Ensure    = 'Present'
            Name      = 'RSAT-Clustering-CmdInterface'
            DependsOn = '[WindowsFeature]AddRemoteServerAdministrationToolsClusteringPowerShellFeature'
        }

        xWaitForCluster WaitForCluster
        {
            Name             = 'Cluster01'
            RetryIntervalSec = 10
            RetryCount       = 60
            DependsOn        = '[WindowsFeature]AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature'
        }

        xCluster JoinSecondNodeToCluster
        {
            Name                          = 'Cluster01'
            DomainAdministratorCredential = $ActiveDirectoryAdministratorCredential
            DependsOn                     = '[xWaitForCluster]WaitForCluster'
        }
    }
}
