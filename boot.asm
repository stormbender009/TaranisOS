[BITS 16]
[ORG 0x7C00]

start:
  ;clear the screen
  mov ah, 0x00 ; clear the screen
  mov al, 0x03 ; clear the whole screen
  int 0x10

  xor ax, ax ; Clear AX register
  mov ds, ax ; Set DS to 0
  cld ; Clear direction flag

  ; Set up stack
  mov ah, 0x02 ; BIOS read sector
  mov al, 0x01 ; sectors to read
  mov ch, 0x00 ; Cylinder 0 
  mov cl, 0x02 ; Sector 2
  mov dh, 0x00 ; head 0
  mov dl, 0x00 ; drive number (0 for floppy)
  xor bx, bx ; Clear BX register
  mov es, bx ; es should be 0 
  mov bx, 0x8000 ; Offset
  int 0x13 ; Read sectors from disk

  jc disk_error ; Jump if there was an error
  mov si, success_msg ; Load the address of the success message into SI
  
  call print_string ; Print the success message
  ; Jump to the loaded kernel
  jmp 0x8000 ; Jump to the kernel

print_string:
  lodsb        ; grab a byte from SI

  or al, al  ; logical or AL by itself
  jz .done   ; if the result is zero, get out

  mov ah, 0x0E
  int 0x10      ; otherwise, print out the character!

  jmp print_string

.done:
  ret ; Return to the caller(in this case, the kernel)
success_msg db 'Kernel loaded successfully!', 0x0D, 0x0A, 0

disk_error:
    hlt ; Halt the CPU if there was an error

; Boot sector signature (must be at offset 510-511)
times 510-($-$$) db 0
dw 0xAA55