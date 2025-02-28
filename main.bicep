targetScope = 'resourceGroup'

// ------------------
// PARAMETERS
// ------------------

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(10)
param name string 


@description('Optional. The location for the library. Defaults to the location of the resource group.')
param location string = resourceGroup().location


@description('The name of the Azure Compute Gallery. If EMPTY a new one will be created, other wise the existing one will be used.')
@maxLength(80)
param computeGalleryName string

@description('The name of the image definition in the gallery') 
@maxLength(80)
param imageDefinitionName string

@description('default settings for the image definition') 
param imageDefinitionSettings object = {
  publisher: 'microsoftvisualstudio'
  offer: 'visualstudioplustools'
  sku: 'vs-2022-pro-general-win11-m365-gen2'
  version: 'latest'
}

@description('Guid for generating random template name')
param randomguid string = newGuid()


// ------------------
// VARIABLES
// ------------------
var resourceNames = {
   azureComputeGalleryName: computeGalleryName == '' ? replace('gal_${name}', '-', '_' ) : computeGalleryName
   imgBuilderIdenityName: 'id-imgbuilder-${name}'
   imageTemplateName: take('${name}_${guid(resourceGroup().id)}_${imageDefinitionName}',64)
   imageTemplateBuildName: take('${name}_${guid(resourceGroup().id)}_img_build_trigger',64)
   queryTemplateProgress: take('${name}_${guid(resourceGroup().id)}_img_build_query',64)
}

var imgBuilderCustomRoleDefinitionName = guid(resourceGroup().id)
var createNewResources = computeGalleryName == '' ? true : false
var readerDefinitionId =  resourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var extraToolsScript = split(loadTextContent('scripts/example.ps1'), ['\r','\n'])
var buildCommand = 'Invoke-AzResourceAction -ResourceName "${resourceNames.imageTemplateName}" -ResourceGroupName "${resourceGroup().name}" -ResourceType "Microsoft.VirtualMachineImages/imageTemplates" -ApiVersion "2024-02-01" -Action Run -Force'



// ------------------
// RESOURCES
// ------------------

@description('The new azure compute gallery, that will hold the new Custom Image Definition.')
resource azureComputeGallery 'Microsoft.Compute/galleries@2024-03-03' = if (createNewResources) {
  name: resourceNames.azureComputeGalleryName
  location: location
}

resource imageDefinition 'Microsoft.Compute/galleries/images@2024-03-03' = {
  parent: azureComputeGallery
  name: imageDefinitionName
  location: location
  properties: {
    hyperVGeneration: 'V2'
    architecture: 'x64'
    features: [
      {
          name: 'SecurityType'
          value: 'TrustedLaunch'
      }
    ]
    identifier: {
      offer: imageDefinitionSettings.offer
      publisher: imageDefinitionSettings.publisher
      sku: imageDefinitionSettings.sku
    }
    osState: 'Generalized'
    osType: 'Windows'
  }
}

resource imgBuilderIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: resourceNames.imgBuilderIdenityName
  location: location
}

resource imgBuilderCustomRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: imgBuilderCustomRoleDefinitionName
  properties: {
    roleName: imgBuilderCustomRoleDefinitionName
    description: 'Image Builder access to create resources for the image build'
    type: 'customRole'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
          'Microsoft.Storage/storageAccounts/blobServices/containers/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/write'
          'Microsoft.Resources/deployments/read'
          'Microsoft.Resources/deploymentScripts/read'
          'Microsoft.Resources/deploymentScripts/write'
          'Microsoft.VirtualMachineImages/imageTemplates/run/action'
          'Microsoft.ContainerInstance/containerGroups/read'
          'Microsoft.ContainerInstance/containerGroups/write'
          'Microsoft.ContainerInstance/containerGroups/start/action'
        ]
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

resource templateRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, '${imgBuilderCustomRoleDefinition.id}', imgBuilderIdentity.id)
  properties: {
    roleDefinitionId: imgBuilderCustomRoleDefinition.id
    principalId: imgBuilderIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource readerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, readerDefinitionId, imgBuilderIdentity.id)
  properties: {
    roleDefinitionId: readerDefinitionId
    principalId: imgBuilderIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2024-02-01' = {
  name: resourceNames.imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${imgBuilderIdentity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 180
    vmProfile: {
      vmSize: 'Standard_D8ds_v4'
      osDiskSizeGB: 256
    }
    source: {
      type: 'PlatformImage'
      offer: imageDefinitionSettings.offer
      publisher: imageDefinitionSettings.publisher
      sku: imageDefinitionSettings.sku
      version: imageDefinitionSettings.version
    }
    customize: [
      {
        type: 'PowerShell'
        name: 'Install Extra Tools'
        inline: extraToolsScript
      }
    ]    
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: imageDefinition.id
        runOutputName: '${imageDefinitionName}_Output'
        replicationRegions: array(location)
      }
    ]
  }
  dependsOn: [
    templateRoleAssignment
  ]
}

resource imageTemplateBuild 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: resourceNames.imageTemplateBuildName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${imgBuilderIdentity.id}': {}
    }
  }
  dependsOn: [
    imageTemplate
    templateRoleAssignment
  ]
  properties: {
    forceUpdateTag: randomguid
    azPowerShellVersion: '8.3'
    scriptContent: buildCommand
    timeout: 'PT3H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

@description('The status of the image template build. It takes around 60+ minutes to complete, so with this the deployment stays active and waits for the image to be built.')
resource imageTemplateStatusQuery 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: resourceNames.queryTemplateProgress
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${imgBuilderIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    scriptContent: 'Connect-AzAccount -Identity; \'Az.ImageBuilder\', \'Az.ManagedServiceIdentity\' | ForEach-Object {Install-Module -Name $_ -AllowPrerelease -Force}; $status=\'Started\'; while ($status -ne \'Succeeded\' -and $status -ne \'Failed\' -and $status -ne \'Cancelled\') { Start-Sleep -Seconds 30;$status = (Get-AzImageBuilderTemplate -ImageTemplateName ${resourceNames.imageTemplateName} -ResourceGroupName ${resourceGroup().name}).LastRunStatusRunState}'  
    timeout: 'PT3H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    imageTemplate
    imageTemplateBuild
  ]
}


// TODO: Check if withe existing works
// @description('The new azure compute gallery, that will hold the new Custom Image Definition.')
// resource azureComputeGalleryExisting 'Microsoft.Compute/galleries@2024-03-03'  existing= if (!createNewResources) {
//   name: computeGalleryName
// }

//TODO Add existing resource imageDefinition 'Microsoft.Compute/galleries/images@2024-03-03' = {

//TODO Add existing resource imgBuilderIdenity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {


// ------------------
// OUTPUTS
// ------------------

output galleryName string = azureComputeGallery.name
output imageDefinitionName string = imageDefinition.name
output imageTemplateName string = imageTemplate.name
