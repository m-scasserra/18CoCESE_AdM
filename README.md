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

5. ¿Qué ventajas presenta el uso de los “shadowed pointers” del PSP y el MSP?

MSP: Main Stack Pointer es el stack pointer por defecto. Se utiliza en el modo Thread cuando el CONTROL bit[1] (SPSEL) es 0 y en el modo Handler se utiliza siempre.
PSP: Program Stack Pointer se utiliza en el Thread mode cuando el CONTROL bit[1] (SPSEL) es 1.

Si no utilizamos un OS podemos usar siempre el MSP e ignorar el PSP.
Si usamos un OS, el MSP es utilizado por el manejadores de excepciones mientras que el PSP es utilizado por las aplicaciones teniendo cada una un espacio propio del stack. El cambio de contexto del OS se encarga de cambiar el valor del PSP.

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

Los sufijos de tamaño se utilizan para que el procesador sepa como operar con el dato que esta obteniendo de la memoria. Si tratarlo como un byte signado o no signado (sb y b respectivamente) o como un halfword signado o no signado (sh y h respectivamente). Si se obvia se va a tratar como un word

Ej:
LDRH R1, [R0]

Trae de la dirección en R0 el valor y lo ubica en R1. Trata el valor como sin signo por ende completa el registro de 32 bits con 0s 

2. ¿Para qué se utiliza el sufijo ‘s’? Dé un ejemplo

El sufijo s se utiliza para cuando se necesita que una operación actualice los flags del procesador. Por defecto las operaciones no lo hacen.

Ej:
ADDS R1, R2

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

SHADD16 R0, R1		Hace la suma signada de 2 valores de 16 bits y divide el resultado por 2

R0  50	||	100  Valor original de R0  
R1  40	||	 60  Valor original de R1  
\+   90	||	160  Suma de R0 + R1  
/   45	||	 80  Divide cada uno de los resultado por 2  
___________________________
R0	45	||	 80  Valor final de R0  
