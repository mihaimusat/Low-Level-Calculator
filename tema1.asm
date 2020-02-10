%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .bss
    expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
    push ebp ;salveaza base pointer-ul anterior
    mov ebp, esp ;seteaza base pointer-ul stivei ca pointer la top

    GET_STRING expr, MAX_INPUT_SIZE 

    ;am grija ca toate registrele pe care le folosesc sa fie initializate cu 0
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi
        
verificare_final:
    cmp byte [expr + ecx], 0 ;compar pozitia curenta cu terminatorul de sir 
    je afisare ;daca am gasit sfarsitul sirului, inseamna ca trebuie sa afisez rezultatul
    
aplica_operatie:
    mov bl, byte [expr + ecx] ;muta pozitia curenta in registrul bl
    cmp bl, '+' ;compar cu +
    je adunare ;daca am gasit +, sar la label-ul adunare  
    cmp bl, '-' ;compar cu -
    je verificare_minus ;daca am gasit -, sar la label-ul verificare_minus
    cmp bl, '*' ;compar cu *
    je inmultire ;daca am gasit *, sar la label-ul inmultire
    cmp bl, '/' ;compar cu /
    je impartire ;daca am gasit /, sar la label-ul impartire
    cmp bl, ' ' ;compar cu spatiu
    je verificare_spatiu ;daca am gasit spatiu, sar la label-ul spatiu
    jmp afla_numar ;acum stiu sigur ca la pozita curenta pot sa mai am doar numar
       
verificare_minus:
    cmp byte [expr + ecx + 1], ' ' ;daca dupa semnul - am spatiu
    je scadere ;inseamna ca am operatie de scadere
    cmp byte [expr + ecx + 1], 0 ;daca dupa semnul - am terminator de sir
    je scadere ;inseamna ca am operatie de scadere
    mov edi, 1 ;daca nu, inseamna ca am numar negativ si setez edi = 1 
    jmp avansare_pozitie ;avansez pozitia curenta in sir
    
verificare_spatiu:
    cmp byte [expr + ecx - 1], '+' ;daca pe pozitia anterioara am avut +
    je avansare_pozitie ;vreau sa ajung pe spatiu
    cmp byte [expr + ecx - 1], '-' ;daca pe pozitia anterioara am avut -
    je avansare_pozitie ;vreau sa ajung pe spatiu
    cmp byte [expr + ecx - 1], '/' ;daca pe pozitia anterioaraa am avut /
    je avansare_pozitie ;vreau sa ajung pe spatiu
    cmp byte [expr + ecx - 1], '*' ;daca pe pozitia anterioara am avut *
    je avansare_pozitie ;vreau sa ajung pe spatiu
    cmp edi, 1 ;verific daca la pozitia curenta am numar negativ
    je negare_numar ;daca da, sar la label-ul negare_numar
    push esi ;pune numarul de negat pe stiva 
    xor esi, esi
    jmp avansare_pozitie

negare_numar:
    neg esi ;neg ce am pus in esi
    push esi ;si il pun pe stiva
    xor esi, esi
    xor edi, edi
    jmp avansare_pozitie

afla_numar:
    sub bl, '0' ;convertesc din caracter in cifra
    add esi, ebx ;retin in esi cifra curenta a numarului
    cmp byte [expr + ecx + 1], ' ' ;verific daca urmatoarea pozitie e spatiu
    jne prelucrare_cifra ;daca nu, inseamna ca mai am de citit cifre din numar
    jmp avansare_pozitie
    
prelucrare_cifra:
    mov eax, esi ;salveza cifra curenta in eax
    mov esi, 10 ;seteaza esi = 10
    imul esi ;inmultesc cu 10 cifra curenta
    mov esi, eax ;pun rezultatul la loc in esi
    jmp avansare_pozitie
    
adunare:
    pop eax ;scot primul operand de pe stiva
    pop edx ;scot al doilea operand de pe stiva
    add edx, eax ;adun operanzii si retin rezultatul in edx
    push edx ;pun rezultatul pe stiva
    jmp avansare_pozitie
    
scadere:
    pop eax ;scot primul operand de pe stiva
    pop edx ;scot al doilea operand de pe stiva
    sub edx, eax ;scad operanzii si retin rezultatul in edx
    push edx ;pun rezultatul pe stiva
    jmp avansare_pozitie
    
inmultire:
    pop eax ;scot primul operand de pe stiva
    pop edx ;scot al doilea operand de pe stiva
    imul edx ;inmultesc eax cu ce am retinut in edx
    push eax ;pun rezultatul obtinut in eax pe stiva 
    xor edx, edx
    xor eax, eax
    jmp avansare_pozitie
    
impartire:
    pop edi ;scot impartitorul de pe stiva
    pop eax ;scot deimpartitul de pe stiva
    cdq 
    idiv edi ;impart la valoarea retinuta in edi
    push eax ;pun rezultatul obtinut in eax pe stiva
    xor eax, eax
    xor edi, edi
    jmp avansare_pozitie
    
avansare_pozitie:
    inc ecx ;avansez pozitia curenta in sir
    jmp verificare_final
    
afisare:
    pop eax ;scot rezultatul de pe stiva
    PRINT_DEC 4, eax ;si il afisez
    
    xor eax, eax
    pop ebp
    ret