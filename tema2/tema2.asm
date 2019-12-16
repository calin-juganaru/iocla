extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./inputs/inputX.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

; -------------------------------------
; ---------------TASK-1----------------

xor_strings:
        push ebp
        mov ebp, esp
        
        xor ebx, ebx
        mov eax, [ebp + 8]
        
; apelez funcștia strlen pentru a găsi
; dimensiunea șirului criptat. șirul cu 
; cheia se află în memorie imediat după
; cel criptat, deci la adresa primită ca 
; parametru + dimensiunea aflată cu strlen

        push eax
        push eax
        call strlen
        add esp, 4
        mov ecx, eax
        pop eax
        
; eax -> șirul criptat
; ebx -> cheia

        mov ebx, eax
        inc ecx
        add ebx, ecx

; -------------------------------------

; extrag câte un octet din fiecare șir 
; și aplic xor între ei. rezultatul va
; rămâne în șirul primit ca parametru

loop_1:
        xor edx, edx        
        mov dl, byte [ebx]
        
        push eax
        push ecx
        push edx
        
        xor byte [eax], dl
        inc eax
        inc ebx
        cmp byte [eax], 0
        jne loop_1
        
        leave
	    ret

; -------------------------------------
; ---------------TASK-2----------------

rolling_xor:
        push ebp
        mov ebp, esp
        
        xor ebx, ebx
        mov eax, [ebp + 8]
        
        push eax
        push eax
        call strlen
        add esp, 4
        mov ecx, eax
        pop eax

; -------------------------------------

; până aici codul a fost aproape identic
; cu cel de la task-ul 1, lipsește doar
; inițializarea registrului ebx cu adresa
; cheii, căci nu mai este necesar. În rest
; algoritmul va decurge ca o recurență,
; aplicând xor între oricare două elemente
; consecutive ale șirului primit

loop_2:
        dec ecx
        xor edx, edx        
        mov dl, byte [eax + ecx - 1]
        xor byte [eax + ecx], dl
        cmp ecx, 1
        jg loop_2
        
        leave
        ret
        
; -------------------------------------
; ---------------TASK-3----------------

xor_hex_strings:
        push ebp
        mov ebp, esp
        
        xor ebx, ebx
        mov eax, [ebp + 8]
        
        push eax
        push eax
        call strlen
        add esp, 4
        mov ecx, eax
        pop eax
        push ecx

        mov ebx, eax
        inc ecx
        add ebx, ecx
        pop ecx
        push eax

; -------------------------------------

; în această buclă voi converti reprezentarea
; hexazecimală în coduri ascii corespunzătoare
; caracterelor din cele două șiruri, și voi
; aplica xor între elementele cu același indice.

hexa_to_ascii_loop:
        xor edx, edx
        mov dl, byte [ebx]
        push ebx
        xor ebx, ebx
        mov bl, byte [eax]
        
        push edx
        push ebx
        call ascii_to_hex
        add esp, 4
        mov ebx, edx
        pop edx

        push edx
        call ascii_to_hex
        add esp, 4 
        xor edx, ebx
        
        push edx
        call hex_to_ascii
        add esp, 4
        
        mov byte [eax], dl
        pop ebx       
        add eax, 1
        add ebx, 1
        cmp byte [eax], 0
        jne hexa_to_ascii_loop  

        pop eax
        mov ecx, eax

; -------------------------------------

; în a doua buclă voi concatena codurile
; ascii rezultate în prima (care sunt
; reținute pe câte doi octeți consecutivi
; pentru un singur caracter), iar șirul
; obținut va suprascrie cel primit

ascii_to_bin_loop:
        xor ebx, ebx
        xor edx, edx
        mov bl, byte [eax]
        mov dl, byte [eax + 1]
        push ecx
        push eax
        push edx
        
        push ebx
        call ascii_to_hex
        add esp, 4
        mov ebx, edx       
        
        mov eax, ebx
        mov ecx, 16
        mul ecx
        pop edx
        
        push edx
        call ascii_to_hex
        add esp, 4
        
        add eax, edx
        mov ebx, eax
        pop eax
        
        pop ecx
        mov byte [ecx], bl
        add eax, 2
        add ecx, 1
        cmp byte [eax], 0
        jne ascii_to_bin_loop
        
        mov byte [ecx], 0
          
        leave
	ret

; -------------------------------------
; -------------------------------------

; funcție utilitară care transformă un
; caracter cifră sau literă mică [a-f], 
; (cifră din baza 16) în număr (baza 16)

ascii_to_hex:
        push ebp
        mov ebp, esp
        mov edx, [ebp + 8]
        cmp edx, 'a'
        jge if_letter
        jmp if_digit
    
if_digit:
        sub edx, '0'
        leave
        ret
    
if_letter:
        sub edx, 'a'
        add edx, 10
   
        leave
        ret

; -------------------------------------
; -------------------------------------

