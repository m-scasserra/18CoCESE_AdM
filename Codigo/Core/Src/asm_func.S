.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_filtroVentana10
.global asm_pack32to16
.global asm_max
.global asm_downsampleM
.global asm_invertir
.global asm_eco
#define MAX_SAT 4095

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_zeros (uint32_t * vector, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector
@   r1: longitud
.thumb_func               			@ Se avisa al emsablador que esta es una funcion
    asm_zeros:            			@ Etiqueta/nombre de la función.
        mov r2, 0         			@ r2 = 0 
		asm_zeros_bucle:			@ Etiqueta de comienzo de bucle.
		    str r2, [r0]          	@ Asigna 0 a la palabra en dirección r0.
    		add r0, 4             	@ Pasa a la siguiente palabra/elemento en vector.
	    	subs r1, 1            	@ Resta 1 a la cantidad de elementos y actualiza flags de estado del procesador. En particular, estamos interesados en el flag Z.
    		bne asm_zeros_bucle   	@ La instrucción se ejecuta mientras el resultado de r1 - 1 no sea cero (Z == 0).
    bx lr                 			@ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar32 (uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint32_t escalar)
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Dirección de memoria de inicio del vector de salida.
@	r2: Longitud
@	r3: Escalar

.thumb_func               			@ Se avisa al emsablador que esta es una funcion
    asm_productoEscalar32:			@ Etiqueta/nombre de la función.
    	push {r4}					@ Guardo el valor de r4 en el stack
        asm_escalar32_bucle:		@ Etiqueta de comienzo de bucle.
    		ldr r4, [r0]          	@ Asigna a r4 el valor en la dirección r0.
    		mul r4, r4, r3        	@ Multiplica el valor en r4 por el valor en r3 y lo guarda en r4
	    	str r4, [r1]		  	@ Guarda el valor de r4 en la direccion de r1
    		add r0, 4			  	@ Pasa a la siguiente palabra/elemento en vector de entrada
    		add r1, 4			  	@ Pasa a la siguiente palabra/elemento en vector de salida
	    	subs r2, 1            	@ Resta 1 a la cantidad de elementos y actualiza flags de estado del procesador. En particular, estamos interesados en el flag Z.
    		bne asm_escalar32_bucle @ La instrucción se ejecuta mientras el resultado de r1 - 1 no sea cero (Z == 0).
	    pop {r4}					@ Traigo el valor de r4 de vuelta del stack.
    	bx lr       	          	@ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar16(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar)
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Dirección de memoria de inicio del vector de salida.
@	r2: Longitud
@	r3: Escalar

.thumb_func               			@ Se avisa al emsablador que esta es una funcion
    asm_productoEscalar16:			@ Etiqueta/nombre de la función.
	    push {r4}					@ Muevo el valor de r4 al stack
        asm_escalar16_bucle:		@ Etiqueta de comienzo de bucle.
		    ldrh r4, [r0]          	@ Asigna a r4 el valor en la dirección r0.
		    mul r4, r4, r3        	@ Multiplica el valor en r4 por el valor en r3 y lo guarda en r4
		    strh r4, [r1]		  	@ Guarda el valor de r4 en la direccion de r1
    		add r0, 2			  	@ Pasa a la siguiente palabra/elemento en vector de entrada
    		add r1, 2			  	@ Pasa a la siguiente palabra/elemento en vector de salida
    		subs r2, 1            	@ Resta 1 a la cantidad de elementos y actualiza flags de estado del procesador. En particular, estamos interesados en el flag Z.
    		bne asm_escalar16_bucle @ La instrucción se ejecuta mientras el resultado de r1 - 1 no sea cero (Z == 0).
    	pop {r4}					@ Traigo el valor de r4 de vuelta del stack
	    bx lr	                 	@ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar12(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Dirección de memoria de inicio del vector de salida.
@	r2: Longitud
@	r3: Escalar

.thumb_func               			@ Se avisa al emsablador que esta es una funcion
    asm_productoEscalar12:			@ Etiqueta/nombre de la función.
	    push {r4,r5}				@ Muevo el valor de r4 al stack
        asm_escalar12_bucle:		@ Etiqueta de comienzo de bucle.
		    movw r5, MAX_SAT		@ Muevo el valor #4095 a r5
		    ldrh r4, [r0]          	@ Asigna a r4 el valor en la dirección r0.
		    mul r4, r4, r3        	@ Multiplica el valor en r4 por el valor en r3 y lo guarda en r4
		    subs r5, r5, r4			@ Resto el valor en r5 el valor en r5 y lo guardo en r5 y actualizo los flags de estado del procesador
		    ITTE MI
		    movwmi r5, #4095		@ Si el flag de negativo es 1, guardo el valor #4095 en r5
		    strhmi r5, [r1]			@ Si el flag de negativo es 1, guarda el valor de r5 en la direacion de r1
		    strhpl r4, [r1]		  	@ si el flag de negativo es 0 ,guarda el valor de r4 en la direccion de r1

    		add r0, 2			  	@ Pasa a la siguiente palabra/elemento en vector de entrada
    		add r1, 2			  	@ Pasa a la siguiente palabra/elemento en vector de salida
    		subs r2, 1            	@ Resta 1 a la cantidad de elementos y actualiza flags de estado del procesador. En particular, estamos interesados en el flag Z.
    		bne asm_escalar12_bucle @ La instrucción se ejecuta mientras el resultado de r1 - 1 no sea cero (Z == 0).
    	pop {r4,r5}					@ Traigo el valor de r4 de vuelta del stack
	    bx lr	                 	@ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_filtroVentana10(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitudVectorIn);
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Dirección de memoria de inicio del vector de salida.
@	r2: Longitud
@	r3: Indice para recorrer el vector
@	r4: Indice para el offset sobre la posicion
@	r5: Auxiliar para guardar valores
@	r6: Registro donde se guarda la suma total de los valores
@	r7: Auxiliar para calcular el offset
@	r8: Total de valores para la division

.thumb_func               			@ Se avisa al emsablador que esta es una funcion
    asm_filtroVentana10:			@ Etiqueta/nombre de la función.
	    push {r4, r5, r6, r7, r8}	@ Muevo el valor de r4, r5, r6, r7, r8 al stack
      	mov r3, #0					@ Guardo el valor #0 en r3
      	mov r6, #0					@ Guardo el valor #0 en r6
      	mov r7, #0					@ Guardo el valor #0 en r7
      	mov r8, #11					@ Guardo el valor #11 en r8
      	asm_filtroVentana10_bucle:	@ Etiqueta del bucle de recorrido del vector
      		mov r4, #1				@ Guardo el valor #1 en r4
      		asm_filtroVentana10_buclesuma:	@ Etiqueta del bucle de suma de elementos
	      		cmp r3, r4					@ Comparo el valor de r3 contra el de r4
	      		ITTTT PL					@ Ejeccucion condicional si el valor anterior es positivo
	      		rsbPL r4, #0				@ Invierto el valor en r4
	      		ldrhPL r5, [r0, r4, LSL 1]	@ Traigo de memoria de 16 bits a r5 el valor en la posicion r0 + r4 << 1
	      		addPL r6, r5				@ Sumo el valor de r5 a r6
	      		rsbPL r4, #0				@ Invierto el valor en r4

	      		add r7, r3, r4				@ Sumo el valor de r3 y r4 y lo guardo en r7
	      		cmp r7, r2					@ Comparo r7 con r2
	      		ITT MI						@ Ejeccion condicional si el valor anterior es negativo
	      		ldrhMI r5, [r0, r4, LSL 1]	@ Traigo de memoria de 16 bits a r5 el valor en la posicion r0 + r4 << 1
	      		addMI r6, r5				@ Sumo el valor de r6 al valor de r5

	      		add r4, #1					@ Sumo 1 a r4
	      		cmp r4, #6					@ Comparo r4 con #6
	      		bMI asm_filtroVentana10_buclesuma	@ Si eal resultado anterior es negativo salto a asm_filtroVentana10_buclesuma
	      	ldrh r4, [r1]					@ Cargo el valor de 16 bits de la posicion apuntada por r1 a r4
	      	add r6, r4						@ Sumo el valor de r4 a r6
	      	udiv r6, r6, r8					@ Hago la unsigned division de r6 por r8 y lo guardo en r6
	      	strh r6, [r1], #2				@ Guardo el valor de 16 bits de r6 en la direccion de r1 y le sumo #2 a r1
	      	mov r6, #0						@ Muevo el valor de #0 a r6
	      	add r0, #2						@ Sumo a r0 el valor #2
	      	add r3, #1						@ Sumo a r3 el valor #1
	      	cmp r3, r2						@ Comparo el valor de r3 contra r2
	      	bne asm_filtroVentana10_bucle	@ Si la comparacion da negativa salto a asm_filtroVentana10_bucle
      	pop {r4, r5, r6, r7, r8}			@ Traigo el valor de r4, r5, r6, r7, r8 de vuelta del stack
	    bx lr	                 	@ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asm_pack32to16(int32_t *vectorIn, int16_t *vectorOut, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Dirección de memoria de inicio del vector de salida.
@	r2: Longitud

.thumb_func               				@ Se avisa al emsablador que esta es una funcion
    asm_pack32to16:						@ Etiqueta/nombre de la función.
	    push {r4}						@ Muevo el valor de r4 al stack
	    asm_pack32to16_bucle: 			@ Etiqueta de comienzo del bucle
			ldr r4, [r0]				@ Cargo en r4 el valor de la direccion en r0
			lsr r4, r4, #16				@ Shifteo el valor en r4 16 veces a la derecha y lo ubico en r4
			strh r4, [r1]				@ Guardo el valor de 16 bits de r4 en la direccion en r1
			add r0, 4					@ Paso al siguiente elemento del vector de entrada
			add r1, 2					@ Paso al siguiente elemento del vector de salida
			subs r2, #1					@ Resta 1 a la cantidad de elementos y actualiza flags de estado del procesador. En particular, estamos interesados en el flag Z.
			bne asm_pack32to16_bucle	@ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.
		pop {r4}						@ Traigo el valor de r4 de vuelta del stack
	    bx lr	                 		@ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_max(int32_t *vectorIn, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Longitud
@	r2: Valor del elemento mas alto
@	r3: Indice del elemento mas alto
@	r4: Indice del valor que comparo con el mas alto
@	r5: Valor del elemento que comparo con el mas altos

.thumb_func
	asm_max:
		push {r4, r5}			@ Guardo en el stack los valores de r4 y r5
		ldr r2, [r0], #4		@ Cargo en r2 el valor en la direccion en r0 y le sumo 4 a la direccion
		mov r3, #0				@ Cargo en r3 el valor #0
		mov r4, #0				@ Cargo en r4 el valor #0
		sub r1, #1				@ Resto #1 al valor de r1
		cmp r1, #1				@ Comparo r1 con el valor #1 y actualizo los flags de estado
		beq asm_max_fin			@ Si r1 es igual a #1 salto al asm_max_fin
		asm_max_bucle:			@ Etiqueta de bucle
			ldr r5, [r0], #4	@ Cargo en r5 el valor den la direccion en r0 y le sumo 4 a la direccion
			add r4, #1			@ Le sumo #1 a r4 #1
			cmp r5, r2			@ Comparo r5 y r2 y actualizo los flags de estado
			ITT pl				@ Instrucciones condicionales si la comparacion me da negativa
			movpl r2, r5		@ Muevo a r2 el valor de r5
			movpl r3, r4		@ Muevo a r3 el valor de r4

			subs r1, #1			@ Resto #1 al valor en r1 y actualizo los flags de estado
			bne asm_max_bucle	@ Si el resultado de la operacion anterior no me da #0 salto a asm_max_bucle
	asm_max_fin:
		mov r0, r3				@ Muevo el valor de r3 y a r0
		pop {r4, r5}			@ Saco del stack los valores anteriores de r4 y r5
		bx lr					@ Vuelvo al programa principal

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_invertir(uint16_t *vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Longitud
@	r2: Indice del elemento alto
@	r3: Auxiliar para el elemento bajo
@	r4: Auxiliar para el elemento alto

.thumb_func
	asm_invertir:
		push {r4}						@ Muevo el valor de r4 al stack
		mov r2, r1						@ Copio el valor de r1 en r2
		sub r2, #1						@ Resto 1 al valor de r2
		lsr r1, 1						@ Shifteo logico a la izquierda el valor de r1 1 posicion

		asm_invertir_bucle:				@ Etiqueta de asm_invertir_bucle
			ldrh r3, [r0]				@ Cargo el valor de unsigned halfword apuntado por r0 en r3
			ldrh r4, [r0, r2, LSL 1]	@ Cargo el valor de unsigned halfword apuntado por r0 en r4, le sumo a r0 el valor de r2 shifteado logico 1 posicion a la izquierda
			strh r4, [r0]				@ Guardo el valor de unsigned halfword de r4 en la direccion apuntada por r0
			strh r3, [r0, r2, LSL 1]	@ Guardo el valor de unsigned halfword de r3 en la direccion apuntada por r0, le sumo a r0 el valor de r2 shifteado logico 1 posicion a la izquierda
			add r0, #2					@ Le sumo a r0 el valor #2
			sub r2, #2					@ Se resto a r2 el valor #2
			subs r1, #1					@ Le resto a r1 el valor de #1 y actualizo los flags del procesador
			bne asm_invertir_bucle		@ Si la anterior operacion no dio 0, salto a la etiqueta asm_invertir_bucle

		pop {r4}						@ Devuelvo el valor de r4 del stack
		bx lr							@ Vuelvo a la funcion

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_eco(int16_t *vectorIn, int16_t *vectorOut, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Dirección de memoria de inicio del vector de salida.
@	r2: Longitud
@	r3: Registro para el guardado de los elementos del vector
@	r4: Indice para recorrer el vector de entrada
@	r5: Auxliar para la division signada y para guardar el valor
@	r6: Registro para guardar la primer posicion del vector de entrada

.thumb_func
	asm_eco:
		push {r4, r5, r6}			@ Preservo los valores de los registros r4, r5, r6 moviendolos al stack
		mov r6, r0					@ Guardo el la posicion de memoria del inicio del vector de entrada
		mov r5, #882				@ Muevo el valor #882 al registro r5
		mov r4, #0					@ Muevo el valor #0 al registro r4
		asm_eco_primerbucle:		@ Etiqueta del primer bucle
			ldr r3, [r0], #4		@ Cargo de memoria los 2 datos signados de 16 bits de la posicion de r0 al registro r3 y le sumo 4 a r0
			str r3, [r1], #4		@ Guardo en memoria los 2 datos signados de 16 bits del registro r3 en la posicion de memoria apuntada por r1 y le sumo 4 a r1
			add r4, #2				@ Sumo 2 a r4
			cmp r4, r5				@ Comparo r4 con r5 y actualizo los flags del procesador
			bne asm_eco_primerbucle	@ Si la anterior operacion no dio 0 salto a la etiqueta asm_eco_primerbucle
		mov r5, #0					@ Muevo el valor #0 a r5
		asm_eco_segundobucle:		@ Etiqueta del segundo bucle
			ldr r3, [r6], #4		@ Cargo en r3 los 2 datos signados apuntados en r6 y le sumo a r6 el valor #4
			shadd16 r3, r3, r5		@ Hago la suma signada de 2 numeros de 16 bits entre r3 y r5 y divido los resultados por 2. Guardo el resultado en r3
			ldr r5, [r0], #4		@ Cargo en r5 los 2 datos signados apuntados en r0 y le sumo a r0 el valor #4
			sadd16 r3, r3, r5		@ Hago la suma signada de 2 numeros de 16 bits entre r3 y r5 y guardo el valor en r3
			mov r5, #0				@ Muevo el valor #0 a r5
			add r4, #2				@ Sumo 2 a r4
			str r3, [r1], #4		@ Guardo en memorio los 2 datos signados de 16 bits de r3 en la posicion de r1 y le sumo 4 a r1
			cmp r4, r2				@ Comparo r4 y r2 y actualizo los flags del procesador
			bne asm_eco_segundobucle@ si la anterior operacion no dio 0 salto a la etiqueta asm_eco_segundobucle
		pop {r4, r5, r6}			@ Retiro del stack los valores anterior de r4, r5 y r6
		bx lr						@ Vuelvo al programa principal
