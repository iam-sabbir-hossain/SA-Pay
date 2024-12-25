.stack 100h ; Need this to make main work 


; add your code here  

.data

  msg1 db 'Welcome to SA-Pay ATM, How can we help you?$'
  msg2 db 'Choose an Option: $'
  msg3 db '1.Create An Account $'
  msg4 db '2.Print Statement $'
  msg5 db '3.Deposit $'
  msg6 db '4.Withdrawl $'
  msgE db '5.Exit$'
  msgOp11 db 'Enter Name:$'
  msgOp12 db 'Enter Pin:$'
  msgOp13 db 'Account is all set!Going back to Menu $'
  msgOp21 db 'Account Holder Name: $'
  msgOp22 db 'Account Balance: $'
  msgOp23 db '0 $'
  msgOp31 db 'Please Specify an Amount to Add: $'
  msgOp32 db '1. 1000 tk. $'
  msgOp33 db '2. 2000 tk. $'
  msgOp34 db '3. 5000 tk. $'
  msgOp35 db '4. 10000 tk.$ ' 
  msgOp41 db 'Please Specify an Amount to withdraw: $'
  msgOp42 db 'Insufficient Fund please try a lower amount. $'
  msgNo db 'Please Create an account before at taking any action $'
  inputCode db ?
  accountName db 100 dup('$')
  accountPin db 100 dup('$')
  accountPinCount dw 0
  accountBalance dw 0
   
                           
                           
.code
  
  ; Utility code
  
  macro printString str   
     mov ah,9
     lea dx,str
     int 21h
  endm
    
  
  printNumber proc                  
    ;initilize count 
    mov cx,0 
    mov dx,0 
    label1: 
        ; if ax is zero 
        cmp ax,0 
        je print1       
          
        ;initilize bx to 10 
        mov bx,10         
          
        ; extract the last digit 
        div bx                   
          
        ;push it in the stack 
        push dx               
          
        ;increment the count 
        inc cx               
          
        ;set dx to 0  
        xor dx,dx 
        jmp label1
         
    print1: 
        ;check if count  
        ;is greater than zero 
        cmp cx,0 
        je exitprint
          
        ;pop the top of stack 
        pop dx 
          
        ;add 48 so that it  
        ;represents the ASCII 
        ;value of digits 
        add dx,48 
          
        ;interuppt to print a 
        ;character 
        mov ah,02h 
        int 21h 
          
        ;decrease the count 
        dec cx 
        jmp print1 
    exitprint: 
        jmp main 
  printNumber endp 
  
  checkAccount proc
    cmp accountPINcount,0
    je accountNotCreated
    ret
  
    accountNotCreated:
        call newLine
        call newline
        printString msgNo
        jmp main 
  checkAccount endp
       
  
  printMoneyOption proc
    call newLine
    printString msgOp32
    call newLine
    printString msgOp33
    call newLine
    printString msgOp34
    call newLine
    printString msgOp35
    ret
  printMoneyOption endp  
  
  GetInput proc near 
    ;call newLine
    mov ah,1  ; Takes only a single input
    int 21h
    mov inputCode,al
    ret        
  GetInput endp 
 
  
  newLine proc near   
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h    
    ret    
  newLine endp
  
; Set Name and Pin 
  
  macro SetName str
    call newLine
    printString msgOp11
    mov si,offset str
    input: 
        mov ah,1
        int 21h
        cmp al,13 
        je GetPin
        mov [si],al
        inc si
        jmp input
  
  endm

  macro SetPin str
    call newLine
    printString msgOp12
    mov si,offset str
    input2: 
        mov ah,1
        int 21h
        cmp al,13
        je BacktoM
        inc accountPinCount
        mov [si],al
        inc si
        jmp input2
  
  endm
  
  
  Op1 proc
      
      call newLine
      call newLine
      SetName accountName
      
      GetPin:
        SetPin accountPin
      
      BacktoM:
        call newLine
        printString msgOp13
        call newLine
        jmp Main  
    
    
    
  Op1 endp

; Print Statement 

  Op2 proc
     
     call newLine
     call newLine
     call checkAccount
     printString msgOp21
     printString accountName
     call newLine
     printString msgOp22
     mov ax, accountBalance
     cmp ax,0
     je zerobalance
     call printNumber
     call newLine
     
     zerobalance:
       printString msgOp23 
       call newLine
       jmp main
     ret
     
  Op2 endp

; Deposit Money
  Op3 proc
    call newline
    call newline
    call checkAccount
    call printMoneyOption
    call newline
    call newline
    printString msgOp31
    call GetInput
    
    cmp inputCode,'1'  ;Can't do it directly cause of after cmp
        je Addone      ; difference between je and jmp super imp!
        
    cmp inputCode,'2'
        je Addtwo
                        
    cmp inputCode,'3'
        je Addthree    
        
    cmp inputCode,'4'
        je Addfour  
    
    Addone:
        add accountBalance,1000
        call newLine
        jmp main
    
    Addtwo:
        add accountBalance,2000
        call newLine
        jmp main
    
    Addthree:
        add accountBalance,5000
        call newLine
        jmp main
    
    Addfour:
        add accountBalance,10000
        call newLine
        jmp main
        
     
  Op3 endp

; Withdraw Money
  
  Op4 proc
    call newline
    call newline
    call checkAccount
    call printMoneyOption
    call newline
    call newline
    printString msgOp31
    call GetInput
    
    cmp inputCode,'1'   ;Can't do it directly cause of after cmp      
        je Subone
        
    cmp inputCode,'2'
        je Subtwo
        
    cmp inputCode,'3'
        je Subthree    
        
    cmp inputCode,'4'
        je Subfour  
    
    Subone:
        cmp accountBalance,1000
        jl insufficientfund
        sub accountBalance,1000
        jmp main
    
    Subtwo:
        cmp accountBalance,2000
        jl insufficientfund
        sub accountBalance,2000
        jmp main
    
    Subthree:
        cmp accountBalance,5000
        jl insufficientfund
        sub accountBalance,5000
        jmp main
    
    Subfour:
        cmp accountBalance,10000
        jl insufficientfund
        sub accountBalance,10000
        jmp main
                   
    insufficientfund:
        call NewLine
        call NewLine
        printString msgOp42
        jmp main

     
  Op4 endp
  
  
 
     
  Options proc
    call newLine
    printString msg1
    call newLine
    printString msg3
    call newLine
    printString msg4
    call newLine
    printString msg5
    call newLine
    printString msg6
    call newLine
    printString msgE 
    call newLine
    printString msg2
    ret ; Gotta return control to stack
        
  Options endp
  
  
  printop:
    call newLine
    printString msg2
    jmp mainloop
  ret
    
  
  
Main proc
    
    mov ax,@data
    mov ds,ax
    
    mainloop:                 
    
     
        call Options
        call newLine
        call GetInput                                      
        
        cmp inputCode,'1'
        je Op1
        
        cmp inputCode,'2'
        je Op2
        
        cmp inputCode,'3'
        je Op3  
        
        cmp inputCode,'4'
        je Op4
        
        cmp  inputCode,'5'
        je exit
        
       
        
        jmp mainloop
                       
    exit:
       
        mov ah,4ch
        int 21h
        
        
        
  main endp
end main
            
            
;ret


                        1

