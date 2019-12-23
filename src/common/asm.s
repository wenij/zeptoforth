@ Copyright (c) 2019, Travis Bemann
@ All rights reserved.
@ 
@ Redistribution and use in source and binary forms, with or without
@ modification, are permitted provided that the following conditions are met:
@ 
@ 1. Redistributions of source code must retain the above copyright notice,
@    this list of conditions and the following disclaimer.
@ 
@ 2. Redistributions in binary form must reproduce the above copyright notice,
@    this list of conditions and the following disclaimer in the documentation
@    and/or other materials provided with the distribution.
@ 
@ 3. Neither the name of the copyright holder nor the names of its
@    contributors may be used to endorse or promote products derived from
@    this software without specific prior written permission.
@ 
@ THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
@ AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
@ IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
@ ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
@ LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
@ CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
@ SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
@ INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
@ CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
@ ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
@ POSSIBILITY OF SUCH DAMAGE.

	@@ Assemble a move immediate instruction
	define_word "mov-imm,", visible_flag
_asm_mov_imm:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, #7
	ands r0, r1
	movs r1, #0xFF
	ands tos, r1
	lsls r0, r0, #8
	orrs tos, r0
	ldr r0, =0x2000
	orrs tos, r0
	bl _current_comma_16
	pop {pc}	

	@@ Assemble a logical shift left immediate instruction
	define_word "lsl-imm,", visible_flag
_asm_lsl_imm:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, #7
	ands r0, r1
	movs r1, #0xFF
	ands tos, r1
	lsls r0, r0, #8
	orrs tos, r0
	movs r1, tos
	pull_tos
	movs r0, #0x1F
	ands tos, r0
	lsls tos, tos, #6
	orrs tos, r1
	bl _current_comma_16
	pop {pc}	

	@@ Assemble an reverse subtract immediate from zero instruction
	define "neg,", visible_flag
_asm_neg:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, #7
	ands tos, r1
	ands r0, r1
	lsls tos, tos, #3
	orrs tos, r0
	ldr r0, =0x4240
	orrs tos, r0
	bl _current_comma_16
	pop {pc}

	@@ Compile a blx (register) instruction
	define_word "blx-reg,", visible_flag
_asm_blx_reg:
	push {rl}
	movs r0, #0xF
	ands tos, r0
	lsls tos, tos, #3
	ldr r0, =0x4780
	orrs tos, r0
	bl _current_comma_16
	pop {pc}
	
	.ifdef thumb2

	@@ Call a word at an address
	define_word "call,", visible_flag
_asm_call:	
	push {rl}
	bl _current_here
	movs r0, tos
	pull_tos
	movs r1, tos
	subs tos, tos, r0
	ldr r2, =0x00FFFFFF
	cmp tos, r2
	bgt 1f
	ldr r2, =0xFF000000
	cmp tos, r2
	blt 1f
	bl _asm_bl
	pop {pc}
1:	movs tos, r1
	adds tos, #1
	push_tos
	movs tos, #1
	bl _asm_literal
	push_tos
	movs tos, #1
	bl _asm_blx_reg
	pop {pc}
	
	@@ Compile a bl instruction
	define_word "bl,", visible_flag
_asm_bl:
	push {rl}
	movs r0, tos
	lsrs tos, tos, #12
	ldr r1, =0x3FF
	ands tos, r1
	lsls r1, r0, #24
	movs r2, #1
	ands r1, r2
	lsls r2, r1, #10
	orrs tos, r2
	ldr r2, =0xF000
	orrs tos, r2
	push {r0, r1}
	bl _current_comma_16
	pop {r0, r1}
	push_tos
	movs tos, r0
	lsrs tos, tos, #1
	ldr r2, =0x7FF
	ands tos, r2
	lsrs r2, r0, #22
	movs r3, #1
	ands r2, r3
	mvn r2, r2
	eor r2, r1
	ands r2, r3
	lsls r2, r2, #11
	orrs tos, r2
	lsrs r2, r0, #23
	ands r2, r3
	mvn r2, r2
	eor r2, r1
	ands r2, r3
	lsls r2, r2, #13
	orrs tos, r2
	ldr r2, =0xD000
	orrs tos, r2
	bl _current_comma_16
	pop {pc}

	@@ Compile a move 16-bit immediate instruction
	define_word "mov-16-imm,", visible_flag
