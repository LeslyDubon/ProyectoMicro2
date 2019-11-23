.386
.model flat, stdcall

option casemap:none 
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
include \masm32\include\masm32.inc
include \masm32\include\masm32rt.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib


.DATA
;---Definición de la ruta del archivo de escritura
FileName db "test2.txt",NULL
;---Mensajes de éxito y error de la creación del archivo
BadText db "Its not ok",0
OkText db "Its ok",0
;---Mensaje de impresión de acciones
format db 'You pressed %s',10,0
WriteText  db "This is some test text.",0
thechar db 0, 0
;---Formatos de fecha y hora
formatofecha DB "  dd-MM-yyyy",0
formatohora DB " hh:mm:ss",0
espacio DB " ",0


.DATA?
;---Handle
hFile HANDLE ?
;---Buffers de fecha y hora
fechaBuf DB 50 DUP(?)
horaBuf DB 50 DUP(?)
BytesRead dd ?
BytesWritten dd ?

.CODE
start1:
	sl: 
	;---Creación del archivo
    invoke CreateFile,addr FileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov hFile,eax
	cmp hFile, INVALID_HANDLE_VALUE
    jz code1

	;---Espera a que una tecla sea presionada
	call wait_key
	mov thechar, al
	;---Compara el char con enter
	cmp thechar, 13
	je fecha1
	;---Compara el char con el espacio
	cmp thechar, 32
	je fecha1
	cmp thechar, 0E0h
	je start2
	invoke SetFilePointer,hFile,0,0,FILE_END
	mov BytesRead, 1
	mov BytesWritten, 1
	invoke WriteFile, hFile, addr thechar, BytesRead, addr BytesWritten,  0
	invoke CloseHandle, hFile
    jmp sl

fecha1:
	;---Formato de fecha y hora
	INVOKE GetDateFormat , 0 , 0 , \
	0 , ADDR formatofecha , ADDR fechaBuf, 50
	MOV EBX, OFFSET fechaBuf
	INVOKE GetTimeFormat , 0 , 0 , \
	0 , ADDR formatohora , ADDR horaBuf , 50
	;---Imprime un enter
	mov thechar, 10
	invoke SetFilePointer,hFile,0,0,FILE_END
	mov BytesRead, 12
	mov BytesWritten, 12
	;---Escribe la fecha y hora
	invoke WriteFile, hFile, addr fechaBuf, BytesRead, addr BytesWritten,  0
	invoke WriteFile, hFile, addr horaBuf, BytesRead, addr BytesWritten,  0
	mov BytesRead, 1
	mov BytesWritten, 1
	invoke WriteFile, hFile, addr thechar, BytesRead, addr BytesWritten,  0
	invoke CloseHandle, hFile
	jmp sl

fecha2:
	;---Formato de fecha y hora
	INVOKE GetDateFormat , 0 , 0 , \
	0 , ADDR formatofecha , ADDR fechaBuf, 50
	MOV EBX, OFFSET fechaBuf
	INVOKE GetTimeFormat , 0 , 0 , \
	0 , ADDR formatohora , ADDR horaBuf , 50
	;---Imprime un enter
	mov thechar, 10
	invoke SetFilePointer,hFile,0,0,FILE_END
	mov BytesRead, 12
	mov BytesWritten, 12
	;---Escribe la fecha y hora
	invoke WriteFile, hFile, addr fechaBuf, BytesRead, addr BytesWritten,  0
	invoke WriteFile, hFile, addr horaBuf, BytesRead, addr BytesWritten,  0
	mov BytesRead, 1
	mov BytesWritten, 1
	invoke WriteFile, hFile, addr thechar, BytesRead, addr BytesWritten,  0
	invoke CloseHandle, hFile
	jmp start2

code1:
    invoke MessageBox,NULL,addr BadText,addr BadText,MB_OK
    invoke ExitProcess,0
    ret

start2: 
	;---Creación del archivo
    invoke CreateFile,addr FileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
    mov hFile,eax
    cmp hFile, INVALID_HANDLE_VALUE
    jz code1

	;---Espera a que una tecla sea presionada
	call wait_key
	mov thechar, al

	;---Compara el char con enter
	cmp thechar, 13
	je fecha2
	;---Compara el char con el espacio
	cmp thechar, 32
	je fecha2
	cmp thechar, 0E0h
	je sl

	;---Imprime las acciones del teclado
	invoke crt_printf, ADDR format, ADDR thechar
	invoke SetFilePointer,hFile,0,0,FILE_END
	mov BytesRead, 1
	mov BytesWritten, 1
	invoke WriteFile, hFile, addr thechar, BytesRead, addr BytesWritten,  0
	invoke CloseHandle, hFile
    jmp start2

end start1

