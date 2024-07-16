
//NOTA: si hay cosas raras, es por falta de optimizacion y tiempo
.data
/* Definicion de datos */

aciertosR: .byte 0
DecisionReplay: .ascii " " //Se guardara la decision de jugar del usuario

VidasInit: .byte 7
//aciertosR: .byte 0 // Los aciertos "Reales" para controlar si llego a los 15 y gano la partida
replay: .ascii "Si desea jugar denuevo, presione 's', de lo contrario cualquier otra letra: "
LongReplay = . -replay

perder: .ascii "HAZ PERDIDO!!\n"
LongPerder = . -perder

ganar: .ascii "GANADOR!!\n"
LongGanador = . - ganar

//Tablero
board: .asciz "\n+------------------------------------------------+\n|               ***  GRUPO 17  ***               |\n+------------------------------------------------+\n|           |****************************|\n|           |*** ? * ? * ? * ? * ? * ? **|\n|           |****************************|\n|           |*** ? * ? * ? * ? * ? * ? **|\n|           |****************************|\n|           |*** ? * ? * ? * ? * ? * ? **|\n|           |****************************|\n|           |*** ? * ? * ? * ? * ? * ? **|\n|           |****************************|\n|           |*** ? * ? * ? * ? * ? * ? **|\n|           |****************************|\n+------------------------------------------------+\n|    Aciertos: 0                  Vidas: 7           |\n+------------------------------------------------+\n"
longitud = . - board

relleno: .word 0 // Para evitar errores con las couples

// 5 filas y  7 columnas
couples: .ascii "AABBCC\nDDEEFF\nGGHHII\nJJKKLL\nMMNNOO\n" // size 35

vidas: .byte 7

valorx: .asciz " " // Se guardara el valor x que ingresa el usuario

aciertosInit: .byte 0x0 // Los aciertos iniciales del jugador

valory: .asciz " "
condicion: .word 0
ingresar: .ascii "Ingrese un valor x: "
size = . - ingresar

aciertos2: .byte 0 // los aciertos para manipular el board
exception: .asciz "RuntimeException: los valores no son validos\n"
size3 = . - exception

ingresar2: .ascii "Ingrese un valor y: "
size2 = . - ingresar


//aciertosR: .byte 0 // los aciertos reales

//vidasInit: .byte 7


.text
boardF:
	.fnstart

	push {lr}

	mov r7, #4 // write instruction
	mov r0, #1 //  r0 <-- 1 stdout (screen)

	ldr r1, =board // r1 <-- message address
	mov r2, #longitud // cargar la longitud del ascii

	swi 0
	pop {lr}

	bx lr
	.fnend



pedirX:

	.fnstart
	push {lr}

	bl print // llamo al mensaje para que imprima x
	mov r7, #3
	mov r0, #0

	ldr r1, =valorx
	mov r2, #255
	swi 0

	pop {lr}
	bx lr
	.fnend

pedirY:

	.fnstart
	push {lr}

	bl print2

	eor r1, r1
	eor r2, r2
	mov r7, #3
	mov r0,#0
	ldr r1, =valory
	mov r2, #255
	swi 0

	pop {lr}
	bx lr
	.fnend

//Muestra al usuario el mensaje para que ingrese un valor numerico.
print:


	.fnstart
	mov r7, #4
	mov r0, #1
	ldr r1, =ingresar
	ldr r2, =size
	swi 0
	bx lr
	.fnend

print2:

	.fnstart
	push {lr}

	mov r7, #4
	mov r0, #1
	ldr r1, =ingresar2
	ldr r2, =size2
	swi 0

	pop {lr}
	bx lr
	.fnend

esValorValido:

	.fnstart

	push {lr}
	//r1 x y r2 y

	// x no es valido
	cmp r1, #0x30 // comparar x con 0x30 '0'
	blcc ThrowException

	adds r3, #1
	cmp r1, #0x34 //comparar x con 0x34 '4'
	blhi ThrowException

	eor r3, r3
	adds r3, #1 // limpiar los flags

	// y no es valido
	cmp r2, #0x30
	blcc ThrowException

	adds r3, #1 //actualizar de nuevo los flags
	cmp r2, #0x35

	blhi ThrowException // si es mas grande...
	eor r3, r3 // libero r3 para que se use en otro lado

	bl UnaCifra // Detecta si x o y es de una cifra
	pop {lr}
	bx lr
	.fnend

