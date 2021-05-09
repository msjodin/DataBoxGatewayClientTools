# DataBoxGatewayClientTools
Project to expand on the capabilities of an Azure DataBox Gateway

This was a project I did to expand on the capabilities of an Azure DataBox Gateway to allow a client to pass a text file with pathing to a DataBox Gateway in order to hydrate blobs by copying them from an archive container to a cold container in a storage account, see the status of hydrating files, and refresh the DataBox Gateway. By default Microsoft has no out of the box solution, module, or cmdlet to initiate a refresh on the client side to sync up their metadata representation of what is currently in the storage account container when changes are made from an outside entity (ex. hydrating data, moving data from one container via automated process). This set of scripts when deployed in the same directory allows a client to use a DataBox Gateway to use the Databox Gateway to Upload, Hydrate multiple files via text file, and Download files in DataBox Gateway Shares as opposed to the default supported configuration which is mainly upload only with limited download capability.

To ensure compatibility confirm the Azure modules Az.Accounts, and Az.Storage are installed on the client machine and that the machine is running .Net Framework version 4.8 or above.

If you have any questions implementing this script feel free to reach out to me on LinkedIn or open up an issue on this repo.
