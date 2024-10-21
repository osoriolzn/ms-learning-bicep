## Lenguaje Bicep
Bicep es un lenguaje de plantilla de Resource Manager que se usa para implementar recursos de Azure mediante declaración. Bicep es un lenguaje específico de dominio, lo que significa que está diseñado para un escenario o dominio en particular. Bicep no está pensado para usarse como lenguaje de programación estándar para escribir aplicaciones. Bicep solo se usa para crear plantillas de Resource Manager. Bicep está pensado para ser fácil de entender y fácil de aprender, independientemente de la experiencia que tenga con otros lenguajes de programación. Todos los tipos de recursos, versiones de API y propiedades son válidos en las plantillas de Bicep.

## Implementación de Bicep
Al implementar un recurso o una serie de recursos en Azure, se envía la plantilla de Bicep a Resource Manager, que todavía requiere plantillas JSON. Las herramientas integradas en Bicep convierten la plantilla de Bicep en una plantilla JSON. Este proceso se conoce como transpilación, que básicamente trata la plantilla de ARM como un lenguaje intermedio. La conversión se produce automáticamente al enviar la implementación, o bien puede hacerse manualmente.

![](https://learn.microsoft.com/es-es/training/modules/includes/media/bicep-to-json.png)

## Tipos de parámetros
Los parámetros de Bicep pueden ser de alguno de los siguientes tipos:

- `string` permite escribir texto arbitrario.
- `int` permite escribir un número.
- `bool` representa un valor booleano (true o false).
- `object` y `array` representan listas y datos estructurados.

**Ejemplo de Objeto:**
```bicep
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
  capacity: 1
}
```

### Reglas de parámetros
- Valores permitidos
  ```bicep
  @allowed([
    'nonprod'
    'prod'
  ])
  param environmentType string
  ```
  Bicep no permitirá que nadie implemente la plantilla a menos que se proporcione uno de estos valores.

  *Uso con operador ternario*
  ```bicep
  var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
  var appServicePlanSkuName = (environmentType == 'prod') ? 'P2V3' : 'F1'
  ```

- Protección
  ```bicep
  @secure()
  param sqlServerAdministratorLogin string

  @secure()
  param sqlServerAdministratorPassword string
  ```

## Prioridad de los parámetros
![](https://learn.microsoft.com/es-es/training/modules/build-reusable-bicep-templates-parameters/media/4-precedence.png)

## Uso de Key Vault con los módulos
Este es un archivo de Bicep de ejemplo que implementa un módulo y proporciona el valor del parámetro de secreto `ApiKey` obteniéndolo directamente de Key Vault:

```bicep
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

module applicationModule 'application.bicep' = {
  name: 'application-module'
  params: {
    apiKey: keyVault.getSecret('ApiKey')
  }
}
```
 
Se hace referencia al recurso de Key Vault mediante la palabra clave `existing`. La palabra clave indica a Bicep que Key Vault ya existe, y este código es una referencia a ese almacén. Bicep no lo implementará de nuevo. Además, observe que el código usa el método `getSecret()` en el valor del parámetro `apiKey` del módulo. Se trata de una función especial de Bicep que solo se puede usar con parámetros de módulo seguros.

## Definición de un módulo
Los módulos de Bicep permiten organizar y reutilizar el código de Bicep mediante la creación de unidades más pequeñas que se pueden combinar en una plantilla. Cualquier plantilla de Bicep se puede usar como módulo por otra plantilla.

![](https://learn.microsoft.com/es-es/training/modules/includes/media/bicep-templates-modules.png)

```bicep
module myModule 'modules/mymodule.bicep' = {
  name: 'MyModule'
  params: {
    location: location
  }
}
```

- `module` Indica a Bicep que va a usar otro archivo de Bicep como módulo.
- `MyModule` El *nombre simbólico* se usa cuando se hace referencia a las salidas del módulo en otras partes de la plantilla.
- `modules/mymodule.bicep` Es la ruta de acceso al archivo de módulo, relativa al archivo de plantilla. Recuerde que un archivo de módulo es simplemente un archivo de Bicep normal.
- `name` **Es obligatoria**. Azure usa el nombre del módulo porque crea una implementación independiente para cada módulo dentro del archivo de plantilla. Esas implementaciones tienen nombres que puede usar para identificarlas.
- `params` Establece los valores de cada parámetro dentro de la plantilla, puede usar expresiones, parámetros de plantilla, variables, propiedades de los recursos implementados dentro de la plantilla y salidas de otros módulos. Bicep comprenderá automáticamente las dependencias entre los recursos.

## Módulos y salidas
Al igual que las plantillas, los módulos de Bicep pueden definir salidas. Es habitual encadenar módulos dentro de una plantilla. En ese caso, la salida de un módulo puede ser un parámetro de otro. Mediante el uso combinado de módulos y salidas, puede crear archivos de Bicep eficaces y reutilizables.

![](https://learn.microsoft.com/es-es/training/modules/create-composable-bicep-files-using-modules/media/2-compose.png)

## Diseño de los módulos
Un buen módulo de Bicep sigue algunos principios clave:

- [x] Un módulo debe tener un propósito claro. Puede usar módulos para definir todos los recursos relacionados con una parte específica de la solución. Por ejemplo, Ud. podría crear un módulo que contenga todos los recursos que se usan para supervisar la aplicación. También podría usar un módulo para definir un conjunto de recursos que son inseparables, como todas las bases de datos y todos los servidores de bases de datos.

- [x] No coloque todos los recursos en su propio módulo. No debe crear un módulo distinto para cada recurso que implemente. Si tiene un recurso que tiene muchas propiedades complejas, puede tener sentido colocar ese recurso en su propio módulo, pero, en general, es mejor que los módulos combinen varios recursos.

- [x] Un módulo debe tener parámetros y salidas claros que tengan sentido. Considere la finalidad del módulo. Piense en si el módulo debe manipular los valores de los parámetros o si la plantilla primaria debe controlar este aspecto y pasar un solo valor al módulo. Del mismo modo, piense en las salidas que debe devolver un módulo y asegúrese de que sean útiles para las plantillas que usarán el módulo.

- [x] Un módulo debe ser lo más independiente posible. Si un módulo necesita usar una variable para definir una de sus partes, la variable generalmente debe incluirse en el archivo de módulo en lugar de en la plantilla primaria.

- [x] Un módulo no debe generar secretos. Al igual que con las plantillas, no cree salidas de módulo para valores secretos como cadenas de conexión o claves.