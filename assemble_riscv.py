#!/usr/bin/env python3
"""Tiny assembler for the RISC-V subset used in this project.

Supported instructions:
    addi, add, sub, mul, lw, sw, beq, bne, jal, jalr, halt

Output format matches instruction_memory.v ROM lines:
    rom[i] = 32'hXXXXXXXX;
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


REG_ALIASES = {
    "zero": 0,
    "ra": 1,
    "sp": 2,
    "gp": 3,
    "tp": 4,
    "t0": 5,
    "t1": 6,
    "t2": 7,
    "s0": 8,
    "fp": 8,
    "s1": 9,
    "a0": 10,
    "a1": 11,
    "a2": 12,
    "a3": 13,
    "a4": 14,
    "a5": 15,
    "a6": 16,
    "a7": 17,
    "s2": 18,
    "s3": 19,
    "s4": 20,
    "s5": 21,
    "s6": 22,
    "s7": 23,
    "s8": 24,
    "s9": 25,
    "s10": 26,
    "s11": 27,
    "t3": 28,
    "t4": 29,
    "t5": 30,
    "t6": 31,
}


@dataclass
class AsmLine:
    pc: int
    op: str
    args: list[str]
    source: str


def parse_reg(token: str) -> int:
    token = token.strip()
    if token in REG_ALIASES:
        return REG_ALIASES[token]
    if re.fullmatch(r"x([0-9]|[12][0-9]|3[01])", token):
        return int(token[1:])
    raise ValueError(f"Unknown register: {token}")


def parse_imm(token: str) -> int:
    return int(token, 0)


def parse_mem_operand(token: str) -> tuple[int, int]:
    match = re.fullmatch(r"\s*([-+]?(?:0x[0-9a-fA-F]+|\d+))\(([^)]+)\)\s*", token)
    if not match:
        raise ValueError(f"Invalid memory operand: {token}")
    offset = parse_imm(match.group(1))
    base = parse_reg(match.group(2).strip())
    return offset, base


def sign_check(value: int, bits: int, name: str) -> None:
    lo = -(1 << (bits - 1))
    hi = (1 << (bits - 1)) - 1
    if not (lo <= value <= hi):
        raise ValueError(f"{name}={value} does not fit in {bits} signed bits")


def encode_r_type(func7: int, rs2: int, rs1: int, func3: int, rd: int, opcode: int) -> int:
    return (
        ((func7 & 0x7F) << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((func3 & 0x7) << 12)
        | ((rd & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def encode_i_type(imm: int, rs1: int, func3: int, rd: int, opcode: int) -> int:
    sign_check(imm, 12, "imm")
    return (
        ((imm & 0xFFF) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((func3 & 0x7) << 12)
        | ((rd & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def encode_s_type(imm: int, rs2: int, rs1: int, func3: int, opcode: int) -> int:
    sign_check(imm, 12, "imm")
    imm12 = imm & 0xFFF
    return (
        (((imm12 >> 5) & 0x7F) << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((func3 & 0x7) << 12)
        | ((imm12 & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def encode_b_type(offset: int, rs2: int, rs1: int, func3: int, opcode: int) -> int:
    sign_check(offset, 13, "branch offset")
    if offset % 2 != 0:
        raise ValueError(f"Branch offset must be 2-byte aligned, got {offset}")
    imm = offset & 0x1FFF
    return (
        (((imm >> 12) & 0x1) << 31)
        | (((imm >> 5) & 0x3F) << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((func3 & 0x7) << 12)
        | (((imm >> 1) & 0xF) << 8)
        | (((imm >> 11) & 0x1) << 7)
        | (opcode & 0x7F)
    )


def encode_j_type(offset: int, rd: int, opcode: int) -> int:
    sign_check(offset, 21, "jump offset")
    if offset % 2 != 0:
        raise ValueError(f"Jump offset must be 2-byte aligned, got {offset}")
    imm = offset & 0x1FFFFF
    return (
        (((imm >> 20) & 0x1) << 31)
        | (((imm >> 1) & 0x3FF) << 21)
        | (((imm >> 11) & 0x1) << 20)
        | (((imm >> 12) & 0xFF) << 12)
        | ((rd & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def tokenize_line(raw_line: str) -> tuple[str | None, str | None]:
    line = raw_line.split("#", 1)[0].split("//", 1)[0].strip()
    if not line:
        return None, None
    if ":" in line:
        label, rest = line.split(":", 1)
        return label.strip(), rest.strip() or None
    return None, line


def parse_source(text: str) -> tuple[list[AsmLine], dict[str, int]]:
    labels: dict[str, int] = {}
    instructions: list[AsmLine] = []
    pc = 0

    for raw_line in text.splitlines():
        label, body = tokenize_line(raw_line)
        if label is not None:
            if label in labels:
                raise ValueError(f"Duplicate label: {label}")
            labels[label] = pc
        if body is None:
            continue
        parts = body.split(None, 1)
        op = parts[0].lower()
        arg_text = parts[1] if len(parts) > 1 else ""
        args = [arg.strip() for arg in arg_text.split(",")] if arg_text else []
        instructions.append(AsmLine(pc=pc, op=op, args=args, source=body))
        pc += 4

    return instructions, labels


def resolve_label(token: str, labels: dict[str, int]) -> int:
    if token not in labels:
        raise ValueError(f"Unknown label: {token}")
    return labels[token]


def assemble_line(line: AsmLine, labels: dict[str, int]) -> int:
    op = line.op
    args = line.args

    if op == "halt":
        return 0x0000007F
    if op == "addi":
        rd, rs1, imm = parse_reg(args[0]), parse_reg(args[1]), parse_imm(args[2])
        return encode_i_type(imm, rs1, 0b000, rd, 0b0010011)
    if op == "lw":
        rd = parse_reg(args[0])
        imm, rs1 = parse_mem_operand(args[1])
        return encode_i_type(imm, rs1, 0b010, rd, 0b0000011)
    if op == "jalr":
        rd = parse_reg(args[0])
        imm, rs1 = parse_mem_operand(args[1])
        return encode_i_type(imm, rs1, 0b000, rd, 0b1100111)
    if op == "sw":
        rs2 = parse_reg(args[0])
        imm, rs1 = parse_mem_operand(args[1])
        return encode_s_type(imm, rs2, rs1, 0b010, 0b0100011)
    if op == "beq":
        rs1, rs2 = parse_reg(args[0]), parse_reg(args[1])
        offset = resolve_label(args[2], labels) - line.pc
        return encode_b_type(offset, rs2, rs1, 0b000, 0b1100011)
    if op == "bne":
        rs1, rs2 = parse_reg(args[0]), parse_reg(args[1])
        offset = resolve_label(args[2], labels) - line.pc
        return encode_b_type(offset, rs2, rs1, 0b001, 0b1100011)
    if op == "jal":
        rd = parse_reg(args[0])
        offset = resolve_label(args[1], labels) - line.pc
        return encode_j_type(offset, rd, 0b1101111)
    if op == "add":
        rd, rs1, rs2 = parse_reg(args[0]), parse_reg(args[1]), parse_reg(args[2])
        return encode_r_type(0b0000000, rs2, rs1, 0b000, rd, 0b0110011)
    if op == "sub":
        rd, rs1, rs2 = parse_reg(args[0]), parse_reg(args[1]), parse_reg(args[2])
        return encode_r_type(0b0100000, rs2, rs1, 0b000, rd, 0b0110011)
    if op == "mul":
        rd, rs1, rs2 = parse_reg(args[0]), parse_reg(args[1]), parse_reg(args[2])
        return encode_r_type(0b0000001, rs2, rs1, 0b000, rd, 0b0110011)

    raise ValueError(f"Unsupported instruction: {line.source}")


def format_rom(words: list[int]) -> str:
    lines = []
    for index, word in enumerate(words):
        lines.append(f"rom[{index}]  = 32'h{word:08x};")
    return "\n".join(lines)


def render_output(words: list[int], output_format: str) -> str:
    if output_format == "rom":
        return format_rom(words)
    return "\n".join(f"{word:08x}" for word in words)


def main() -> int:
    parser = argparse.ArgumentParser(description="Assemble a tiny RISC-V subset into ROM lines.")
    parser.add_argument("input", help="Assembly source file")
    parser.add_argument(
        "--format",
        choices=["rom", "hex"],
        default="rom",
        help="Output as Verilog ROM assignments or plain hex words",
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Optional output file path. If omitted, prints to stdout.",
    )
    parser.add_argument(
        "--depth",
        type=int,
        help="Optional number of words to emit. Pads remaining words with 00000013 nops.",
    )
    args = parser.parse_args()

    with open(args.input, "r", encoding="utf-8") as asm_file:
        instructions, labels = parse_source(asm_file.read())

    words = [assemble_line(line, labels) for line in instructions]
    if args.depth is not None:
        if len(words) > args.depth:
            raise ValueError(f"Program has {len(words)} words, which exceeds depth {args.depth}")
        words.extend([0x00000013] * (args.depth - len(words)))

    output_text = render_output(words, args.format)
    if args.output:
        output_path = Path(args.output)
        output_path.write_text(output_text + "\n", encoding="utf-8")
    else:
        print(output_text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
