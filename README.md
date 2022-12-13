# Arquitectura de Microprocesadores Co18CESE
## Repositorio de preguntas y trabajos

### Preguntas orientadoras

1. Describa brevemente los diferentes perfiles de familias de microprocesadores/microcontroladores de ARM. Explique alguna de sus diferencias características.
**Cortex-A**
Procesadores de Aplicación, diseñados para mayor rendimiento y uso de OS avanzados (Android, Linux, etc.). Pueden usar clocks de mayores velocidades (> 1 GHz) e incluyen  MMU. Poseen un pipeline de procesador de mayor largo.
Usos: En dispositivos moviles, tablets, televisiones, etc.
Desventajas: No están diseñados para dar respuestas rápidas a eventos de hardware.

**Cortex-R**
Procesadores de Real-Time, son buenos para procesar datos. Corren a velocidad de clocks intermedias (entre 500MHz y 1GHz). Están diseñados para responder bien a eventos de hardware. Poseen memoria que los provee de un comportamiento **determinista**. Poseen capacidades para que tengan mas fiabilidad (Error Correcting Code).
Usos: Controladores de discos rígidos, modems, microcontroladores especializados para uso automotriz o industrial.
Desventajas: Diseños bastante complejos y consumos de energia elevados.

**Cortex-M**
Procesadores diseñados para el mercado general de microcontroladores donde los requerimientos de procesamiento son menores y necesitan que el consumo de energía sea poco. Diseñados con un pipeline relativamente corto, siendo de 2 pasos en los M0+, de 3 pasos en los M0, M3 y M4 y en los M7 de 6 pasos por su requerimiento de mayor desempeño (Aun en este ultimo caso es bastante mas corto que los procesadores pensados para aplicaciones). Debido a el pipeline mas corto y limites en el clock del procesador presentan un poder de procesamiento menor a los Cortex-M y a los Cortex-A. Fueron diseñados para atender rápidamente a interrupciones y tener un comportamiento determinista. Esto se debe a un Nested Vector Interrupt Controller apareado con el bloque de control del procesador. Son diseñados mayormente para poder ser programados en C.
Usos: En sensores, chipsets de comunicación wireless y como controlador para subsistemas de procesadores de aplicación mas complejos.
Desventajas: Menor poder y velocidad de procesamiento que las otras familias, sets de instrucciones mas reducidos. 

#### Cortex M

1. Describa brevemente las diferencias entre las familias de procesadores Cortex M0, M3 y M4.
Set de instrucciones
M0 y M0+ poseen sets de instrucciones pequeños por lo cual la densidad del código es mejor. Son compatibles con la mayor parte de las instrucciones Thumb y con algunas del Thumb-2.
M3 y M4 expanden sobre este set de instrucciones (utilizando mayormente instrucciones de 32 bits haciendo que puedan utilizar mas eficientemente los registros). Poseen compatibilidad con todas las instrucciones Thumb y Thumb-2. M4 incluye instrucciones Single Instruction Multiple Data e instrucciones de aritmética saturada para realizar procesamiento de señales digital.

Arquitectura
M0 y M0+ utilizan arquitectura Von Neumann.
M3 y M4 utilizan arquitectura Harvard.

Systick
M0 y M0+ la implementación de un systick es opcional.
M3 y M4 incluyen la implementación del systick.

Energia
M0 y M0+ debido a su bajo numero de compuertas lógicas su consumo energético es el mínimo.
M3 y M4 como tienen mayor poder de procesamiento y mayor numero de compuertas lógicas su consumo aumenta.

MMU
M0 no tiene MMU.
M0+, M3 y M4 poseen la **posibilidad** de tener MMU.

Cache
M0, M0+ y M3 no tienen memoria cache.
M4 tiene la **posibilidad** de tener memoria cache.

2. ¿Por qué se dice que el set de instrucciones Thumb permite mayor densidad de código? Explique

Debido a que los procesadores soportan tanto instrucciones de 16-bits y de 32-bits los programas pueden lograr los mismos resultados en una menor cantidad de instrucciones. Esto se logra mediante características como varios modos de direccionamientos de memoria, múltiples accesos de memoria mediante una sola instrucción, etc.

3. ¿Qué entiende por arquitectura load-store? ¿Qué tipo de instrucciones no posee este tipo de arquitectura?