_asm_mov_16_imm:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, tos
	lsrs tos, tos, #11
	movs r5, #1
	ands tos, r5
	lsls tos, tos, #10
	movs r3, r1
	lsrs r3, r3, #12
	orrs tos, r3
	movs r3, #0xF240
	orrs tos, r3
	push {r0, r1}
	bl _current_comma_16
	pop {r0, r1}
	push_tos
	movs tos, r1
	movs r5, #0xFF
	ands tos, r5
	lsrs r1, r1, #8
	movs r5, #7
	ands r1, r5
	lsls r1, r1, #12
	orrs tos, r1
	movs r5, #0xF
	ands r0, r5
	lsls r0, r0, #8
	orrs tos, r0
	bl _current_comma_16
	pop {pc}

	@@ Compile a move top 16-bit immediate instruction
	define_word "movt-imm,", visible_flag
_asm_movt_imm:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, tos
	lsrs tos, tos, #11
	movs r5, #1
	ands tos, r5
	lsls tos, tos, #10
	movs r3, r1
	lsrs r3, r3, #12
	orrs tos, r3
	ldr r3, =0xF2C0
	orrs tos, r3
	push {r0, r1}
	bl _current_comma_16
	pop {r0, r1}
	push_tos
	movs tos, r1
	movs r5, #0xFF
	ands tos, r5
	lsrs r1, r1, #8
	movs r5, #7
	ands r1, r5
	lsls r1, r1, #12
	orrs tos, r1
	movs r5, #0xF
	ands r0, r5
	lsls r0, r0, #8
	orrs tos, r0
	bl _current_comma_16
	pop {pc}

	@@ Assemble a literal
	define_word "literal,", visible_flag
_asm_literal:
	push {lr}
	movs r0, tos
	pull_tos
	movs r5, #0
	cmp tos, r5
	blt 1f
	movs r5, #0xFF
	cmp tos, r5
	bgt 2f
	push_tos
	movs tos, r0
	bl _asm_mov_imm
	pop {pc}
2:	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm
	pop {pc}
1:	neg tos, tos
	movs r5, #0xFF
	cmp tos, r5
	bgt 3f
	push_tos
	movs tos, r0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	bl _asm_neg
	pop {pc}
3:	ldr r1, =0xFFFF
	cmp tos, r1
	bgt 4f
	push_tos
	movs tos, r0
	push {r0}
	bl _asm_ldr_long_imm
	pop {r0}
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	bl _asm_neg
	pop {pc}
4:	neg tos, tos
	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm
	pop {pc}
	
	@@ Assemble a long load register immediate pseudo-opcode
	define_word "ldr-long-imm,", visible_flag
_asm_ldr_long_imm:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, tos
	ldr r2, =0xFFFF
	ands tos, r2
	mov r2, #0xFF
	cmp tos, r2
	bgt 1f
	push_tos
	mov tos, r0
	push {r0, r1}
	bl _asm_mov_imm
	pop {r0, r1}
2:	ldr r2, =0x7FFF
	cmp r1, r2
	ble 3f
	push_tos
	movs tos, r1
	lsrs tos, tos, #16
	ands tos, r2
	push_tos
	movs tos, r0
	bl _asm_movt_imm
	pop {pc}
1:	push_tos
	movs tos, r0
	push {r0, r1}
	bl _asm_mov_16_imm
	pop {r0, r1}
	b 2b
3:	pop {pc}
	
	.else

	@@ Call a word at an address
	define_word "call,", visible_flag
_asm_call:	
	push {rl}
	bl _current_here
	movs r0, tos
	pull_tos
	movs r1, tos
	subs tos, tos, r0
	ldr r2, =0x003FFFFF
	cmp tos, r2
	bgt 1f
	ldr r2, =0xFFC00000
	cmp tos, r2
	blt 1f
	bl _asm_bl
	pop {pc}
1:	movs tos, r1
	adds tos, #1
	push_tos
	movs tos, #1
	bl _asm_literal
	push_tos
	movs tos, #1
	bl _asm_blx_reg
	pop {pc}

	@@ Compile a bl instruction
	define_word "bl,", visible_flag
_asm_bl:
	push {rl}
	movs r0, tos
	lsrs tos, tos, #12
	ldr r1, =0x7FF
	ands tos, r1
	ldr r2, =0xF000
	orrs tos, r2
	push {r0}
	bl _current_comma_16
	pop {r0}
	push_tos
	movs tos, r0
	lsrs tos, tos, #1
	ldr r2, =0x7FF
	ands tos, r2
	ldr r2, =0xF800
	orrs tos, r2
	bl _current_comma_16
	pop {pc}

	@@ Assemble a literal
	define_word "literal,", visible_flag
_asm_literal:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, #0
	cmp tos, r1
	blt 1f
	movs r1, #0xFF
	cmp tos, r1
	bgt 2f
	push_tos
	movs tos, r0
	bl _asm_mov_imm
	pop {pc}
2:	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm
	pop {pc}
