## Fases de implementación de Bicep
1 - Lint: use el linter de Bicep para comprobar que el archivo de Bicep está bien formado y no contiene errores obvios.

2 - Validate (Validación): use el proceso de validación preparatoria de Azure Resource Manager para comprobar si hay problemas que podrían producirse al realizar la implementación.

3 - Preview (Vista previa): use el comando hipotético para validar la lista de cambios que se aplicarán al entorno de Azure. Pida a una persona que revise manualmente los resultados hipotéticos y apruebe la canalización para continuar.

4 - Deploy (Implementación): envíe la implementación a Resource Manager y espere a que se complete.

5 - Smoke Test (Prueba de comprobación de la compilación): ejecute comprobaciones básicas posteriores a la implementación en algunos de los recursos importantes que ha implementado. Estas revisiones se denominan *pruebas de comprobación de la compilación de la infraestructura*.

![](https://learn.microsoft.com/es-es/training/modules/test-bicep-code-using-azure-pipelines/media/2-stages-bicep.png)

### Fase de linter
```yml
stages:
- stage: Lint
  jobs: 
  - job: Lint
    steps:
      # Con Azure CLI
      - script: |
          az bicep build --file deploy/main.bicep
      # Con PowerShell
      - powershell: |
          bicep build deploy/main.bicep
```

### Fase de validación
```yml
- stage: Validate
  jobs:
  - job: Validate
    steps:
      - task: AzureResourceManagerTemplateDeployment@3
        inputs:
          connectedServiceName: 'MyServiceConnection'
          location: $(deploymentDefaultLocation)
          deploymentMode: Validation
          resourceGroupName: $(ResourceGroupName)
          csmFile: deploy/main.bicep
          overrideParameters: >
            -appWebName $(webName)
```
Validaciones principales:
- ¿Son válidos los nombres que ha especificado para los recursos de Bicep?
- ¿Los nombres que ha especificado para los recursos de Bicep ya están en uso?
- ¿Son válidas las regiones en las que va a implementar los recursos?

### Fase Pre-Implementación
```yml
stages:
- stage: Preview
  jobs: 
  - job: Preview
    steps:
    - task: AzureCLI@2
      inputs:
        azureSubscription: 'MyServiceConnection'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          az deployment group what-if \
            --resource-group $(ResourceGroupName) \
            --template-file deploy/main.bicep
```
Si crea una canalización propia basada en PowerShell, puede usar el cmdlet `New-AzResourceGroupDeployment` con el modificador `-Whatif`, o bien usar el cmdlet `Get-AzResourceGroupDeploymentWhatIfResult`.

### Siguientes fases
Puede ver las demás fases en la platilla de implementación "02-Implementación-bicep-pipelines/deploy/pipeline-templates/deploy.yml"

### Uso de plantillas
Referenciar una plantilla
```yml
stages:
- stage: Lint
  jobs: 
  - template: pipeline-templates/lint.yml
```

Definir una plantilla
```yml
jobs:
- job: LintCode
  displayName: Lint code
  steps:
  # Aquí se definen todos los pasos necesarios
```

***Nota:** Cuando empiece a trabajar con el archivo YAML en plantillas en Visual Studio Code, es posible que vea algunas líneas onduladas de color rojo que indican que hay un problema. Esto se debe a que la extensión de Visual Studio Code para los archivos YAML a veces no adivina correctamente el esquema del archivo.*

*Puede pasar por alto los problemas que notifica la extensión. O bien, si lo prefiere, puede agregar el código siguiente a la parte superior del archivo para suprimir la adivinación de la extensión*

```yml
# yaml-language-server: $schema=./deploy.yml
parameters:
- name: firstParameter
  type: string
```

*Cambie "./deploy.yml" por la ruta de la plantilla en la que se encuentra trabajando*

## Definición y uso de variables
1. Uso en el mismo trabajo:
```yml
stages:
- stage: Stage1
  jobs:
  - job: Job1
    steps:
      # Set the variable's value.
      - script: |
          echo "##vso[task.setvariable variable=myVariableName;isOutput=true]VariableValue"
        name: Step1

      # Read the variable's value.
      - script:
          echo $(myVariableName)
```
2. Uso en otro trabajo:
```yml
stages:
- stage: Stage1
  jobs:
  - job: Job1
    steps:
      # Set the variable's value.
      - script: |
          echo "##vso[task.setvariable variable=myVariableName;isOutput=true]VariableValue"
        name: Step1

  - job: Job2
    dependsOn: Job1
    variables: # Map the variable to this job.
      myVariableName: $[ dependencies.Job1.outputs['Step1.myVariableName'] ]
    steps:
      # Read the variable's value.
      - script: |
          echo $(myVariableName)
```
2. Uso en otra fase:
```yml
stages:
- stage: Stage1
  jobs:
  - job: Job1
    steps:
      # Set the variable's value.
      - script: |
          echo "##vso[task.setvariable variable=myVariableName;isOutput=true]VariableValue"
        name: Step1

- stage: Stage2
  dependsOn: Stage1
  jobs:
  - job: Job1
    variables: # Map the variable to this stage.
      myVariableName: $[ stageDependencies.Stage1.Job1.outputs['Step1.myVariableName'] ]
    steps:
      # Read the variable's value.
    - script: |
        echo $(myVariableName)
```

## Gestión de versión para las plantillas y módulos de Bicep
Se recomienda usar un sistema de control de versiones de *varias partes*. Un sistema de control de versiones de varias partes consta de una versión *principal*, una versión *secundaria* y un número de *revisión*, similar al ejemplo siguiente:

![](https://learn.microsoft.com/es-es/training/modules/publish-reusable-bicep-code-using-azure-pipelines/media/5-version-number.png)

- **Siempre que realice un cambio importante debe incrementar el número de versión principal.** Por ejemplo, supongamos que agrega un nuevo parámetro obligatorio o quita un parámetro del archivo de Bicep. Estos son ejemplos de cambios importantes, ya que Bicep requiere que se especifiquen parámetros obligatorios en el momento de la implementación y no permite establecer valores para parámetros inexistentes. Por lo tanto, debe actualizar el número de versión principal.
- **Siempre que agregue algo nuevo al código que no sea un cambio importante, debe incrementar el número de versión secundaria.** Por ejemplo, supongamos que agrega un nuevo parámetro opcional con un valor predeterminado. Los parámetros opcionales no son cambios importantes, por lo que debe actualizar el número de versión secundaria.
- **Siempre que realice correcciones de errores de compatibilidad con versiones anteriores u otros cambios que no afecten al funcionamiento del código, debe incrementar el número de revisión.** Por ejemplo, supongamos que refactoriza el código de Bicep para hacer un mejor uso de variables y expresiones. Si la refactorización no cambia el comportamiento del código de Bicep, actualice el número de revisión.