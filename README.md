# Training Bicep

## Playground
Compara las plantillas de bicep vs JSON: [Bicep Playground](https://azure.github.io/bicep/)

## Comandos Bicep
Descompilar una plantilla JSON a Bicep:
```bicep
bicep decompile
```

Validar la plantilla Bicep
```bicep
bicep build main.bicep
```
***Nota:** Al ejecutar el comando `build`, Bicep también transpila el código de Bicep en una plantilla de ARM JSON. Por lo general, no necesita el archivo que genera, por lo que puede omitirlo.*

## Nombrar recursos
Documentación 👉 [Definición de convención de nomenclatura](https://learn.microsoft.com/es-es/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

Herramienta 👉 [Azure Naming Tool](https://github.com/mspnp/AzureNamingTool/wiki/Run-as-a-Docker-Image)
