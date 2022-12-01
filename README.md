# Arquitectura de Microprocesadores Co18CESE
## Repositorio de preguntas y trabajos

### Preguntas orientadoras

1. Describa brevemente los diferentes perfiles de familias de microprocesadores/microcontroladores de ARM. Explique alguna de sus diferencias características.
**Cortex-A**
Procesadores de Aplicacion, diseñados para mayor rendimiento y uso de OS avanzados (Android, Linux, etc.). Pueden usar clocks de mayores velocidades (> 1 GHz) e incluyen  MMU. Poseen un pipeline de procesador de mayor largo.
Usos: En dispositivos moviles, tablets, televisiones, etc.
Desventajas: No estan diseñados para dar respuestas rapidas a eventos de hardware.

**Cortex-R**
Procesadores de Real-Time, son buenos para procesar datos. Corren a velocidad de clocks intermedias (entre 500MHz y 1GHz). Estan diseñados para responder bien a eventos de hardware. Poseen memoria que los provee de un comportamiento **determinista**. Poseen capacidades para que tengan mas fiabilidad (Error Correcting Code).
Usos: Controladores de discos rigidos, modems, microcontroladores especializados para uso automotriz o industrial.
Desventajas: Diseños bastante complejos y consumos de energia elevados.

**Cortex-M**
Procesadores diseñados para el mercado general de microcontroladores donde los requerimientos de procesamiento son menores y necesitan que el consumo de energia sea poco. Diseñados con un pipeline relativamente corto, siendo de 2 pasos en los M0+, de 3 pasos en los M0, M3 y M4 y en los M7 de 6 pasos por su requerimiento de mayor desepeño (Aun en este ultimo caso es bastante mas corto que los procesadores pensados para aplicaciones). Debido a el pipeline mas corto y limites en el clock del procesador presentan un poder de procesamiento menor a los Cortex-M y a los Cortex-A. Fueron diseñados para atender rapidamente a interrupciones y tener un compartamiento determinista. Esto se debe a un Nested Vector Interrupt Controller apareado con el bloque de control del procesador. Son diseñados mayormente para poder ser programados en C.
Usos: En sensores, chipsets de comunicacion wireless y como controlador para subsistemas de procesadores de aplicacion mas complejos.
Desventajas: Menor poder y velocidad de procesamiento que las otras familias, sets de instrucciones mas reducidos. 

#### Cortex M

1. Describa brevemente las diferencias entre las familias de procesadores Cortex M0, M3 y M4.
Set de instrucciones
M0 y M0+ poseen sets de instrucciones pequeños por lo cual la densidad del codigo es mejor. Son compatibles con la mayor parte de las instrucciones Thumb y con algunas del Thumb-2.
M3 y M4 expanden sobre este set de instrucciones (utilizando mayormente instrucciones de 32 bits haciendo que puedan utilizar mas eficientemente los registros). Poseen compatibiliad con todas las intrucciones Thumb y Thumb-2. M4 incluye instrucciones Single Instruction Multiple Data e instrucciones de aritmetica saturada para realizar procesamiento de señales digital.

Arquitectura
M0 y M0+ utilizan arquitectura Von Neumann.
M3 y M4 utilizan arquitectura Harvard.

Systick
M0 y M0+ la implementacion de un systick es opcional.
M3 y M4 incluyen la implementacion del systick.

Energia
M0 y M0+ debido a su bajo numero de compuertas logicas su consumo energetico es el minimo.
M3 y M4 como tienen mayor poder de procesamiento y mayor numero de compuertas logicas su consumo aumenta.

MMU
M0 no tiene MMU.
M0+, M3 y M4 poseen la **posibilidad** de tener MMU.

Cache
M0, M0+ y M3 no tienen memoria cache.
M4 tiene la **posibilidad** de tener memoria cache.

2. ¿Por qué se dice que el set de instrucciones Thumb permite mayor densidad de código? Explique

3. ¿Qué entiende por arquitectura load-store? ¿Qué tipo de instrucciones no posee este tipo de arquitectura?

4. ¿Cómo es el mapa de memoria de la familia?

5. ¿Qué ventajas presenta el uso de los “shadowed pointers” del PSP y el MSP?