1:	neg tos, tos
	movs r0, #0xFF
	cmp tos, r0
	bgt 2f
	push_tos
	movs tos, r0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	bl _asm_neg
	pop {pc}
2:	push_tos
	movs tos, r0
	push {r0}
	bl _asm_ldr_long_imm
	pop {r0}
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	bl _asm_neg
	pop {pc}

	@@ Assemble a long load register immediate pseudo-opcode
	define_word "ldr-long-imm,", visible_flag
_asm_ldr_long_imm:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, tos
	lsrs r1, r1, #24
	bne 1f
	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm_1st_zero
	pop {pc}
1:	movs r2, tos
	mv tos, r1
	push_tos
	mv tos, r0
	push {r0, r2}
	bl _asm_mov_imm
	pop {r0, r2}
	movs r1, r2
	lsrs r1, r1, #16
	movs r3, #0xFF
	ands r1, r3
	bne 1f
	push_tos
	movs tos, r2
	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm_2nd_zero
	pop {pc}
1:	push_tos
	movs tos, #8
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r1, r2}
	bl _asm_lsl_imm
	pop {r0, r1, r2}
	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	push {r0, r2}
	bl _asm_mov_imm
	pop {r0, r2}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_orr
	pop {r0, r2}
	movs r1, r2
	ldr r1, r1, #8
	movs r3, #0xFF
	ands r1, r3
	bne 1f
	push_tos
	movs tos, r2
	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm_3rd_zero
	pop {pc}
1:	push_tos
	movs tos, #8
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r1, r2}
	bl _asm_lsl_imm
	pop {r0, r1, r2}
	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	push {r0, r2}
	bl _asm_mov_imm
	pop {r0, r2}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_orr
	pop {r0, r2}
	movs r3, #0xFF
	ands r2, r3
	bne 1f
	pop {pc}
1:	push_tos
	movs tos, #8
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_lsl_imm
	pop {r0, r2}
	push_tos
	movs tos, r2
	push_tos
	movs tos, #0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	bl _asm_orr
	pop {pc}

	@@ Assemble a long load register immediate pseudo-opcode
	define_word "ldr-long-imm-1st-zero,", visible_flag
_asm_ldr_long_imm_1st_zero:
	push {lr}
	movs r0, tos
	pull_tos
	movs r2, tos
	movs r1, r2
	lsrs r1, r1, #16
	movs r3, #0xFF
	ands r1, r3
	bne 1f
	push_tos
	movs tos, r2
	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm_1st_2nd_zero
	pop {pc}
1:	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	push {r0, r2}
	bl _asm_mov_imm
	pop {r0, r2}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_orr
	pop {r0, r2}
	movs r1, r2
	ldr r1, r1, #8
	movs r3, #0xFF
	ands r1, r3
	bne 1f
	push_tos
	movs tos, r2
	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm_1st_3rd_zero
	pop {pc}
1:	push_tos
	movs tos, #8
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r1, r2}
	bl _asm_lsl_imm
	pop {r0, r1, r2}
	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	push {r0, r2}
	bl _asm_mov_imm
	pop {r0, r2}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_orr
	pop {r0, r2}
	push_tos
	movs tos, #8
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_lsl_imm
	pop {r0, r2}
	movs r3, #0xFF
	ands r2, r3
	bne 1f
	pop {pc}
1:	push_tos
	movs tos, r2
	push_tos
	movs tos, #0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	bl _asm_orr
	pop {pc}

	@@ Assemble a long load register immediate pseudo-opcode
	define_word "ldr-long-imm-2nd-zero,", visible_flag
_asm_ldr_long_imm_2nd_zero:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, tos
	movs r1, r2
	ldr r1, r1, #8
	movs r3, #0xFF
	ands r1, r3
	bne 1f
	push_tos
	movs tos, r2
	push_tos
	movs tos, r0
	bl _asm_ldr_long_imm_2nd_3rd_zero
	pop {pc}
1:	push_tos
	movs tos, #16
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r1, r2}
	bl _asm_lsl_imm
	pop {r0, r1, r2}
	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	push {r0, r2}
	bl _asm_mov_imm
	pop {r0, r2}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_orr
	pop {r0, r2}
	movs r3, #0xFF
	ands r2, r3
	bne 1f
	pop {pc}
1:	push_tos
	movs tos, #8
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_lsl_imm
	pop {r0, r2}
	push_tos
	movs tos, r2
	push_tos
	movs tos, #0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	bl _asm_orr
	pop {pc}

	@@ Assemble a long load register immediate pseudo-opcode
	define_word "ldr-long-imm-1st-2nd-zero,", visible_flag