Para operar sobre un dato es necesario que este sea copiado de la memoria a un registro para poder recién ser modificado y después se tenga que copiar del registro a la memoria. Debido a esto es se conoce este tipo de arquitectura como load-store. Las instrucciones se separan en instrucciones de movimiento (de memoria al registro o viceversa) y de operaciones (que se hacen entre registros o entre registros y valores).

4. ¿Cómo es el mapa de memoria de la familia?

El bus de direccionamiento del procesador es de 32 bits por lo cual soporta un mapa de memoria de hasta 4 GB. Por mas que no sea necesario para sistemas embebidos esto garantiza compatibilidad futura y posibles mejoras.
El mapa delimita diferentes areas para funcionalidades especificas como:
CODE region
SRAM region
Periféricos
Control interno del procesador y funciones de debuging

![Mapa de memoria](/Figuras/MapaDeMemoria.png)

5. ¿Qué ventajas presenta el uso de los “shadowed pointers” del PSP y el MSP?

MSP: Main Stack Pointer es el stack pointer por defecto. Se utiliza en el modo Thread cuando el CONTROL bit[1] (SPSEL) es 0 y en el modo Handler se utiliza siempre.
PSP: Program Stack Pointer se utiliza en el Thread mode cuando el CONTROL bit[1] (SPSEL) es 1.

Si no utilizamos un OS podemos usar siempre el MSP e ignorar el PSP.
Si usamos un OS, el MSP es utilizado por el manejadores de excepciones mientras que el PSP es utilizado por las aplicaciones teniendo cada una un espacio propio del stack. El cambio de contexto del OS se encarga de cambiar el valor del PSP.
Se los conoce como Shadowed Pointers porque no pueden ser modificados directamente si no que tenemos que indicar con una modificación de un bit especifico a un registro especifico cual es el puntero al stack que vamos a utilizar al volver de la interrupción.

Las ventajas son:
En caso de producirse algún error en una aplicación que corrompa la memoria, este solo afectaría al stack de la misma. El OS y otras aplicaciones no se verian afectadas idealmente.
El OS puede utilizar el MMU para definir la region del stack que las aplicaciones pueden utilizar, produciendo una excepción de MemManage en caso de que el programa produzca un stack overflow. 

6. Describa los diferentes modos de privilegio y operación del Cortex M, sus relaciones y como se conmuta de uno al otro. Describa un ejemplo en el que se pasa del modo privilegiado a no privilegiado y nuevamente a privilegiado.

El procesador Cortex-M tiene 2 modos de operación:
    Thumb state: El procesador actualmente esta corriendo instrucciones del código.
    Debug state: Algún evento (por el debugger o un breakpoint) de debug pauso al procesador y no esta corriendo instrucciones.

En el modo Thumb se pueden tener 2 modos de operación:
    Thread Mode: Se encuentra ejecutando código de aplicación.
    Handler Mode: Se encuentra ejecutando alguna rutina de excepción (Como es el ISR)

En el modo Thread se pueden tener 2 niveles de privilegio:
    Privileged Access: La aplicación tiene acceso a toda la memoria y puede leer y modificarla. El Handler Mode siempre tiene este nivel de privilegio.
    Unprivileged Access: La aplicación no tiene permisos para acceder a partes criticas de la memoria para evitar que esta pueda corromperla. Si esta aplicación crashea, solo se vería afectada su porción de la memoria y no afectaría a otras aplicaciones. 

Una aplicación puede pasar a Thread Mode modificando el registro de CONTROL (nPRIV en 0 para Privileged Mode y en 1 para Unprivileged Mode) en cualquier momento de su ejecución pero este solo no puede volver. Si se quiere volver al Privileged Mode se debe hacer mediante el Handler Mode ya que el si tiene los privilegios necesarios para modificar el registro CONTROL.

7. ¿Qué se entiende por modelo de registros ortogonal? Dé un ejemplo

Que un registro sea ortogonal nos permite la combinación en una instrucción de diferentes operaciones, modos de direccionamiento y de tipos de datos

Ej:
LDRH R5,[R1,R2,LSL 2]
Guarda un dato de half word (16 bits) ubicado en R5 en la posición de memoria indicado por [R1 + (R2 << 2)]

8. ¿Qué ventajas presenta el uso de instrucciones de ejecución condicional (IT)? Dé un ejemplo

