.text
.globl main

main:
    li $v0, 4
    la $a0, mensagem_inicial
    syscall

    li $a0, 0
    jal print_board

    li $t0, 0
    start_for_3:
        beq $t0, 9, velha

        jal ler_posicao

        move $a0, $v0
        li $t1, 2
        div $t0, $t1
        mfhi $a1
        jal set_position

        li $a0, 0
        jal print_board
        jal confirma_vitoria

        # fica alternando entre 1 e 0 a cada iteracao
        add $t0, $t0, 1
        j start_for_3

velha:
    la $a0, velha_msg
    li $v0, 4
    syscall

end:
    li $v0, 10
    syscall

ler_posicao:
    # prologo
    sub $sp, $sp, 32
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    sw $t5, 24($sp)
    sw $t6, 28($sp)

    # aloca buffer na heap para ler a string
    # t0 = ponteiro para o buffer
    li $a0, 4
    li $v0, 9
    syscall
    move $t0, $v0

    # le a string para o buffer
    move $a0, $t0
    li $a1, 4
    li $v0, 8
    syscall

    # $t1 possui a string invertida (lw le little endian)
    lw $t1, 0($t0)

    # $t2 possui o primeiro caracrtere
    li $t2, 0
    sll $t2, $t1, 24
    srl $t2, $t2, 24

    # t3 possui o segundo caractere
    srl $t3, $t1, 8
    sll $t3, $t3, 24
    srl $t3, $t3, 24

    # converte a coluna para indice
    sub $t2, $t2, 97

    # se a coluna for invalida, $t4 sera diferente de 0
    li $t4, 0
    li $t5, 0
    slti $t4, $t2, 0
    li $t6, 2
    slt $t5, $t6, $t2
    add $t4, $t4, $t5

    bgt $t4, 0, throw_error_parsing_1
    j end_throw_error_parsing_1

    throw_error_parsing_1:
        la $a0, error_1
        li $v0, 4
        syscall

        lw $ra, 0($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        lw $t2, 12($sp)
        lw $t3, 16($sp)
        lw $t4, 20($sp)
        lw $t5, 24($sp)
        lw $t6, 28($sp)
        add $sp, $sp, 32
        j ler_posicao
    end_throw_error_parsing_1:

    # converte a linha para indice
    sub $t3, $t3, 49

    # se a linha for invalida, $t4 sera diferente de 0
    li $t4, 0
    li $t5, 0
    slti $t4, $t3, 0
    li $t6, 2
    slt $t5, $t6, $t3
    add $t4, $t4, $t5

    bgt $t4, 0, throw_error_parsing_2
    j end_throw_error_parsing_2

    throw_error_parsing_2:
        la $a0, error_2
        li $v0, 4
        syscall

        lw $ra, 0($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        lw $t2, 12($sp)
        lw $t3, 16($sp)
        lw $t4, 20($sp)
        lw $t5, 24($sp)
        lw $t6, 28($sp)
        add $sp, $sp, 32
        j ler_posicao
    end_throw_error_parsing_2:

    mul $t3, $t3, 12
    mul $t2, $t2, 4
    add $t7, $t2, $t3

    lw $t0, board($t7)
    li $t1, 32
    beq $t0, $t1, end_throw_error_parsing_3
    throw_error_parsing_3:
        la $a0, error_3
        li $v0, 4
        syscall

        lw $ra, 0($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        lw $t2, 12($sp)
        lw $t3, 16($sp)
        lw $t4, 20($sp)
        lw $t5, 24($sp)
        lw $t6, 28($sp)
        add $sp, $sp, 32
        j ler_posicao
    end_throw_error_parsing_3:

    move $v0, $t7

    # epilogo
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    lw $t5, 24($sp)
    lw $t6, 28($sp)
    add $sp, $sp, 32
    jr $ra

set_position:
    # prologo
    sub $sp, $sp, 8
    sw $ra, 0($sp)
    sw $t0, 4($sp)

    li $t0, 79
    mul $a1, $a1, 9
    add $t0, $t0, $a1
    sw $t0, board($a0)

    # epilogo
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    add $sp, $sp, 8
    jr $ra

print_board:
    # prologo
    sub $sp, $sp, 8
    sw $ra, 0($sp)
    sw $t0, 4($sp)

    jal pbl

    # itera pelas linhas
    li $t0, 0
    start_for_1:

        move $a0, $t0
        jal print_row

        bge $t0, 2, end_for_1
        la $a0, separator_row
        li $v0, 4
        syscall

        add $t0, $t0, 1
        j start_for_1
    end_for_1:

    jal pbl

    # epilogo
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    add $sp, $sp, 4
    jr $ra

print_row:
    # prologo
    sub $sp, $sp, 8
    sw $ra, 0($sp)
    sw $t0, 4($sp)

    # itera pelos itens da linha
    move $t0, $a0
    mul $t0, $t0, 3
    add $t2, $t0, 2

    start_for_2:
        mul $t1, $t0, 4
        la $a0, board
        add $a0, $a0, $t1
        li $a1, 1
        li $v0, 4
        syscall

        bge $t0, $t2, end_for_2
        la $a0, separator_column
        li $v0, 4
        syscall

        add $t0, $t0, 1

        j start_for_2
    end_for_2:

    jal pbl

    # epilogo
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    add $sp, $sp, 8
    jr $ra

confirma_vitoria:
    # prologo
    sub $sp, $sp, 28
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    sw $t5, 24($sp)

    li $t1, 237
    li $t2, 264

    # diagonal principal
    li $t0, 0
    lw $t3, board($t0)
    add $t0, $t0, 16
    lw $t4, board($t0)
    add $t0, $t0, 16
    lw $t5, board($t0)

    add $t0, $t3, $t4
    add $t0, $t0, $t5
    beq $t0, $t1, vitoria_O
    beq $t0, $t2, vitoria_X

    # diagonal secundaria
    li $t0, 8
    lw $t3, board($t0)
    add $t0, $t0, 8
    lw $t4, board($t0)
    add $t0, $t0, 8
    lw $t5, board($t0)

    add $t0, $t3, $t4
    add $t0, $t0, $t5
    beq $t0, $t1, vitoria_O
    beq $t0, $t2, vitoria_X

    # linhas
    li $a0, 0
    li $t0, 0
    li $t1, 2
    start_for_5:
        bgt $t0, $t1, end_for_5
        move $a0, $t0
        jal analisa_linha
        add $t0, $t0, 1
        j start_for_5
    end_for_5:

    # colunas
    li $a0, 0
    li $t0, 0
    li $t1, 2
    start_for_7:
        bgt $t0, $t1, end_for_7
        move $a0, $t0
        jal analisa_coluna
        add $t0, $t0, 1
        j start_for_7
    end_for_7:

    # epilogo
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    lw $t5, 24($sp)
    add $sp, $sp, 28
    jr $ra

analisa_linha:
    # prologo
    sub $sp, $sp, 24
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)

    li $t2, 0
    mul $t0, $a0, 12
    add $t4, $t0, 12
    start_for_4:
        beq $t0, $t4, end_for_4

        lw $t1, board($t0)
        add $t2, $t2, $t1
        add $t0, $t0, 4

        j start_for_4
    end_for_4:

    li $t3, 237
    li $t4, 264
    beq $t2, $t3, vitoria_O
    beq $t2, $t4, vitoria_X

    # epilogo
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    add $sp, $sp, 24
    jr $ra

analisa_coluna:
    # prologo
    sub $sp, $sp, 24
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)

    li $t2, 0
    mul $t0, $a0, 4
    add $t4, $t0, 32
    start_for_6:
        bgt $t0, $t4, end_for_6

        lw $t1, board($t0)
        add $t2, $t2, $t1
        add $t0, $t0, 12

        j start_for_6
    end_for_6:

    li $t3, 237
    li $t4, 264
    beq $t2, $t3, vitoria_O
    beq $t2, $t4, vitoria_X

    # epilogo
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    add $sp, $sp, 24
    jr $ra

vitoria_X:
    la $a0, vitoria_x_msg
    li $v0, 4
    syscall
    j end

vitoria_O:
    la $a0, vitoria_O_msg
    li $v0, 4
    syscall
    j end

pbl:
    # prologo
    sub $sp, $sp, 4
    sw $ra, 0($sp)

    la $a0, bl
    li $v0, 4
    syscall

    # epilogo
    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra

debug:
    # prologo
    sub $sp, $sp, 4
    sw $ra, 0($sp)

    li $v0, 1
    syscall
    jal pbl

    # epilogo
    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra

.data
board: .word 32:9
separator_column: .asciiz " | "
separator_row: .asciiz "- + - + - \n"
mensagem_inicial: .asciiz "Bem vindo ao jogo da velha. Jogue dando posicoes:\n\n"
error_1: .asciiz "Coluna invalida!\n"
error_2: .asciiz "Linha invalida!\n"
error_3: .asciiz "Casa ocupada!\n"
vitoria_x_msg: .asciiz "Vitoria do X!\n"
vitoria_O_msg: .asciiz "Vitoria do O!\n"
velha_msg: .asciiz "Deu velha!\n"
bl: .asciiz "\n"
