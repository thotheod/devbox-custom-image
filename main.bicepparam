using './main.bicep'

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(10)
param name = 'ttdevimg04'

@maxLength(80)
@description('The name of the Azure Compute Gallery. If Empty a new one will be created, other wise the existing one will be used.')
param computeGalleryName = ''

@description('The name of the image definition in the gallery') 
@maxLength(80)
param imageDefinitionName = 'vs2022-custom-dev-image-${name}'

// @description('Optional. The location for the library. Defaults to the location of the resource group.')
// param location = resourceGroup().location

@description('default settings for the image definition') 
param imageDefinitionSettings = {
  publisher: 'microsoftvisualstudio'
  offer: 'visualstudioplustools'
  sku: 'vs-2022-pro-general-win11-m365-gen2'  
  version: 'latest'
}