; funcție utilitară care convertește o
; cifră din baza 16 în caracterul ascii
; corespunzător (cifră sau literă [a-f])

hex_to_ascii:
        push ebp
        mov ebp, esp
        mov edx, [ebp + 8]
        cmp edx, 9
        jg to_letter
        jmp to_digit
    
to_digit:
        add edx, '0'
        leave
        ret
    
to_letter:
        add edx, 'a'
        sub edx, 10
   
        leave
        ret

; -------------------------------------
; ---------------TASK-4----------------

base32decode:
        push ebp
        mov ebp, esp
        mov eax, [ebp + 8]
    
        mov ecx, eax

; în următoarea buclă voi extrage la o
; iterație câte 8 elemente din șir, care
; chiar dacă fiecare ocupă câte un octet,
; doar 5 dintre biți sunt utili, și, din
; aceștia voi construi octeți prin niște
; concatenări succesive, pentru a obține
; câte 5 caractere la fiecare iterație.
; șirul rezultat va suprascrie șirul inițial

loop_over_bytes:
        xor ebx, ebx
        xor edx, edx

; construiesc primul octet:

        mov dl, byte[eax]
        mov bl, byte[eax + 1]
    
        push edx
        call decode32
        add esp, 4
        push edx
        push ebx
        call decode32
        add esp, 4
        mov ebx, edx
        pop edx
    
        shl bl, 3
        mov bh, dl
        shl bx, 3
        mov byte [ecx], bh

;----------------------------------
; construiesc al doilea octet:

        xor edx, edx
        mov dl, byte[eax + 2]
        push edx
        call decode32
        add esp, 4
    
        shl dl, 1
        or bl, dl
        xor bh, bh
        shl bx, 7
    
        xor edx, edx
        mov dl, byte[eax + 3]
        push edx
        call decode32
        add esp, 4
    
        shl dl, 3
        mov bl, dl
        shl bx, 1
        mov byte [ecx + 1], bh

;----------------------------------
; construiesc al treilea octet:

        xor edx, edx
        mov dl, byte[eax + 4]
        push edx
        call decode32
        add esp, 4

        shl bx, 4
        shl dl, 3
        mov bl, dl
        shl bx, 4
        mov byte [ecx + 2], bh

;----------------------------------
; construiesc al patrulea octet:

        xor edx, edx
        mov dl, byte[eax + 5]
        push edx
        call decode32
        add esp, 4

        shl bx, 1
        shl dx, 3
        mov bl, dl
        shl bx, 5

        xor edx, edx
        mov dl, byte[eax + 6]
        push edx
        call decode32
        add esp, 4
        shl dl, 3
        mov bl, dl
        shl bx, 2
        mov byte [ecx + 3], bh

;----------------------------------
; construiesc și al cincilea octet:
    
        xor edx, edx
        mov dl, byte[eax + 7]
        push edx
        call decode32
        add esp, 4
        or bl, dl
        mov byte [ecx + 4], bl

; incrementez pointerii din regiștrii
; și continui ciclarea printre octeți

        add eax, 8
        add ecx, 5
        mov ebx, eax
        inc ebx
        cmp byte [ebx], 0
        jne loop_over_bytes

        leave
        ret

; -------------------------------------
; -------------------------------------

; funcție utilitară care decodifică
; un alfabet în baza 32

decode32:
        push ebp
        mov ebp, esp
        xor edx, edx
        mov edx, [ebp + 8]

        cmp edx, '='
        je pad

        cmp edx, 'A'
        jge letter
        jmp digit

; -------------------------------------

pad:
        xor edx, edx    
        jmp _exit

letter:
        sub edx, 'A'
        jmp _exit

digit:
        sub edx, 24
        jmp _exit

_exit:
        leave
        ret

; -------------------------------------
; ---------------TASK-5----------------

bruteforce_singlebyte_xor:
        push ebp	
        mov ebp, esp
        mov eax, [ebp + 8]

        push eax
        push eax
        call strlen
        add esp, 4
        mov ecx, eax
        pop eax
        push ecx

        mov cx, 255

; -------------------------------------

; în outer_loop încerc să decriptez
; mesajul cu fiecare octet între [0, 255]

outer_loop:
        push eax
        dec ecx

; în inner_loop aplic xor între fiecare
; caracter al șirului și octetul curent

inner_loop:
        xor edx, edx
        mov dl, byte [eax]
        xor edx, ecx
        cmp edx, 'f'
        je f

; -------------------------------------

back_to_loop:
        inc eax
        cmp byte [eax], 0
        jne inner_loop

        pop eax
        cmp ecx, 0
        jge outer_loop

; -------------------------------------

; după ce am găsit cheia mai ciclez o
; singură dată ca să decriptez întreg
; mesajul și să returnez cheia găsită

found:
        pop eax

last_loop:
        xor edx, edx
        mov dl, byte [eax]
        xor edx, ecx
        mov byte [eax], dl

        inc eax
        cmp byte [eax], 0
        jne last_loop

        mov eax, ecx
        push eax
        
        leave
        ret