UnaCifra: // Detecta si el usuario ingresa un caracter de una sola cifra

	.fnstart

	push {r1}
	push {r3}
	push {r4}

	//Analizando x
	eor r4, r4 // Sera el #offset
	ldr r1, =valorx

	detect:

		add r4, #1
		ldrb r3, [r1, r4]
		cmp r3, #'\n'
		bne detect


	adds r4, #1
	sub r4, #1

	cmp r4, #1
	bhi ThrowException

	pop {r4}
	pop {r3}
	pop {r1}

	eor r4, r4

	push {r1}
	push {r3}

	ldr r1, =valory

	//Analizando y
	detect2:

		add r4, #1
		ldrb r3, [r1, r4] // Cargo el caracter en r3

		cmp r3, #'\n'
		bne detect2

	adds r4, #1
	sub r4, #1

	cmp r4, #1
	bhi ThrowException // Si hay mas de un caracter lanzo excepcion

	pop {r3}
	pop {r1}

	eor r4, r4
	bx lr // En efecto, es un valor valido :)
	.fnend

ThrowException:

	.fnstart

	mov r7, #4
	mov r0, #1

	ldr r1, =exception
	ldr r2, =size3

	swi 0
	bal end

	.fnend

analizarValor:

	.fnstart

	push {lr}

	eor r1, r1
	eor r2, r2
	eor r3, r3

	ldr r1, =valorx // fila
	ldr r2, =valory // columna

	ldrb r1, [r1] // cargo el ascii del valor ingresado por el usuario
	ldrb r2, [r2] // en particular cargo el caracter que es un byte

	bl esValorValido
	ldr r3, =couples // lista con las parejas de letras

	sub r1, #0x30 // convertir de ascii a decimal
	sub r2, #0x30

	eor r4, r4
	eor r5, r5 // r5 sera nuestro calculo para la posicion de el caracter

	mov r4, #7 //la cantidad de caracteres es 7

	mul r5, r1, r4 //fila * cantidad de elementos
	add r5, r2 // le suma al resultado la columna


	eor r6, r6
	ldrb r6, [r3, r5] // cargar el ascii en r6
	bl voltear

	pop {lr}
	bx lr

	.fnend


voltear:

	.fnstart

	push {lr}
	eor r7, r7 //limpiamos r7
	ldr r7, =board //cargo el board en r7

	mov r4, #6 // colocamos la cantidad de elementos 6
	eor r5, r5 //limpiamos r5

	mul r5, r1, r4 // mult cantidad de filas por numero de elementos
	add r5, r2 // le sumamos el numero de columna

	//mov r8, #100 // #offset de 100 pasa saltear lo de GRUPO 17
	eor r8, r8
	mov r8, #100
	eor r10, r10 // r10 sera mi counter para comparar con r5

	loop:

		ldrb  r9, [r7, r8] //cargamos el byte en r9
		//add r8, #1 // le sumamos uno al #offset

		cmp r9, #'?' // detectamos si es un ?
		add r8, #1

		blne esLetra // tambien voy a comprobar si es una letra
		bne loop // si no es  igual a ? 
		bl esValor
		//cmp r5, r10 //si es ? comparamos la posicion y r10
		//bleq intercambiar
		//add r10, #1 // le sumamos 1 a r10
		bne loop

	pop {lr}
	bx lr


	.fnend


esValor:

	push {lr}

	cmp r5, r10 // r5 = posicion que quiere voltear,  comparo la poscicion con r10
	bleq intercambiar

	add r10, #1

	pop {lr}

	bx lr

esLetra:

	.fnstart
	push {lr}

	cmp r9, #0x41 // comparo el caracter con 'A'
	bcs es //Si es mas grande o igual...
	b fin

	es:
		cmp r9, #0x5a //comparar con
		blcc esValor

	fin:
		pop {lr}
		cmp r9, #'?' // comparo denuevo para hacer el bne
		bx lr

	.fnend

intercambiar:

	.fnstart


	push {lr}

	sub r8, #1


	ldrb r9, [r7, r8] // Tenemos que analizar si en esa posicion ya hay una letra
	cmp r6, r9 // Si la hay lanzamos excepcion
	beq ThrowException

	strb r6, [r7, r8] // cargo el byte en board y posicion r8

	pop {lr}

	// Decision de diseño: activo el flag Z para que al volver a la subrutina no aplique
	// el bne loop
	mov r0, #0
	cmp r0, #0
	eor r0, r0

	bx lr
	.fnend


