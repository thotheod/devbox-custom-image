# Dev Box Custom Image with Azure Image Builder
This repo contains simple Bicep to create a Dev Box Definition with custom Image. It is not creating all the required recourses for a Dev Box, but it is focusing on the customization with Azure Image Builder. 

## Useful links
- [quick-start-custom-image](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.devcenter/devbox-with-customized-image/customized-image/customized-image.bicep)

##  How-To / Summary
- Follow the steps in the [Quickstart: Configure Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service) until you reach the point of creating a custom image. So the prerequisite steps / resources required (and not covered by this Bicep) are:
    - Create a [Dev Center](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service#create-a-dev-center)
        - Create a [Project](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service#create-a-project)
- Before yoy proceed with the next steps, you need to create a custom image. The documentation is not 100% correct. After I managed to create a custom image, I found out that the image was not validating because the OS SKU is not supported.   
    -  Follow the steps in the [Create a custom image](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-devbox-azure-image-builder). (NOTE: This is having a lot of issues - Powershell, not correct OS SKUs, no correct ARM templates - needs to be fixed)
    - Create a [Gallery](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-devbox-azure-image-builder#create-a-gallery) (or use an existing one) and [configure it / attach it to the Dev Center](https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-azure-compute-gallery#attach-a-gallery-to-a-dev-center)

- Create a [Dev Box Definition](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service#create-a-dev-box-definition)
- Create a [Dev Box Pool](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service#create-a-dev-box-pool)
    - Provide [access to a dev box project](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service#provide-access-to-a-dev-box-project)
- [Create a Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-create-dev-box?tabs=no-existing-dev-boxes#create-a-dev-box)


## Note regarding Image Builder Managed Identity
The Azure Image Builder needs a Managed Identity to be able to create the image. So you need to add a new (or existing) Managed Identity in the imageTemplate (Microsoft.VirtualMachineImages/imageTemplates) that needs to have a custom role definition assigned. as described below. The Role Assignment can be done on the whole RG hosting the image Library

```json
{
    "Name": "Azure Image Builder <Image-Name>",
    "IsCustom": true,
    "Description": "Image Builder access to create resources for the image build, you should delete or split out as appropriate",
    "Actions": [
        "Microsoft.Compute/galleries/read",
        "Microsoft.Compute/galleries/images/read",
        "Microsoft.Compute/galleries/images/versions/read",
        "Microsoft.Compute/galleries/images/versions/write",

        "Microsoft.Compute/images/write",
        "Microsoft.Compute/images/read",
        "Microsoft.Compute/images/delete"
    ],
    "NotActions": [
  
    ],
    "AssignableScopes": [
      "/subscriptions/<subscriptionID>/resourceGroups/<rgName>"
    ]
  }





```
