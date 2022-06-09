# 
# File: asm2bin.py
# 
# Description: Simple script to convert assembly programs to a bit sequence
#              that can be loaded into memory. The output is a verilog file
#              that can be loaded with $loadmemb.
# 
# Date: 05/21/2019
# 

# TODO:
#   - Right now, for loads and stores, the opening and closing brackets should be right next
#     to the numbers (i.e., no spaces in between)
#   - The immediates are not optional
#   - Fix the error messages for branches (Labels HAVE BEEN implemented)
#   - Implement .data statements
#   - The arguments for CMP are switched. Check if this happen for more instructions, and fix the asm code

import sys
import numpy

if len(sys.argv) > 2:
    raise SystemExit('ERROR: asm2bin.py takes at most one input: the name of the file containing the assembly code. If no filename is given, it is assumed to be \'test.asm\'')

if len(sys.argv) == 2:
    input_filename = sys.argv[1]
    if (input_filename.find('.') != -1):
        output_filename = input_filename[0:input_filename.find('.')] + '.v'
    else:
        output_filename = input_filename + '.v'
else:
    input_filename = 'test.asm'
    output_filename = 'test.v'

print('Input file: ' + input_filename)
print('Output file: ' + output_filename)

# Opening the output file for writing
output_file = open(output_filename,"w+")

# Used to keep track of the line number, to report possible syntax errors
line_number = 0

# Used to keep track of the memory addresses
labels_dictionary = {}
instruction_number = 0

# In a first pass, we'll create the labels dictionary
with open(input_filename) as input_file:
    for line in input_file:
        # Updating the line number, replacing tabs, commas and other characters with spaces, and converting to lowercase
        line_number = line_number + 1;
        line = line.lower()
        line = line.replace(',', ' ')
        line = line.replace('\t', ' ')
        line = line.replace('\n', ' ')
        
        # Ignoring comments (they begin with //)
        if (line.find('//') != -1):
            # If the entire line is a comment, we ignore it
            if line.find('//') == 0:
                line = ''
            else:
                line = line[0:line.find('//')-1]

        # Splitting the line into words separated by spaces
        instruction = line.split()
        # Ignoring empty lines
        if len(instruction) != 0:
            # If the instruction is not a label, increment the 
            if instruction[0][-1] != ':':
                instruction_number = instruction_number + 1
            
            # Updating the labels dictionary:
            if instruction[0][-1] == ':':
                # Labels should not take any input parameters
                if len(instruction) != 1:
                    raise SystemExit('ERROR: Labels should not take any arguments (line ' + str(line_number) + ')')
                # If the label already exists, throw an error
                if instruction[0][0:-1] in labels_dictionary:
                    raise SystemExit('ERROR: Label ' + instruction[0][0:-1]  + ' already exists (line ' + str(line_number) + ')')
                # Add the label to the dictionary
                labels_dictionary[instruction[0][0:-1]] = instruction_number
        # end of label
# end of the first pass

# Used to keep track of the line number, to report possible syntax errors
line_number = 0

# Used to keep track of the memory addresses
instruction_number = 0

# In a second pass, we translate the input file and write the result to the output file
with open(input_filename) as input_file:
    for line in input_file:
        # Updating the line number, replacing tabs, commas and other characters with spaces, and converting to lowercase
        line_number = line_number + 1;
        line = line.lower()
        line = line.replace(',', ' ')
        line = line.replace('\t', ' ')
        line = line.replace('\n', ' ')
        
        # Ignoring comments (they begin with //)
        if (line.find('//') != -1):
            # If the entire line is a comment, we ignore it
            if line.find('//') == 0:
                line = ''
            else:
                line = line[0:line.find('//')-1]

        # Splitting the line into words separated by spaces
        instruction = line.split()
        # Ignoring empty lines
        if len(instruction) != 0:
            # If the instruction is not a label, increment the 
            if instruction[0][-1] != ':':
                instruction_number = instruction_number + 1
            
            # The following is equivalent to a case statement on instruction[0]. Sadly, python
            # has no case statement on its own.

# label
            if instruction[0][-1] == ':':
                # Do nothing. The first pass took care of labels
                pass
# end of label