quitarVidas:

	.fnstart

	push {lr}

	eor r5, r5 // limpiamos r5 para que sea el #offset
	eor r4, r4 // sera el byte dentro de mi for
	eor r6, r6 // es la cantidad anterior de vidas del usuario en ascii

	ldr r1, =board
	ldr r2, =vidas

	ldrb r3, [r2] // cargo en r3 el valor de las vidas

	//operar


	sub r3, #1 //le quito una vida al usuario
	strb r3, [r2] // almacenar las nuevas vidas en la variable

	add r3, #0x30 // transforma a ascii el valor numerico
	mov r6, r3
	add r6, #1 //la cantidad de vidas anterior del usuario en ascii

	//cambiar el valor en el board
	for:


		//r1 = board y r5 = #offset
		ldrb r4, [r1, r5] //cargo el byte del valor ascii
		add r5, #1 // le sumo uno al contador

		cmp r4, #'d' // necesito comparar con la cantidad de vidas
		bne for

	forEach: // Nombres declarativos

		ldrb r4, [r1, r5] // sigo cargando el byte en r4
		add r5, #1 // le sumo 1 al #offset
		cmp r4, r6 //necesito comparar con la cantidad de vidas

		bne forEach
		beq change
	change:

		// r3 es el valor que le quiero ponen
		sub r5, #1 // le resto 1 para que no se pase
		strb r3, [r1, r5] // cargamos el valor en el board 

	bl devolverEstado

	pop {lr}

	eor r5, r5
	adds r5, #1 // limpiar los flags
	bx lr



	.fnend


devolverEstado:

	push {lr}
	// r8 me queda el #offset del segundo ascii
	// r11 tengo el backup del primero
	eor r3, r3 // limpiamos r3
	mov r3, #'?'
	strb r3,[r1, r8]
	strb r3, [r1, r11]

	pop {lr}
	bx lr



comprobarLetras:

	.fnstart

	push {lr}
	push {r6} // mando a guardar la letra volteada del usuario, en este caso el par 1

	cmp r6,r12 // comparo el par de letras
	blne quitarVidas // saltar a acertar si no son iguales
	bleq sumarPuntos // si son la misma sumo puntaje

	pop {r6}

	pop {lr}
	bx lr


	.fnend



sumarPuntos:

	.fnstart

	eor r1, r1
	eor r0, r0

	//voy a modificar la variable aciertos real, para que sepa si acabar el juego o no
	push {r0}
	push {r1}


	ldr r1, =aciertosR // La variable aciertos que controla si termina la partida o no
	ldrb r0, [r1]
	add r0, #1
	strb r0, [r1]

	pop {r1}
	pop {r0}


	push {lr}
	ldr r1, =board //cargar el board
	ldr r2, =aciertos2 // cargamos los aciertos en r2

	eor r4, r4 // limpiamos r4 que sera el #offset
	eor r5, r5 // en r5 cargaremos el byte

	eor r6, r6 // r6 sera donde
	mov r4, #100 //r4 = #offset empezamos desde el 100 para evitar errores

	ldrb r3, [r2] // cargo los aciertos para modificarlos
	add r3, #1 // le doy un punto al usuario

	strb r3, [r2] // y lo vuelvo a almacenar en esa direccion de memoria


	add r3, #0x30 //le sumamos para que se transforme en ascii 
	mov r6, r3
	sub r6, #1 // para que sea el valor anterior

	cmp r6, #0x39
	beq DosCifras

	I: //ITERATOR - r3 es el nuevo valor

		add r4, #1
		ldrb r5, [r1, r4]

		bl es11 // vamos a verificar si es 11 para evitar errores

		cmp r5, r6 //comparar el byte con el ascii
		bne I
		beq exchange

	DosCifras:

		// Hay un '9' en el tablero y 0xa en aciertos asi que hago cambios...

		add r4, #1 // #offset
		ldrb r5, [r1, r4] // cargo el ascii en r5

		cmp r5, r6
		bne DosCifras // si no es el valor vuelvo a I2

		//sub r4, #1 // le resto uno al #offset

		eor r0, r0
		mov r0, #0x31 // es el '1' en ascii

		strb r0, [r1, r4]
		add r4, #1

		//tema poner los aciertos a 0

		eor r0, r0
		mov r0, #0 //es el 0 decimal
		strb r0, [r2]

		ldrb r3, [r2]
		add r3, #0x30


	exchange:

		//add r3, #1 //obtengo el valor original
		//sub r4, #1

		//cmp r3, #0x9
		bl colocarPuntos
		//strb r3, [r1, r4]

	pop {lr}
	bx lr

	.fnend