6. Describa los diferentes modos de privilegio y operación del Cortex M, sus relaciones y como se conmuta de uno al otro. Describa un ejemplo en el que se pasa del modo privilegiado a no priviligiado y nuevamente a privilegiado.

El procesador Cortex-M tiene 2 modos de operacion:
    Thumb state: El procesador actualmente esta corriendo instrucciones del codigo.
    Debug state: Algun evento (por el debugger o un breakpoint) de debug pauso al procesador y no esta corriendo instrucciones.

En el modo Thumb se pueden tener 2 modos de opercion:
    Thread Mode: Se encuentra ejecutando codigo de aplicacion.
    Handler Mode: Se encuentra ejecutando alguna rutina de excepcion (Como es el ISR)

En el modo Thread se pueden tener 2 niveles de privilegio:
    Privileged Access: La aplicacion tiene acceso a toda la memoria y puede leer y modificarla. El Handler Mode siempre tiene este nivel de privilegio.
    Unprivileged Access: La aplicacion no tiene permisos para acceder a partes criticas de la memoria para evitar que esta pueda corromperla. Si esta aplicacion crashea, solo se veria afectada su porcion de la memoria y no afectaria a otras aplicaciones. 

Una aplicacion puede pasar a Thread Mode modificando el registro de CONTROL (nPRIV en 0 para Privileged Mode y en 1 para Unprivileged Mode) en cualquier momento de su ejecucion pero este solo no puede volver. Si se quiere volver al Privileged Mode se debe hacer mediante el Handler Mode ya que el si tiene los privilegios necesarios para modificar el registro CONTROL.
7. ¿Qué se entiende por modelo de registros ortogonal? Dé un ejemplo

8. ¿Qué ventajas presenta el uso de intrucciones de ejecución condicional (IT)? Dé un ejemplo

9. Describa brevemente las excepciones más prioritarias (reset, NMI, Hardfault).

10. Describa las funciones principales de la pila. ¿Cómo resuelve la arquitectura el llamado a funciones y su retorno?

11. Describa la secuencia de reset del microprocesador.

12. ¿Qué entiende por “core peripherals”? ¿Qué diferencia existe entre estos y el resto de los periféricos?

13. ¿Cómo se implementan las prioridades de las interrupciones? Dé un ejemplo

14. ¿Qué es el CMSIS? ¿Qué función cumple? ¿Quién lo provee? ¿Qué ventajas aporta?

15. Cuando ocurre una interrupción, asumiendo que está habilitada ¿Cómo opera el microprocesador para atender a la subrutina correspondiente? Explique con un ejemplo

17. ¿Cómo cambia la operación de stacking al utilizar la unidad de punto flotante?

18. Explique las características avanzadas de atención a interrupciones: tail chaining y late arrival.

19. ¿Qué es el systick? ¿Por qué puede afirmarse que su implementación favorece la portabilidad de los sistemas operativos embebidos?

20. ¿Qué funciones cumple la unidad de protección de memoria (MPU)?

21. ¿Cuántas regiones pueden configurarse como máximo? ¿Qué ocurre en caso de haber solapamientos de las regiones? ¿Qué ocurre con las zonas de memoria no cubiertas por las regiones definidas?

22. ¿Para qué se suele utilizar la excepción PendSV? ¿Cómo se relaciona su uso con el resto de las excepciones? Dé un ejemplo

23. ¿Para qué se suele utilizar la excepción SVC? Expliquelo dentro de un marco de un sistema operativo embebido.

#### ISA

1. ¿Qué son los sufijos y para qué se los utiliza? Dé un ejemplo

2. ¿Para qué se utiliza el sufijo ‘s’? Dé un ejemplo

3. ¿Qué utilidad tiene la implementación de instrucciones de aritmética saturada? Dé un ejemplo con operaciones con datos de 8 bits.

4. Describa brevemente la interfaz entre assembler y C ¿Cómo se reciben los argumentos de las funciones? ¿Cómo se devuelve el resultado? ¿Qué registros deben guardarse en la pila antes de ser modificados?

5. ¿Qué es una instrucción SIMD? ¿En qué se aplican y que ventajas reporta su uso? Dé un ejemplo