Las instrucciones de ejecución condicional son cargadas de todas maneras en el pipeline, produciendo un mejor aprovechamiento del mismo ya que no se va a destruir por completo en el caso de que se corra una ejecución condicional. Este tiene un limite de 4 posibles condiciones, en caso de superar esto ya no hay una ventaja frente a un salto.
Ej:
ITTE **NE**
AND**NE** r0, r0, r1
ADD**NE** r2, r2, #1
MOV**EQ** r2, r3

Las instrucciones en el bloque IT deben ser las mismas, o la inversa de otras.

9. Describa brevemente las excepciones más prioritarias (reset, NMI, Hardfault).

Las excepciones son eventos que causan cambios en el flujo del programa fuera de la secuencia de código normal. Cuando sucede este excepción la ejecución actual del programa es suspendida y el exception handler asociado es ejecutado. Cada excepción tiene un numero único y una prioridad asociada. En algunas excepciones esta prioridad es programable y en otras es fija.

**Reset**
Esta excepción tiene la prioridad mas alta (-3) y se corre apenas se recibe una señal de reset en el µC

**NMI** 
Non Maskable Interrupt tiene la segunda prioridad mas alta (-2) y se utiliza para sistemas donde la seguridad es critica. Puede ser usada para manejar alguna falla en el suministro eléctrico del dispositivo o atada a algún watchdog que reinicie el sistema si este deja de responder.

**Hard Fault**
Esta excepción se dedica a manejar cualquier condición fallida  durante la ejecución del programa como pueden ser códigos de operaciones incorrectos, alguna falla en los buses de memoria o direccionamiento o si se intenta cambiar de estado sin privilegios. 

10. Describa las funciones principales de la pila. ¿Cómo resuelve la arquitectura el llamado a funciones y su retorno?

La pila o el stack es un área de memoria con lógica LiFo que se utiliza para:
Guardar el estado del procesador y de los registros de propósito general cuando se produce una interrupción pudiendo salvar el estado actual de los mismos para poder después reanudar donde se quedo.
Pasar datos a subrutinas o funciones.
Guardar valores de los registros temporalmente para que después puedan volver a ser accedidos.

Se maneja mediante un registro donde lleva su dirección de memoria y se puede mandar datos a la misma de un registro mediante la instrucción PUSH Rx y se puede sacar datos de ella mediante POP Rx. La actualización del registro de dirección se hace automáticamente en ambos casos.

Cuando es llamada una función los primeros 4 parámetros no son pasados mediante la pila si no que se posición automáticamente en los registros R0, R1, R2 y R3 (los valores anteriores del llamado a estar función son guardados y van a ser traídos una vez que esta termine). Si la función tiene que retornar algo esto se hará mediante el registro R0

11. Describa la secuencia de reset del microprocesador.

Después de que se produzca un reset y antes de que el procesador empiece a ejecutar código lo primero que hace el procesador es leer los dos primeras words de la memoria 0x00000000 y 0x00000004 las cuales contienen el valor inicial del MSP y el vector de reset que es la dirección de inicio del Reset Handler. Después de eso empieza a ejecutar las instrucciones del Reset Handler.

12. ¿Qué entiende por “core peripherals”? ¿Qué diferencia existe entre estos y el resto de los periféricos?

Los Core Peripherals son periféricos que estan atados en su control y maneja directamente a instrucciones del procesador. Estos son manejados constanemente por el (pueden ser el NVIC, el systick o el MMU si es que esta implementada). A diferencia de los Core Independent Peripherals estos requieren ciclos del reloj del procesador para ser atendidos. Los segundos no requieren un manejo constante del procesador y pueden actuar independientemente del mismo. Esto tiene ventajas ya que aumenta el tiempo efectivo del procesador en tareas especificas y se evitan posibles saltos durante el proceso del mismo.
Estan implementados dentro del mismo procesador los Core Peripherals.

13. ¿Cómo se implementan las prioridades de las interrupciones? Dé un ejemplo

