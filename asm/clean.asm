global _asm_clean
global _asm_clean_size
global _asm_clean_retaddr_pop_off

%define TLS_HOOK_INFO 0x44
%define TLS_TEMPORARY 0x48
%define TLS_LASTERR 0x34

%define HOOKCNT_OFF 0
%define LASTERR_OFF 4

asm_clean:

    push eax

    ; restore last error
    mov eax, dword [fs:TLS_HOOK_INFO]
    push dword [eax+LASTERR_OFF]
    pop dword [fs:TLS_LASTERR]

    ; decrease hook count
    dec dword [eax+HOOKCNT_OFF]

    ; restore return address
    call _clean_getpc_target

_clean_getpc:
_clean_retaddr_pop:
    dd 0xcccccccc

_clean_getpc_target:
    pop eax

    ; restore original return address
    pushad
    call [eax+_clean_retaddr_pop-_clean_getpc]
    mov dword [fs:TLS_TEMPORARY], eax
    popad

    pop eax
    jmp dword [fs:TLS_TEMPORARY]

_clean_end:


_asm_clean dd asm_clean
_asm_clean_size dd _clean_end - asm_clean
_asm_clean_retaddr_pop_off dd _clean_retaddr_pop - asm_clean
