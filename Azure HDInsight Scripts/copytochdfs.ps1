$resourcegroup = 'R1234'
$storageaccountname = 'storagesree1234'
$storagecontainer='sree1234'

$filename ='D:\01-Learning\EDX\Mircosoft DAT2012.1x\event logs.csv'
$blobname ='input\event logs.csv'

$storageaccountkey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourcegroup -Name $storageaccountname)[0].value
$storagecontext = New-AzureStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $storageaccountkey

Set-AzureStorageBlobContent -File $filename -Context $storagecontext -Container $storagecontainer -Blob $blobname