En los Cortex-M4 las prioridades de las interrupciones se implementan mediante un controlador (NVIC) exclusivamente dedicado a ello. Este posee un vector de hasta 240 interrupciones y con múltiples niveles de prioridad de las mismas (entre 8 y 256 niveles).
Las únicas que no son programables son las interrupciones de Reset, NMI y HardFault que siempre estan presentes y tienen una prioridad de -3, -2 y -1 respectivamente.
Cada fabricante decide cuantas de estas posibles prioridades implementar. Pueden ser de 3 bits o 4 bits siendo las prioridades mas altas las de menor numero (0 la mas alta y 7, 15 o 255 la mas baja).
Las interrupciones pueden ser habilitadas o deshabilitadas mediante modificaciones especificas al firmware.
Por ejemplo, el systick suele tener una de las prioridades mas bajas fuera de alguna interrupción por falla ya que es necesario para la implementación de RTOS.

14. ¿Qué es el CMSIS? ¿Qué función cumple? ¿Quién lo provee? ¿Qué ventajas aporta?

Cortex Microcontroller Software Interface Standard es una estandarización de ARM apuntada a reducir costos y tiempos de produccion.
Es un standard que se independiza de los vendedores de silicio para generar una capa de abstracción sobre  el hardware de los Cortex-M. Esto lo provee ARM junto con la comunidad y los vendedores.
Algunos de las standards son diferentes controles de periféricos como puede ser el NVIC, el SysTick o el MPU y también algunos registros programables del Bloque de Control.
Algunas de las funciones del microcontrolador no es posible acceder las mediante C puro ya que requieren el uso de assembly o modificaciones al toolchain. El CMSIS provee diferentes funciones para poder modificarlas.
Las principales ventajas del CMSIS es el proveer una API con llamadas estandarizadas abstrayendo en parte del hardware especifico de cada microcontrolador lo cual reduce mucho el tiempo de desarrollo de aplicaciones y esto se ve impactado en la cantidad de productos que pueden utilizar una solución de Cortex y en el precio final de los mismos. También es central la posibilidad de reutilizar código en diferentes proyectos que tengan en común el uso de un Cortex-M. La generación de drivers independientes del toolchain ya que si son compatibles con CMSIS garantiza la independencia de toolchains especificas.

15. Cuando ocurre una interrupción, asumiendo que está habilitada ¿Cómo opera el microprocesador para atender a la subrutina correspondiente? Explique con un ejemplo

Una vez que se de una excepción y el procesador la acepte se producen 2 acciones:
Primero se guarda el estado actual del procesador (valores de los registros, del stack actual, PC, Bloque de control, etc.) en el stack para que una vez que la excepción termine el procesador vuelva al mismo lugar donde se había quedado
Segundo se busca en el NVIC el vector a la interrupción que se produjo para conseguir la dirección de las instrucciones del mismo.

![Interrupción](/Figuras/Interrupt.png)

El stack que se usa para el stacking puede ser el PSP o el MSP pero una vez que entra en la interrupción al estar usando modo Handler si o si se va a utilizar el MSP. Por ende cualquier interrupción que se anide en el vector a partir de la primera va a ser en el MSP.

![Interrupción anidada](/Figuras/NestedInterrupt.png)

17. ¿Cómo cambia la operación de stacking al utilizar la unidad de punto flotante?

Debido a que la unidad de punto flotante posee 32 registros de 32 bits cada uno que pueden estar separados o agrupados en 16 double word el proceso del stacking se vuelve mucho mas largo.
Una solución a esto es la utilizacion del *lazy stacking* en el cual se va a leer el estado de diferentes bits en el registro de CONTROL para saber si es necesario guardar el estado de estos registros o no cuando se produzca un stacking. Esto esta activado por defecto y no es necesario ningún manejo de registros durante el handler exception debido a que el hardware propio se encarga.
Ej:
Si el bit FPCA del registro CONTROL indica si el contexto actual esta utilizando una operación de punto flotante o no (1 cuando la ejecuta y 0 cuando no).  

18. Explique las características avanzadas de atención a interrupciones: tail chaining y late arrival.

Si se produce una excepción y el procesador ya se encuentra procesando una de la misma o mayor prioridad esta nueva excepción entra en un estado pendiente. Cuando el procesador termine la excepción actual en vez de volver a cargar todos los registros y el estado del programa pre excepción para volver a cargarlos al stack para atender la nueva interrupción este va a saltar directamente al exception handler de ella. Esto ahorra mucho tiempo de proceso y se conoce como **tail chaining**

