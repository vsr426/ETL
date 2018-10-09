#Set-ExecutionPolicy -Scope CurrentUser  remotesigned #restricted #remotesigned

try
{
    Get-AzureRmSubscription
}

catch
{
    Add-AzureRmAccount
}


$resourcegroupname = 'R1234'
$location = 'East US 2'

#Create Resource group
New-AzureRmResourceGroup -Name $resourcegroupname -Location $location

#Create Storage Account if not exist

$defaultstorageaccount = 'storagesree1234'

New-AzureRmStorageAccount -Name $defaultstorageaccount -Location $location -ResourceGroupName $resourcegroupname -Type Standard_LRS

$defaultstorageaccountkey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourcegroupname -StorageAccountName $defaultstorageaccount)[0].Value
$defaultstoragecontext  = New-AzureStorageContext -StorageAccountName $defaultstorageaccount -StorageAccountKey $defaultstorageaccountkey 

# Get information for the HDInsight cluster
$clustername = 'sree1234'
# Cluster login is used to secure HTTPS services hosted on the cluster
$httpusername = 'hduser'
$httppassword= ConvertTo-SecureString 'Hadoop@1234' -AsPlainText -Force
# SSH user is used to remotely connect to the cluster using SSH clients
$sshuser='sshhduser'
$sshpassword = ConvertTo-SecureString 'Hadoop@1234' -AsPlainText -Force

# Create credentials for login
$httpcredential = Get-Credential -UserName $httpusername -Message $httppassword
$sshcredential = Get-Credential -UserName $sshuser -Message $sshpassword

# Default cluster size (# of worker nodes), version, type, and OS
$clusterSizeInNodes = '1'
$clusterVersion ='3.6'
$clustertype = 'Hadoop'
$clusteros = 'Linux'

# Set the storage container name to the cluster name
$defaultblobstoragecontainer = $clustername

# Create a blob container. This holds the default data store for the cluster.
New-AzureStorageContainer -Name $defaultblobstoragecontainer -Context $defaultstoragecontext

# Create the HDInsight cluster

New-AzureRmHDInsightCluster `
-ResourceGroupName $resourcegroupname `
-ClusterName $clustername `
-Location $location `
-ClusterSizeInNodes $clusterSizeInNodes `
-ClusterType $clustertype `
-OSType $clusteros `
-Version $clusterVersion `
-HttpCredential $httpcredential `
-DefaultStorageAccountName $defaultstorageaccount `
-DefaultStorageAccountKey $defaultstorageaccountkey `
-DefaultStorageContainer $defaultblobstoragecontainer `
-SshCredential $sshcredential `
-WorkerNodeSize 'Standard_D3' `
-HeadNodeSize 'Standard_D12_v2' `
-HiveMetastore | Add-AzureRmHDInsightMetastore -SqlAzureServerName 'sreehive.database.windows.net' -DatabaseName 'sree_hive' -Credential 'Hadoop@1234' -MetastoreType HiveMetastore


#Use-AzureRmHDInsightCluster -ClusterName $clustername -HttpCredential $httpcredential -ResourceGroupName $resourcegroupname -
#$tables = Invoke-AzureRmHDInsightHiveJob -JobName 'Hive-ShowTable-eventlogs' -Query 'USE sree_hive; show tables;' -StatusFolder 'C:\temp' 