es11: 

	.fnstart

	ldrb r5, [r1, r4] // cargo el siguiente
	cmp r5, #'1'

	bxne lr

	//si es 1 hay que verifiar el siguiente

	add r4, #1
	ldrb r5, [r1, r4]
	cmp r5, #'1' // si el siguiente es 1

	bne noes
	bx lr // el siguiente es 1 y lo modifico

	noes: // caso 1 digito

		sub r4, #1
		ldrb r5, [r1, r4] // recargo el valor anterior y que el programa prosiga
		bx lr



	.fnend

colocarPuntos:

	push {lr}

	strb r3, [r1, r4]
	pop {lr}
	bx lr


//Muestra el mensaje de derrota al usuario
derrota:

	.fnstart

	push {lr}

	mov r7, #4
	mov r0, #1

	ldr r1, =perder
	ldr r2, =LongPerder

	swi 0
	pop {lr}
	bx lr
	.fnend

victoria:

	.fnstart

	push {lr}

	mov r7, #4
	mov r0, #1

	ldr r1, =ganar
	ldr r2, =LongGanador

	swi 0
	pop {lr}
	bx lr

	.fnend


//Vamos a preguntarle al usuario si quiere jugar denuevo
playAgain:

	.fnstart

	push {lr}

	bl msjAgain
	bl decision

	ldr r5, =DecisionReplay
	ldrb r10, [r5] // cargamos la decision del usuario en r10

	pop {lr}
	bx lr

	.fnend


msjAgain:

	.fnstart


	push {lr}

	mov r4, #7
	mov r0, #1

	ldr r1, =replay
	ldr r2, =LongReplay

	swi 0
	pop {lr}
	bx lr

	.fnend

decision:

	// Le vamos a pedir al usuario que ingrese 's' si quiere jugar
	// denuevo una partida
	.fnstart

	push {lr}
	mov r7, #3
	mov r0, #0

	ldr r1, =DecisionReplay
	mov r2, #255

	swi 0
	pop {lr}
	bx lr
	.fnend

LimpiarTablero:

	.fnstart

	eor r2, r2 // en r2 cargaremos cada ascii

	eor r1, r1 // en r1 estara la direccion de memoria del tablero
	ldr r1, =board //cargamos el board en r1

	eor r4, r4
	mov r4, #200 // Para evitar errores de comparacion



	RestablecerLetras:

		push {lr}

		add r4, #1 // #Offset
		ldrb r2, [r1, r4]

		bl estadoOriginal

		eor r0, r0
		adds r0, #1

		cmp r2, #'+' // si es '+'

		pop {lr}
		bne RestablecerLetras


	avanzar:

		add r4, #1
		ldrb r2, [r1, r4]


		cmp r2, #'V'
		bne avanzar


	//Vamos a colocar las vidas de nuevo a 7

	ldr r3, =vidas
	//ldr r10, =vidasInit

	mov r9, #0x7

	strb r9, [r3]
	add r9, #0x30
	eor r10, r10

	RestablecerVidas:

		push {lr}

		add r4, #1
		ldrb r2, [r1, r4]

		bl rVidas

		pop {lr}

		cmp r2, #'+'
		bne RestablecerVidas

	eor r4, r4
	mov r4, #200

	eor r3, r3
	eor r5, r5

	ldr r3, =aciertosR // cargo la direccion de memoria de los aciertos
	ldrb r5, [r3]

	mov r10, r5 // vamos a hacer backup de los aciertos anteriores del usuario

	sub r5, r5
	strb r5, [r3]

	ldr r3, =aciertos2 //aciertos para manipular el tablero
	ldrb r5, [r3]

	sub r5, r5
	strb r5, [r3]

	mov r0, #0
	adds r0, #1

	cmp r10, #0xa // si tiene al menos 10 aciertos
	bcc loopi //unsigned lower


	casoEspecial: // Caso en el cual el usuario tiene 10 o mas aciertos

		add r4, #1
		ldrb r2,[r1, r4]

		cmp r2, #0x31 //vemos si es un uno
		bne casoEspecial

	modyfier:

		mov r0, #'0'
		strb r0, [r1, r4] //cambio lo que esta por un vacio

		mov r0, #0x20
		add r4, #1
		strb r0, [r1, r4] // le ponemos 0 a los aciertos de nuevo
		b terminar

	loopi: //caso en el que el usuario tiene menos de 10 vidas

		add r4, #1
		ldrb r2, [r1, r4]

		cmp r2, #0x30
		bcs prueba

		cmp r2, #'V' // cortar la ejecucion para evitar errores de segmentacion
		mov r0, #0
		adds r0, #1
		bne loopi

		prueba: //Analizar si es un numero

			mov r0, #0
			adds r0, #1

			cmp r2, #0x39
			bls ch

			cmp r2, #'V'
			bne loopi

		ch: // si encuentra el valor realiza el intercambio

			mov r0, #0
			add r0, #0x30
			strb r0, [r1, r4]



	terminar:

		// Limpieza de todos los registros para evitar errores
		eor r0, r0
		eor r2, r2
		eor r4, r4

		eor r1, r1
		eor r9, r9

		eor r5, r5
		eor r6, r6
		eor r4, r4

		eor r10, r10
		eor r11, r11
		eor r12, r12

		bx lr

	.fnend

