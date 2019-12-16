%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .bss
	expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
    mov ebp, esp
    push ebp
    mov ebp, esp

    GET_STRING expr, MAX_INPUT_SIZE

; parsarea intrării:
;   parcurg caracter cu caracter string-ul expr,
;   care conține datele de intrare, și construiesc numerele
;   sau aplic operațiile corespunzătoare operatorilor.
;   Pornesc de la indicele -1 fiindcă incrementez ecx
;   la fiecare ciclare în bucla parsării.
    mov ecx, -1

parse_input:
    inc ecx
    xor eax, eax
    mov al, byte [expr + ecx]
    
    ; mă opresc la terminarea string-ului,
    ;   adică la caracterul null
    cmp al, 0
    je exit
    
    ; caracterul '-' are un caz aparte,
    ;   față de ceilalți operatori
    cmp al, '-'
    je minus
    
    ; dacă am găsit un spațiu, atunci voi pune pe stivă
    ;   numărul construit până acum
    cmp al, ' '
    je push_number
    
    ; în cazul în care caracterul curent este o cifră,
    ;   voi construi un nou număr
    cmp al, '0'
    jge build_number
    
    ; dacă acest caracter nu este o cifră sau un minus,
    ;   iar input-ul este corect, atunci sigur va fi un
    ;   operator și voi aplica operația corespunzătoare
    jmp operator
    
build_number:
    ; dacă numărul este precedat de un minus
    ;   atunci voi construi un număr negativ,
    ;   altfel, unul pozitiv
    cmp ebx, 0
    jl build_negative
    jmp build_positive

build_positive:
    ; transform codul ASCII citit în cifră
    sub al, '0'
    
    ; păstrez pe stivă regiștrii pentru mai târziu
    push ecx
    push eax
    
    ; înmulțesc numărul anterior construit cu 10 și
    ;   adaug noua cifră, pentru a crea numărul din input
    mov eax, ebx
    mov ecx, 10
    imul ecx
    
    ; acest număr se va afla în ebx
    pop ebx
    add eax, ebx
    mov ebx, eax
    
    pop ecx
    ; continui parsarea
    jmp parse_input

;----------------------------------------------------------

build_negative:
    sub al, '0'
    push ecx
    push eax
    
    mov eax, ebx
    mov ecx, 10
    imul ecx
    
    ; până aici este identic cu cazul numărului pozitiv,
    ;   dar pornesc cu o valoare negativă și
    ;   scad cifra, în loc s-o adun
    pop ebx
    sub eax, ebx
    mov ebx, eax
    
    pop ecx
    jmp parse_input

;----------------------------------------------------------
    
negative_number:
    ; când numărul este negativ, pornesc construirea sa
    ;   cu -(prima cifră), apoi continui parsarea
    sub edx, '0'
    neg edx
    mov ebx, edx
    jmp parse_input

;----------------------------------------------------------

push_number:
    ; pun numărul proaspăt construit pe stivă
    push ebx
    xor ebx, ebx
    jmp parse_input

;----------------------------------------------------------

minus:
    ; caracterul minus ar putea preceda un număr negativ,
    ;   sau ar putea fi operatorul de scădere
    inc ecx
    xor edx, edx
    ; parsez un nou carater: dacă este o cifră,
    ;   atunci avem de-a face cu un număr negativ,
    ;   iar dacă este un spațiu, trebuie efectuată
    ;   o operație de scădere
    mov dl, byte [expr + ecx]
    cmp dl, '0'
    jg negative_number
    dec ecx
    jmp operator

;----------------------------------------------------------

operator:
    ; dacă am găsit un operator
    ;   aplic operația specifică
    inc ecx
    cmp al, '+'
    je plus

    cmp al, '*'
    je multiply
    
    cmp al, '-'
    je substract
    
    cmp al, '/'
    je divide
    
    jmp exit

;----------------------------------------------------------

plus: 
    pop eax
    pop edx
    add eax, edx
    push eax
    jmp parse_input

;----------------------------------------------------------

substract:
    pop edx
    pop eax
    sub eax, edx
    push eax
    jmp parse_input

;----------------------------------------------------------

multiply:
    pop eax
    pop ebx
    cdq
    imul ebx
    push eax
    xor ebx, ebx
    jmp parse_input

;----------------------------------------------------------

divide:
    pop ebx
    pop eax
    cdq
    idiv ebx
    push eax
    xor ebx, ebx
    jmp parse_input

;----------------------------------------------------------

exit:
    pop eax
    PRINT_DEC 4, eax
    NEWLINE
    xor eax, eax
    pop ebp
    ret