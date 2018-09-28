#AES implementation for FPGA

Implementation of AES encryption standard 128, 192 and 256 bits in VHDL based on AES paper, "A Highly Regular and Scalable AES Hardware Architecture" article of Stefan Mangard and "An ASIC Implementation of the AES SBoxes" article of Johannes Wolkerstorfer, Elisabeth Oswald, and Mario Lamberger.


This project works well for Spartan 6 Atlys board. You can recompile it or flash bit file in the list below. 

To communicate with board you can also use this [communicator](https://github.com/riccardo25/aes-communicator) written in C.

For example, after programming Atlys board with bit file, and checked the USB connection with board (for example on ttyS5 port), you have to:

'''
sudo chmod 666 /dev/ttyS5

stty -F /dev/ttyS5 115200

'''

After that, compile aes-communicator with

'''
make communicator
''''

And then execute it

'''
./build/communicator
'''

This will communicate with board and then return data ciphred in aes.