# movs
            elif instruction[0] == 'movs':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 3:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an integer')
                if ( int(instruction[1]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' only operates on registers 0 to 7')
                if (instruction[2][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The second argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #)')
                if ( not instruction[2][1:].isdigit() ):
                    output_file.close()
                    raise SystemExit('ERROR: The second argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'shouldbe an immediate (which should be preceded by #)')
                if ( int(instruction[2][1:]) > 255 ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate of \'' + instruction[0] + '\' on line ' + str(line_number) + ' Should be less than 256')

                # Writing to the output file
                output_file.write('00100' + numpy.binary_repr(int(instruction[1]), width=3) + numpy.binary_repr(int(instruction[2][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of movs

# mov
            elif instruction[0] == 'mov':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 3:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: Rd argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an integer from 0 to 7')
                if ( int(instruction[2]) > 15 ):
                    output_file.close()
                    raise SystemExit('ERROR: Rm argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an integer from 0 to 15')

                # Writing to the output file
                output_file.write('010001100' + numpy.binary_repr(int(instruction[2]), width=4) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of mov

# adds
            elif instruction[0] == 'adds':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # There are two kinds of ADDS instruction, depending on the presence of an immediate
                if instruction[3][0] == '#':
                    # Operands have the correct formatting
                    if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3][1:].isdigit()):
                        output_file.close()
                        raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers, except for the # in the immediate')
                    if ( int(instruction[1]) > 7 ) or (int(instruction[2]) > 7 ) or (int(instruction[3][1:]) > 7 ):
                        output_file.close()
                        raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' only operates on registers 0 to 7, and the immediate should not be bigger than 7')
                    # Writing to the output file
                    output_file.write('0001110' + numpy.binary_repr(int(instruction[3][1:]), width=3) + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
                else:
                    # Operands have the correct formatting
                    if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3].isdigit()):
                        output_file.close()
                        raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers (the third one may be preceded by # if it is an immediate)')
                    if ( int(instruction[1]) > 7 ) or (int(instruction[2]) > 7 ) or (int(instruction[3]) > 7 ):
                        output_file.close()
                        raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' only operates on registers 0 to 7')
                    # Writing to the output file
                    output_file.write('0001100' + numpy.binary_repr(int(instruction[3]), width=3) + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of adds

# add
            elif instruction[0] == 'add':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[3][1:].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an integer')
                if ( int(instruction[3][1:]) > 127 ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should not be greater than 127')
                if (instruction[3][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The third argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #)')
                if ( instruction[1] != 'sp' ) or ( instruction[2] != 'sp' ):
                    output_file.close()
                    raise SystemExit('ERROR: The second and third arguments of \'' + instruction[0] + '\' on line ' + str(line_number) + ' Should be \'sp\'')

                # Writing to the output file
                output_file.write('101100000' + numpy.binary_repr(int(instruction[3][1:]), width=7) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of add

# subs
            elif instruction[0] == 'subs':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # There are two kinds of SUBS instruction, depending on the presence of an immediate
                if instruction[3][0] == '#':
                    # Operands have the correct formatting
                    if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3][1:].isdigit()):
                        output_file.close()
                        raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers, except for the # in the immediate')
                    if ( int(instruction[1]) > 7 ) or (int(instruction[2]) > 7 ) or (int(instruction[3][1:]) > 7 ):
                        output_file.close()
                        raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' only operates on registers 0 to 7, and the immediate should not be bigger than 7')
                    # Writing to the output file
                    output_file.write('0001111' + numpy.binary_repr(int(instruction[3][1:]), width=3) + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
                else:
                    # Operands have the correct formatting
                    if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3].isdigit()):
                        output_file.close()
                        raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers (the third one may be preceded by # if it is an immediate)')
                    if ( int(instruction[1]) > 7 ) or (int(instruction[2]) > 7 ) or (int(instruction[3]) > 7 ):
                        output_file.close()
                        raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' only operates on registers 0 to 7')
                    # Writing to the output file
                    output_file.write('0001101' + numpy.binary_repr(int(instruction[3]), width=3) + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of subs

# sub
            elif instruction[0] == 'sub':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[3][1:].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an integer')
                if ( int(instruction[3][1:]) > 127 ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should not be greater than 127')
                if (instruction[3][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The third argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #)')
                if ( instruction[1] != 'sp' ) or ( instruction[2] != 'sp' ):
                    output_file.close()
                    raise SystemExit('ERROR: The second and third arguments of \'' + instruction[0] + '\' on line ' + str(line_number) + ' Should be \'sp\'')

                # Writing to the output file
                output_file.write('101100001' + numpy.binary_repr(int(instruction[3][1:]), width=7) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of sub

# cmp
            elif instruction[0] == 'cmp':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 3:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[2]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100001010' + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of cmp

# ands
            elif instruction[0] == 'ands':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 3:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[2]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100000000' + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of ands

# eors
            elif instruction[0] == 'eors':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 3:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[2]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100000001' + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of eors

# orrs
            elif instruction[0] == 'orrs':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 3:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[2]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100001100' + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of orrs

# mvns
            elif instruction[0] == 'mvns':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 3:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[2]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100001111' + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of mvns

# lsls
            elif instruction[0] == 'lsls':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) != int(instruction[2]) ):
                    output_file.close()
                    raise SystemExit('ERROR: The first two arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be equal (they\'re both Rd)')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[3]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100000010' + numpy.binary_repr(int(instruction[3]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of lsls

# lsrs
            elif instruction[0] == 'lsrs':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) != int(instruction[2]) ):
                    output_file.close()
                    raise SystemExit('ERROR: The first two arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be equal (they\'re both Rd)')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[3]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100000011' + numpy.binary_repr(int(instruction[3]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of lsrs

# asrs
            elif instruction[0] == 'asrs':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) != int(instruction[2]) ):
                    output_file.close()
                    raise SystemExit('ERROR: The first two arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be equal (they\'re both Rd)')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[3]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100000100' + numpy.binary_repr(int(instruction[3]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of asrs

# rors
            elif instruction[0] == 'rors':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: Arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be integers')
                if ( int(instruction[1]) != int(instruction[2]) ):
                    output_file.close()
                    raise SystemExit('ERROR: The first two arguments for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be equal (they\'re both Rd)')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[3]) > 7 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7')

                # Writing to the output file
                output_file.write('0100000111' + numpy.binary_repr(int(instruction[3]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of rors

# str
            elif instruction[0] == 'str':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if instruction[2][0] != '[':
                    output_file.close()
                    raise SystemExit('ERROR: The format for \'' + instruction[0] + '\' on line ' + str(line_number) + ' is STR Rd, [Rn, #<im5>]')
                instruction[2] = instruction[2][1:]
                if instruction[3][-1] != ']':
                    output_file.close()
                    raise SystemExit('ERROR: The format for \'' + instruction[0] + '\' on line ' + str(line_number) + ' is STR Rd, [Rn, #<im5>]')
                instruction[3] = instruction[3][:-1]
                if (instruction[3][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The third argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #)')
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3][1:].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: The format for \'' + instruction[0] + '\' on line ' + str(line_number) + ' is STR Rd, [Rn, #<im5>], where Rd, Rn and <im5> are integers')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[2]) > 7 ) or ( int(instruction[3][1:]) > 31 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7, and the immediate should not be greater than 32')

                # Writing to the output file
                output_file.write('01100' + numpy.binary_repr(int(instruction[3][1:]), width=5) + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of str

# ldr
            elif instruction[0] == 'ldr':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 4:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if instruction[2][0] != '[':
                    output_file.close()
                    raise SystemExit('ERROR: The format for \'' + instruction[0] + '\' on line ' + str(line_number) + ' is STR Rd, [Rn, #<im5>]')
                instruction[2] = instruction[2][1:]
                if instruction[3][-1] != ']':
                    output_file.close()
                    raise SystemExit('ERROR: The format for \'' + instruction[0] + '\' on line ' + str(line_number) + ' is STR Rd, [Rn, #<im5>]')
                instruction[3] = instruction[3][:-1]
                if (instruction[3][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The third argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #)')
                if (not instruction[1].isdigit()) or (not instruction[2].isdigit()) or (not instruction[3][1:].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: The format for \'' + instruction[0] + '\' on line ' + str(line_number) + ' is STR Rd, [Rn, #<im5>], where Rd, Rn and <im5> are integers')
                if ( int(instruction[1]) > 7 ) or ( int(instruction[2]) > 7 ) or ( int(instruction[3][1:]) > 31 ):
                    output_file.close()
                    raise SystemExit('ERROR: \'' + instruction[0] + '\' on line ' + str(line_number) + ' operates exclusively on registers 0 to 7, and the immediate should not be greater than 32')

                # Writing to the output file
                output_file.write('01101' + numpy.binary_repr(int(instruction[3][1:]), width=5) + numpy.binary_repr(int(instruction[2]), width=3) + numpy.binary_repr(int(instruction[1]), width=3) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of ldr

# beq
            elif instruction[0] == 'beq':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '0000' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of beq

# bne
            elif instruction[0] == 'bne':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '0001' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bne

# bcs
            elif instruction[0] == 'bcs':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '0010' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bcs

# bcc
            elif instruction[0] == 'bcc':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '0011' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bcc

# bmi
            elif instruction[0] == 'bmi':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '0100' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bmi

# bpl
            elif instruction[0] == 'bpl':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '0101' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bpl

# bvs
            elif instruction[0] == 'bvs':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '0110' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bvs

# bvc
            elif instruction[0] == 'bvc':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '0111' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bvc

# bhi
            elif instruction[0] == 'bhi':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '1000' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bhi

# bls
            elif instruction[0] == 'bls':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '1001' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bls

# bge
            elif instruction[0] == 'bge':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '1010' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bge

# blt
            elif instruction[0] == 'blt':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '1011' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of blt

# bgt
            elif instruction[0] == 'bgt':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '1100' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bgt

# ble
            elif instruction[0] == 'ble':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '1101' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of ble

# bal
            elif instruction[0] == 'bal':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**7 -1 ) or ( int(instruction[1][1:]) < -2**7 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**7) + ' and ' + str(2**7 - 1) + '.')

                # Writing to the output file
                output_file.write('1101' + '1110' + numpy.binary_repr(int(instruction[1][1:]), width=8) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bal

# b
            elif instruction[0] == 'b':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**10 -1 ) or ( int(instruction[1][1:]) < -2**10 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**10) + ' and ' + str(2**10 - 1) + '.')

                # Writing to the output file
                output_file.write('11100' + numpy.binary_repr(int(instruction[1][1:]), width=11) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of b

# bl
            elif instruction[0] == 'bl':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                # If the argument is a label, transform it into an immediate
                if (instruction[1][0] != '#'):
                    if not ( instruction[1] in labels_dictionary ):
                        raise SystemExit('ERROR: Label \'' + instruction[1] + '\' on line ' + str(line_number) + ' does not exist')
                    new_immediate = labels_dictionary[instruction[1]] - instruction_number + 1
                    instruction[1] = '#' + str(new_immediate)
                    line = instruction[0] + ' ' + instruction[1]
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #) NOTE: labels have not been implemented yet')
                if ( not(instruction[1][1:].isdigit()) and(not(instruction[1][1] == '-' and instruction[1][2:].isdigit()) )):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be an immediate (i.e., an integer preceded by #) NOTE: labels have not been implemented yet')
                if ( ( int(instruction[1][1:]) > 2**5 -1 ) or ( int(instruction[1][1:]) < -2**5 ) ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be between ' + str(-2**5) + ' and ' + str(2**5 - 1) + '.')

                # Writing to the output file
                output_file.write('0100010100' + numpy.binary_repr(int(instruction[1][1:]), width=6) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bl

# bx
            elif instruction[0] == 'bx':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 2:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                # Operands have the correct formatting
                if (not instruction[1].isdigit()):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should be a register')
                if ( int(instruction[1]) > 15 ):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + ' should not be greater than 15 (there are only 16 registers)')

                # Writing to the output file
                output_file.write('010001110' + numpy.binary_repr(int(instruction[1]), width=4) + '000    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of bx

# noop
            elif instruction[0] == 'noop':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 1:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))
                
                # Writing to the output file
                output_file.write('1011111100000000    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of noop

# encr
            elif instruction[0] == 'encr':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 3:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Operands have the correct formatting
                if (instruction[1][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #)')
                if ( not instruction[1][1:].isdigit() ):
                    output_file.close()
                    raise SystemExit('ERROR: The first argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should be preceded by #)')
                if ( int(instruction[1][1:]) > 127 ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate of \'' + instruction[0] + '\' on line ' + str(line_number) + ' Should be less than 128')
                if (instruction[2][0] != '#'):
                    output_file.close()
                    raise SystemExit('ERROR: The second argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'should be an immediate (which should start with #)')
                if ( not instruction[2][1:].isdigit() ):
                    output_file.close()
                    raise SystemExit('ERROR: The second argument for \'' + instruction[0] + '\' on line ' + str(line_number) + 'shouldbe an immediate (which should be preceded by #)')
                if ( int(instruction[2][1:]) > 127 ):
                    output_file.close()
                    raise SystemExit('ERROR: The immediate of \'' + instruction[0] + '\' on line ' + str(line_number) + ' Should be less than 128')

                # Writing to the output file
                output_file.write('1000' + numpy.binary_repr(int(instruction[1][1:]), width=6) + numpy.binary_repr(int(instruction[2][1:]), width=6) + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of encr

# ecog
            elif instruction[0] == 'ecog':
                # Catching syntax errors, and exiting if there is one:
                # Enough number of arguments
                if len(instruction) != 1:
                    output_file.close()
                    raise SystemExit('ERROR: Wrong number of arguments for \'' + instruction[0] + '\' on line ' + str(line_number))

                # Writing to the output file
                output_file.write('0000000000000000' + '    // ' + line + ' (line ' + str(line_number) + ', memory address ' + str(instruction_number-1) + ')\n')
# end of ecog

# Default
            else:
                # If the instruction is not on the previous list (i.e., it is not a valid instruction), throw
                # an error and exit
                output_file.close()
                raise SystemExit('ERROR: Unrecognized instruction \'' + instruction[0] + '\' on line ' + str(line_number))

# Closing the output file
output_file.close()

print('The program was successfully translated')