![Tail Chaining](/Figuras/TailChaining.png)

En cambio si durante la acción del stacking el procesador recibe una excepción de mayor prioridad este va a continuar con el stacking pero va a buscar el Exception Handler de la segunda excepción sin tener que guardar el stack de la primer excepción. Esto ahorra tiempo y espacio del stack. Esto es conocido como **late arrival.**

![Late Arrival](/Figuras/LateArrival.png)

19. ¿Qué es el systick? ¿Por qué puede afirmarse que su implementación favorece la portabilidad de los sistemas operativos embebidos?

El SysTick es un timer integrado directamente en los Cortex-M que ya esta integrado en el NVIC que puede tomar como referencia el clock del sistema o un externo. Para la implementación de un OS es necesario la implementación de un sistema de timings que el kernel pueda invocar regularmente. También tiene como medida de seguridad que solo se puede desactivar si se esta corriendo en handler mode (El procesador esta diseñado así)
Todos los Cortex-M cuentan con este timer por ende un OS escrito en cualquier Cortex-M4 puede ser porteado a otro Cortex-M4 sin mayor dificulta favoreciendo la portabilidad de OSs.

20. ¿Qué funciones cumple la unidad de protección de memoria (MPU)?

La MPU es un periférico opcional que esta puede estar presente en los Cortex-M4. Su principal función es definir niveles de permiso de acceso a memoria (Acceso Completo o Acesso Privilegiado Unicamente) a distintos sectores de la memoria (Cortex-M4 soporta hasta 8 regiones programables con diferentes espacios, direcciones y configuraciones).
Una de las funciones es evitar que diferentes aplicaciones puedan corromper memoria o stack utilizado por otros programas o el propio OS. Si la aplicación falla, la única que falla va a ser ella y no va a llevarse consigo a todo el sistema.
También previene que se cualquier aplicación pueda acceder a distintos periféricos que pueden ser críticos o generar problemas de seguridad. Puede desactivar la ejecución de código de zonas de memoria no permitida como la RAM
Si se produciera un acceso no autorizado pueden ocurrir una de dos excepciones de alta prioridad (MemManage o HardFault)

21. ¿Cuántas regiones pueden configurarse como máximo? ¿Qué ocurre en caso de haber solapamientos de las regiones? ¿Qué ocurre con las zonas de memoria no cubiertas por las regiones definidas?

La MPU puede definir hasta 8 regiones de memoria cada una con diferente tamaño, direcciones de inicio y configuraciones especificas.
Si el Bit PRIVDEFENA esta en 0 y el MPU esta activado toda memoria que no se encuentre en una de las 8 posibles regiones definidas en el MPU va a generar un fallo. Todas estas regiones no excluidas de los 8 espacios se los conoce como background region.

![Mapa de memoria protegido](/Figuras/ProteccionMPU.png)

22. ¿Para qué se suele utilizar la excepción PendSV? ¿Cómo se relaciona su uso con el resto de las excepciones? Dé un ejemplo

Pended Service Call es una excepción que se pone en estado pendiente escribiendo al ICSR. Al no ser precisa esta puede ser activada por una excepción de mayor prioridad y no va a ser ejecutada hasta que esta termine. Debido a este comportamiento podemos poner en la queue esta tarea hasta que todas las tareas de mayor prioridad fueran cubiertas mientras la configuremos con la menor prioridad.
Ej:
Si una ISR A tiene una parte que es muy dependiente del tiempo y una parte que no lo es se puede setear la mayor prioridad a la excepción A y en algún momento de la misma activar el estatus del PendSV. Una vez que termine la sección time dependant y si no hay ninguna excepción de mayor prioridad se va a empezar a ejecutar el PendSV antes de volver a la aplicación principal. Esto nos dejaría atender cualquier otra excepción que surja en el medio de esta segunda parte no Time dependant. Cuando termine el PendSV se puede volver a la ejecución del código normal.

![Uso del PendSV](/Figuras/PendSV.png)

23. ¿Para qué se suele utilizar la excepción SVC? Explique lo dentro de un marco de un sistema operativo embebido.