rVidas:

	.fnstart

	cmp r2, #0x30
	bcs ck
	bx lr

	ck:

		mov r0, #0
		adds r0, #1
		cmp r2, #0x39
		bls mod
		bx lr

	mod:

		strb r9, [r1, r4]
		eor r9, r9

		bx lr

	.fnend



estadoOriginal:

	.fnstart



	eor r0, r0

	cmp r2, #'Z'
	bls verificar

	b finale

	verificar:

		adds r0, #1
		cmp r2, #'A'
		bcs del
		b finale

	del:

		mov r5, #'?'
		strb r5,[r1, r4]


	finale:

		bx lr

	.fnend


.global main
main:


	eor r12, r12 // limpiamos r12 que sera la primera letra volteada
	eor r9, r9 // r9 sera nuestro contador de vidas
	eor r1, r1 // voy a poner los aciertos aqui
	eor r6, r6 //sera la primera volteada
	eor r8, r8 //la posicion de la primera volteada

	// limpiar los demas registros para evitar errores
	eor r4, r4
	eor r5, r5
	eor r7, r7

	eor r8, r8
	eor r0, r0
	while:
		ldr r9, =vidas // cargar la direccion de memoria de vidas y aciertos
		ldr r1, =aciertosR

		push {r1} // Como usamos r1 y r9 multiples veces en subrutinas lo popeamos
		push {r9}

		// esto es una jugada
		bl boardF

		bl pedirX // le pedimos el valor en x al usuario
		bl pedirY

		bl analizarValor
		mov r12, r6 // aca guardo en r12 la primera letra volteada
		mov r11, r8 // me guardo el #off set de la primera volteada
		bl boardF

		bl pedirX
		bl pedirY


		bl analizarValor
		bl boardF
		bl comprobarLetras


		pop {r9}
		pop {r1}

		// Vamos a analizar si gana el juego o lo pierde
		ldrb r9, [r9]
		ldrb r1, [r1]

		//Condicion gana el juego llego a 15 aciertos
		cmp r1, #0xf
		beq ganador

		// Condicion pierde el juego se quedo sin vidas
		cmp r9, #0
		beq perdida
		bne while


	ganador:
		bl boardF
		bl victoria

		b JugarDenuevo // Decision de diseño: si gana puede jugar denuevo
		//bal end
	perdida:
		bl boardF
		bl derrota

	JugarDenuevo:

		eor r5, r5
		eor r10, r10
		bl playAgain

		cmp r10, #0x73 // la 's' en ascii
		eor r5, r5
		eor r10, r10

		bne end

		bl LimpiarTablero // Debemos limpiar el tablero para la nueva partida
		b main

end:
	mov r7, #1
	swi 0


