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
@   void productoEscalar12(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar);
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
		    movw r5, #1023
		    ldrh r4, [r0]          	@ Asigna a r4 el valor en la dirección r0.
		    mul r4, r4, r3        	@ Multiplica el valor en r4 por el valor en r3 y lo guarda en r4
		    subs r5, r5, r4			@ Resto el valor en r5 el valor en r5 y lo guardo en r5 y actualizo los flags de estado del procesador
		    ITTE MI
		    movwmi r5, #1023		@ Si el flag de negativo es 1, guardo el valor #1023 en r5
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
@   void filtroVentana10(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitudVectorIn);
@
@ Parametros recibidos:
@   r0: Dirección de memoria de inicio del vector de entrada.
@   r1: Dirección de memoria de inicio del vector de salida.
@	r2: Longitud

.thumb_func               			@ Se avisa al emsablador que esta es una funcion
    asm_filtroVentana10:			@ Etiqueta/nombre de la función.
	    push {r4}					@ Muevo el valor de r4 al stack
      	pop {r4}					@ Traigo el valor de r4 de vuelta del stack
	    bx lr	                 	@ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   pack32to16(int32_t *vectorIn, int16_t *vectorOut, uint32_t longitud);
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
