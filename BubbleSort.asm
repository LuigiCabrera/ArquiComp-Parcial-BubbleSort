.data
	lista: .word 2 , 0 , 3 , 6, 12 , 5, -5, 0, -3, 44 	# que define lista de valores a ordenar.
	size: .word 10						# cantidad de valores en la lista
	
	parray: .asciiz "\nOrigin Array:\n"
	psort: .asciiz "\n\nSorted Array (Decrease):\n"
	coma: .asciiz ", "

.macro print_str(%direction)
	la $a0, %direction
	li $v0, 4
	syscall
.end_macro

.macro index_dir(%index, %direction, %array_pointer)
	add %direction, %index, %index
	add %direction, %direction, %direction		# Cuatriplicar el indice para acceder al array con bytes
	add %direction, %direction, %array_pointer 	# GUARDA LA DIRECCION DE MEMORIA DEL ELEMENTYO A ACCEDER
.end_macro	
	
.text
.globl __start
__start:
	
	la $s1, lista	# PUNTERO A ARRAY EN $s1
	la $t0, size	# Carga direccio de Size
	lw $t0, 0($t0)	# $t0 = Numero de elementos
	
	print_str parray
	jal print_arr	# FUNCION QUE IMPRIME ARRAY
	
	jal BubbleSortDecrease
	
	print_str psort
	jal print_arr	# FUNCION QUE IMPRIME ARRAY
	
	li $v0,10
	syscall
	
BubbleSortDecrease: 	# FUNCION QUE ORDENA ARRAY DE FORMA DECRECIENTE
	
	addi $t3, $t0, -1 # Size de subarray - 1 (Recordar que el ultimo elemento siempre termina en su posicion)
	SortLoop:
		addiu $t1, $zero, 0 	# Indice = $t1 = 0
		
		SubArrayLoop: # (SEGUNDO FOR)
			
			index_dir $t1 $t2 $s1 	# Adquiere la direccion de memoria usando el indice y la direccion del array
			lw $s2, 0($t2) 	# Elemento index
			lw $s3, 4($t2)	# Elemento index+1
			
			# Verify if need to swap
			slt $s4, $s2, $s3
			beq $s4, $zero, NotSwap
			
			# SWAP
			sw $s2, 4($t2)
			sw $s3, 0($t2)
			
			NotSwap:
			addi $t1, $t1, 1		# Incrementa el indice en 1
			beq $t1, $t3, DoneSubArrayLoop	# Si indice == size de subarray - 1 Terminar SubArrayLoop
			j SubArrayLoop
			
		DoneSubArrayLoop:		
			addi $t3, $t3, -1 		# Subarray size se decrementa en 1
			beq $t3, $zero, DoneSortLoop	# If $t3 == 0: Acaba algoritmo
			j SortLoop
		
	DoneSortLoop:
		jr $ra
		
	
print_arr:	# FUNCION QUE IMPRIME ARRAY
	# $s1 = Direccion de memoria del array
	# $t0 = nuemro de elementos de array
	# Se usara auxiliarmente $t1 como indice, $t2 para almacenar direccion y $t3
	addiu $t1, $zero, 0	# $t1 = index = 0
				# $t2 = index (bytes)
	loop_print:
		index_dir $t1 $t2 $s1	# Adquiere la direccion de memoria usando el indice y la direccion del array
		lw $t3, 0($t2)		# Carga dato del array
	
		move $a0, $t3
		li $v0, 1
		syscall 		# Imprime elemento de array
	
		addi $t1, $t1, 1	 	# Sumar 1 a indice
		beq $t1, $t0, done_loop_print 	# Si el indice es igual al numero de elementos termina
	
		print_str coma 		# Imprime una coma y un espacio
	
		j loop_print
	
	done_loop_print:
		jr $ra