; -------------------------------------

; verific efectiv pas cu pas dacă în 
; șirul 'decriptat' cu octetul curent
; există cuvântul 'force'

f:
        inc eax
        xor edx, edx
        mov dl, byte [eax]
        xor edx, ecx
        cmp edx, 'o'
        jne back_to_loop
o:
        inc eax
        mov dl, byte [eax]
        xor edx, ecx
        cmp edx, 'r'
        jne back_to_loop
r:
        inc eax
        mov dl, byte [eax]
        xor edx, ecx
        cmp edx, 'c'
        jne back_to_loop
c:
        inc eax
        mov dl, byte [eax]
        xor edx, ecx
        cmp edx, 'e'
        jne back_to_loop
e:
        je found

; -------------------------------------
; ---------------TASK-6----------------

decode_vigenere:
        push ebp	
        mov ebp, esp
        mov eax, [ebp + 8]
        mov ecx, [ebp + 12]

; eax -> șirul criptat
; ecx -> cheia

        push eax
        push ecx
        push ecx
        call strlen
        add esp, 4
        mov ebx, eax
        pop ecx
        pop eax
        push ebx

; -------------------------------------

; parcurg fiecare caracter din șirul
; primit și, în același timp, din
; cheie, iar dacă sunt litere, aplic
; operația xor între literă și offset

loop_over_letters:
        xor ebx, ebx
        xor edx, edx
        mov bl, byte [eax]
        mov dl, byte [ecx]
    
        cmp bl, 'a'
        jge offset
        inc eax
        cmp byte [eax], 0
        jg loop_over_letters

; -------------------------------------

continue_looping:
        mov byte [eax], bl

        inc eax
        inc ecx

        cmp byte [ecx], 0
        jle modulo_size

        cmp byte [eax], 0
        jg loop_over_letters

        jmp exit_task_6

; -------------------------------------

; calculez offsetul față de litera 'a'

offset:
        sub edx, 'a'
        neg edx
        add edx, 26
        add ebx, edx
        cmp ebx, 'z'
        jg not_letter
        jmp continue_looping

; în cazul în care caracterul curent
; nu este o literă, acesta va trece
; ne(de)criptat prin iterație

not_letter:
        sub ebx, 26
        jmp continue_looping

; ---------------------------------

; dacă cheia este mai mică decât
; șirul criptat, atunci trebuie să
; aplic un % sizeof(key) la indicele
; curent, deci să scad dimensiunea,
; cand trece de ultimul element

modulo_size:
        pop ebx
        push ebx
        sub ecx, ebx
        cmp byte [eax], 0
        jg loop_over_letters

; ---------------------------------

exit_task_6:
        pop ebx
        neg ebx
        dec ebx
        mov byte [eax + ebx], 0
        leave
        ret

; -------------------------------------
; -------------------------------------

main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 14] ;7
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	; TASK 1: Simple XOR between two byte streams
	; TODO TASK 1: find the address for the string and the key
	; TODO TASK 1: call the xor_strings function

        push ecx
        push ecx
        call xor_strings
        add esp, 4
        
        pop ecx
        push ecx
        call puts                   ;print resulting string
        add esp, 4

	jmp task_done

task2:
	; TASK 2: Rolling XOR
	; TODO TASK 2: call the rolling_xor function
        
        push ecx
        push ecx
        call rolling_xor
        add esp, 4
        
        pop ecx
        push ecx
        call puts
        add esp, 4

        jmp task_done

task3:
	; TASK 3: XORing strings represented as hex strings
	; TODO TASK 1: find the addresses of both strings
	; TODO TASK 1: call the xor_hex_strings function

        push ecx
        push ecx
        call xor_hex_strings
        add esp, 4
        
        pop ecx
        push ecx
        call puts                   ;print resulting string
        add esp, 4

	jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string
	; TODO TASK 4: call the base32decode function
        
        push ecx
        push ecx	
        call base32decode
        pop ecx
        
        pop ecx
        push ecx
        call puts                    ;print resulting string
        pop ecx
	
        jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding
	; TODO TASK 5: call the bruteforce_singlebyte_xor function
        
        push ecx
        push ecx
        call bruteforce_singlebyte_xor
        pop ecx
        
        push eax
        push ecx                    ;print resulting string
        call puts
        pop ecx
        pop eax
        
	push eax                    ;eax = key value
	push fmtstr
	call printf                 ;print key value
	add esp, 8

	jmp task_done

task6:
	; TASK 6: decode Vignere cipher
	; TODO TASK 6: find the addresses for the input string and key
	; TODO TASK 6: call the decode_vigenere function

	push ecx
	call strlen
	pop ecx

	add eax, ecx
	inc eax

	push eax
	push ecx                   ;ecx = address of input string 
	call decode_vigenere
	pop ecx
	add esp, 4

	push ecx
	call puts
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