_asm_ldr_long_imm_1st_2nd_zero:
	push {lr}
	movs r0, tos
	pull_tos
	movs r2, tos
	movs r1, r2
	ldr r1, r1, #8
	movs r3, #0xFF
	ands r1, r3
	push_tos
	movs tos, r1
	push_tos
	movs tos, #0
	push {r0, r2}
	bl _asm_mov_imm
	pop {r0, r2}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_orr
	pop {r0, r2}
	push_tos
	movs tos, #8
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_lsl_imm
	pop {r0, r2}
	movs r3, #0xFF
	ands r2, r3
	bne 1f
	pop {pc}
1:	push_tos
	movs tos, r2
	push_tos
	movs tos, #0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	bl _asm_orr
	pop {pc}

	@@ Assemble a long load register immediate pseudo-opcode
	define_word "ldr-long-imm-1st-3rd-zero,", visible_flag
_asm_ldr_long_imm_3rd_zero:
	push {lr}
	movs r0, tos
	pull_tos
	movs r2, tos
	movs tos, #8
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_lsl_imm
	pop {r0, r2}
	movs r3, #0xFF
	ands r2, r3
	bne 1f
	pop {pc}
1:	push_tos
	movs tos, r2
	push_tos
	movs tos, #0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	bl _asm_orr
	pop {pc}

	@@ Assemble a long load register immediate pseudo-opcode
	define_word "ldr-long-imm-1st-3rd-zero,", visible_flag
_asm_ldr_long_imm_1st_3rd_zero:
	push {lr}
	movs r0, tos
	pull_tos
	movs r2, tos
	movs tos, #16
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_lsl_imm
	pop {r0, r2}
	movs r3, #0xFF
	ands r2, r3
	bne 1f
	pop {pc}
1:	push_tos
	movs tos, r2
	push_tos
	movs tos, #0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	bl _asm_orr
	pop {pc}

	@@ Assemble a long load register immediate pseudo-opcode
	define_word "ldr-long-imm-2nd-3rd-zero,", visible_flag
_asm_ldr_long_imm_2nd_3rd_zero:
	push {lr}
	movs r0, tos
	pull_tos
	movs r2, tos
	movs tos, #24
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	push {r0, r2}
	bl _asm_lsl_imm
	pop {r0, r2}
	movs r3, #0xFF
	ands r2, r3
	bne 1f
	pop {pc}
1:	push_tos
	movs tos, r2
	push_tos
	movs tos, #0
	push {r0}
	bl _asm_mov_imm
	pop {r0}
	push_tos
	movs tos, #0
	push_tos
	movs tos, r0
	push_tos
	movs tos, r0
	bl _asm_orr
	pop {pc}
	
	.endif
	
	@@ Assemble an unconditional branch
	define_word "b,", visible_flag
_asm_b: push {lr}
	movs r0, tos
	lsrs r0, r0, #8
	movs r1, #7
	ands r0, r1
	orrs r0, #0xE0
	movs r1, #0xFF
	ands tos, r1
	lsls r0, r0, #8
	orrs tos, r0
	bl _current_comma_16
	pop {pc}

	@@ Assemble a branch on equal zero instruction
	define_word "beq,", visible_flag
_asm_beq:
	push {lr}
	ldr r0, =0xD000
	movs r1, #0xFF
	ands tos, r1
	orrs tos, r0
	bl _current_comma_16
	pop {pc}
	
	@@ Assemble a compare to immediate instruction
	define_word "cmp-imm,", visible_flag
_asm_cmp_imm:
	push {lr}
	movs r0, tos
	pull_tos
	movs r1, #7
	ands r0, r1
	movs r1, #0xFF
	ands tos, r1
	lsls r0, r0, #8
	orrs tos, r0
	ldr r0, =0x2800
	orrs tos, r0
	bl _current_comma_16
	pop {pc}

	@@ Assemble a logical shift left immediate instruction
	define_word "lsl-imm,", visible_flag
_asm_lsl_imm:
	push {lr}
	movs r0, tos
	movs r1, #7
	ands r0, r1
	pull_tos
	ands tos, r1
	lsls tos, tos, #3
	orrs r0, tos
	pull_tos
	movs r1, #0x1F
	ands tos, r1
	lsls tos, tos, #6
	orrs tos, r0
	bl _current_comma_16
	pop {pc}

	@@ Assemble an or instruction
	define_word "orr,", visible_flag
_asm_orr:
	push {lr}
	movs r1, #7
	ands tos, r1
	movs r0, tos
	pull_tos
	ands tos, r1
	lsls tos, tos, #3
	orrs tos, r0
	movs r0, #0x43
	lsls r0, r0, #8
	orrs tos, r0
	bl _current_comma_16
	pop {pc}