SuperVisorCall es una excepción que tiene un comportamiento diferente a otras interrupciones. En una interrupción común pueden pasar varias instrucciones entre que el estado de pendiente y la ejecución de la misma se efectué. En cambio el SVC tiene que correr el handler correspondiente apenas esta excepción es llamada. Debido a esto es útil dentro de un OS ya que nos puede abstraer de la capa de hardware ya que nuestra aplicación llama a un SVC para un recurso el cual no tiene acceso y el OS se encarga (previamente programado en otra tarea) de proveer lo necesario a la aplicación para correr. También puede usarse para generar cambios de contexto cuando la tarea tiene que esperar a algún periférico o dato por su naturaleza de inmediata

#### ISA

1. ¿Qué son los sufijos y para qué se los utiliza? Dé un ejemplo

Los sufijos de tamaño se utilizan para que el procesador sepa como operar con el dato que esta obteniendo de la memoria. Si tratarlo como un byte signado o no signado (sb y b respectivamente) o como un halfword signado o no signado (sh y h respectivamente). Si se obvia se va a tratar como un word

Ej:
`LDRH R1, [R0]`

Trae de la dirección en R0 el valor y lo ubica en R1. Trata el valor como sin signo por ende completa el registro de 32 bits con 0s 

2. ¿Para qué se utiliza el sufijo ‘s’? Dé un ejemplo

El sufijo s se utiliza para cuando se necesita que una operación actualice los flags del procesador. Por defecto las operaciones no lo hacen.

Ej:
`ADDS R1, R2`

Si la suma anterior provocara un carry, esta instrucción actualizaría la flag de carry del procesador.

3. ¿Qué utilidad tiene la implementación de instrucciones de aritmética saturada? Dé un ejemplo con operaciones con datos de 8 bits.

Debido a la naturaleza de la aritmética binaria, si una operación supera la cantidad de bits con la cual se representa el numero sufriría un roll over si no es signado (volver a empezar a contar desde 0) o un desbordamiento si fuera un numero signado ( se vuelve negativo con el menor numero posible)

Para evitar esto es posible implementar aritmética saturada. Esto hace que si el numero supero los bits que esta manejando este quedaría con el mayor o menor numero posible dependiendo de si es signado o no.

Ej:
Sin signar  
255   0b 11111111  
1  +  0b 00000001  
256   0b100000000  ->	0    0b00000000  

Signado  
127   0b 01111111  
1  +  0b 00000001  
-128  0b 10000000  ->	-128 0b10000000  
  
Aritmética saturada sin signar  
255   0b 11111111  
1  +  0b 00000001  
255   0b 11111111  ->	255  0b11111111  

Aritmética saturada signada  
127   0b 01111111  
1  +  0b 00000001  
127   0b 01111111  ->	127  0b01111111  


4. Describa brevemente la interfaz entre assembler y C ¿Cómo se reciben los argumentos de las funciones? ¿Cómo se devuelve el resultado? ¿Qué registros deben guardarse en la pila antes de ser modificados?

Los primeros 4 argumentos de una función se reciben directamente en los registros R0, R1, R2 y R3 respectivamente. Aun cuando la función no tenga tantos parámetros estos registros son automáticamente guardados antes del llamado de la función por lo cual podemos usarlos sin ningún problema.

Si la función devuelve un valor este tiene que ser mediante el registro R0.

Si queremos utilizar los registros superiores a R3 debemos guardarlos en la pila antes de utilizarlos y debemos volver a traer sus valores una vez que terminemos de operar y antes del retorno de la función.

5. ¿Qué es una instrucción SIMD? ¿En qué se aplican y que ventajas reporta su uso? Dé un ejemplo

Una instrucción SIMD (Single Instrucction Multiple Data) es una instrucción creada para procesar los registros como si contuvieran múltiples valores distintos. Estos múltiples valores pueden ser dos valores de 16 bits o 4 de 8 bits.
Su aplicación nos deja procesar mucha mas información de manera mucho mas eficiente en una menor cantidad de ciclos de reloj y con muchas menos lineas de código.

Ej:

`SHADD16 R0, R1`		Hace la suma signada de 2 valores de 16 bits y divide el resultado por 2

|R0 | 50 |100 | Valor original de R0  |
|:---:|:---:|:---:|:---|
|R1 | 40 | 60 | Valor original de R1  |
|+  | 90 |160 | Suma de R0 + R1 |
|/  | 45 | 80 | Divide cada uno de los resultado por 2  |
|R0 | 45 | 80 | Valor final de R0 | 
