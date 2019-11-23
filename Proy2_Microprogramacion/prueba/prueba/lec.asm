.386
.model flat, stdcall
option casemap:none

include ReadFile.inc
include \masm32\include\masm32rt.inc

.data
;definicion de datos
;---Dirección de archivo de lectura
FileName byte "test2.txt",0
;---Cadenas de impresión
ingreso db "Ingrese la palabra a buscar: ",0
noencontrado db "La palabra no se encuentra en el archivo. ",0
encontrado db "La palabra fue ingresada el ",0
;---Bandera de encontrado
bEncontrado db 0
;---Contador de fecha
fechan db 19

.data?
;---Cadena
buffer db 100 dup(?)
;---Variables temporales de la palabra y el archivo
temp dd ?
temp2 dd ?
;---Handler
hFile dd ?
;---Tamaño de archivo
Filesize dd ?
;---Buffer de Lectura
hMemory dd ?
BytesRead dd ?

.code
start:

	main proc
		

		;---Creación del handler para leer el archivo
		invoke CreateFile,addr FileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		mov hFile,eax
		cmp hFile, INVALID_HANDLE_VALUE
		jz code1

		;---Determinar el tamaño del archivo
		invoke GetFileSize,eax,0
		mov Filesize, eax
		inc eax
		
		invoke GlobalAlloc,GMEM_FIXED,eax
		mov hMemory, eax

		add eax, Filesize
		mov BYTE PTR [eax],0

		;---Lectura del Archivo
		invoke ReadFile,hFile,hMemory,Filesize,ADDR BytesRead,0
		invoke CloseHandle,hFile

		invoke StdOut, hMemory

		;---Ingreso de la palabra de búsqueda
		invoke StdOut, addr ingreso
		invoke StdIn,addr buffer,100
		
		call Buscar

		invoke GlobalFree,hMemory

		code1:
		invoke ExitProcess,0
		ret
	main endp

	Buscar proc
	    XOR esi, esi
		XOR edi, edi

		;---Mover a punteros		
		MOV edi, hMemory
		LEA esi, buffer

		;---Obteniendo primer caracter de la palabra y el archivo
		MOVZX eax, BYTE PTR [edi]
		MOV temp2, eax
		MOVZX ebx, BYTE PTR [esi]
		MOV temp, ebx

		;---Convierte a mayúsculas
		call EBXmayuscula
		call TEMP2mayuscula
		;---Compara si son iguales o diferentes
		CMP ebx, temp2
		JE iguales
		JNE diferentes

		diferentes:
		;---Se obtiene el siquiente caracter del archivo y se realiza de nuevo la comparación
		INC edi
		MOVZX eax, BYTE PTR [edi]
		CMP eax, 0
		JE evaluar
		call EAXmayuscula
		call TEMPmayuscula
		CMP eax, temp
		JE iguales
		JNE diferentes

		iguales:
		;---Incrementa los punteros
		INC esi
		INC edi
		;---Se obtiene el siquiente caracter del archivo y de la palabra. Se realiza de nuevo la comparación
		MOVZX ebx, BYTE PTR [esi]
		MOV temp, ebx
		MOV ebx, temp
		CMP ebx, 0
		JE encontrada
		XOR eax, eax
		MOVZX eax, BYTE PTR [edi]
		MOV temp2, eax
		XOR eax, eax
		MOV eax, temp2
		call EAXmayuscula
		call TEMPmayuscula
		CMP temp, eax
		JE iguales
		JNE volverComenzar

		volverComenzar:
		;---Vuelve a iniciar el puntero de palabra y compara
		XOR esi, esi
		LEA esi, buffer
		MOVZX ebx, BYTE PTR [esi]
		MOV temp, ebx
		JMP diferentes

		evaluar:
		;---Evaluación de al menos 1 resultado
		CMP bEncontrado,0
		JE noencontrada
		JMP Fin

		noencontrada:
		;---Impresión de la cadena no encontrada
		invoke StdOut, addr noencontrado
		JMP Fin

		encontrada:
		;---Impresión de la cadena encontrada junto a la fecha y vuelve a comenzar
		invoke StdOut, addr encontrado
		INC bEncontrado
		call imprimirFecha
		print " ",10,13
		mov edx, 20d
		mov fechan, dl
		JMP volverComenzar

		Fin:
		ret

	Buscar endp

	imprimirFecha proc
		XOR EAX, EAX
		;---se repite hasta encontrar la fecha
		espacio:
		INC edi
		MOVZX eax, BYTE PTR [edi]
		CMP eax, 32
		JNE espacio
	
		;---Impresión de la fecha
		fecha:
		INC edi
		MOVZX eax, BYTE PTR [edi]
		push eax
		print esp
		pop eax
		dec fechan
		jnz fecha
		ret
	imprimirFecha endp

	;---Funciones de conversión a mayúsculas
	EAXmayuscula proc
	CMP AX,61H
	JB mayuscula
	CMP AX,7AH
	JA mayuscula
	AND AX,11011111B
	mayuscula:
	ret
	EAXmayuscula endp

	EBXmayuscula proc
	CMP BX,61H
	JB mayuscula
	CMP BX,7AH
	JA mayuscula
	AND BX,11011111B
	mayuscula:
	ret
	EBXmayuscula endp

	TEMPmayuscula proc
	CMP temp,61H
	JB mayuscula
	CMP temp,7AH
	JA mayuscula
	AND temp,11011111B
	mayuscula:
	ret
	TEMPmayuscula endp

	TEMP2mayuscula proc
	CMP temp2,61H
	JB mayuscula
	CMP temp2,7AH
	JA mayuscula
	AND temp2,11011111B
	mayuscula:
	ret
	TEMP2mayuscula endp

end start