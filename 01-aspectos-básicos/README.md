## Diseño de los módulos
Un buen módulo de Bicep sigue algunos principios clave:

- Un módulo debe tener un propósito claro. Puede usar módulos para definir todos los recursos relacionados con una parte específica de la solución. Por ejemplo, Ud. podría crear un módulo que contenga todos los recursos que se usan para supervisar la aplicación. También podría usar un módulo para definir un conjunto de recursos que son inseparables, como todas las bases de datos y todos los servidores de bases de datos.

- No coloque todos los recursos en su propio módulo. No debe crear un módulo distinto para cada recurso que implemente. Si tiene un recurso que tiene muchas propiedades complejas, puede tener sentido colocar ese recurso en su propio módulo, pero, en general, es mejor que los módulos combinen varios recursos.

- Un módulo debe tener parámetros y salidas claros que tengan sentido. Considere la finalidad del módulo. Piense en si el módulo debe manipular los valores de los parámetros o si la plantilla primaria debe controlar este aspecto y pasar un solo valor al módulo. Del mismo modo, piense en las salidas que debe devolver un módulo y asegúrese de que sean útiles para las plantillas que usarán el módulo.

- Un módulo debe ser lo más independiente posible. Si un módulo necesita usar una variable para definir una de sus partes, la variable generalmente debe incluirse en el archivo de módulo en lugar de en la plantilla primaria.

- Un módulo no debe generar secretos. Al igual que con las plantillas, no cree salidas de módulo para valores secretos como cadenas de conexión o claves.

## Tipos de parámetros
Los parámetros de Bicep pueden ser de alguno de los siguientes tipos:

- `string` que permite escribir texto arbitrario.
- `int` que permite escribir un número.
- `bool` que representa un valor booleano (true o false).
- `object` y `array` que representan listas y datos estructurados.

**Ejemplo de Objeto:**
```bicep
param appServicePlanSku object = {
  name: 'F1'
  tiel: 'Free'
  capacity: 1
}
```

## Prioridad de los parámetros
![](https://learn.microsoft.com/es-es/training/modules/build-reusable-bicep-templates-parameters/media/4-precedence.png)
