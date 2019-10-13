# Simple Linux x86-64 listening socket
A listening socket will be opened on the port 8080. It will wait for connection and print the received information.

## Run the code
1. Go in the project folder
2. Install yasm if needed with `sudo apt install yasm`
3. `yasm -f elf64 listen.asm`
4. `ld listen.o -o listen`
5. Run with `./listen`

## Test it
1. open a new terminal
2. Install netcat if needed with `sudo apt install netcat`
3. Connect to port 8080 `netcat localhost 8080`
4. Write something and press enter
5. You should see what you wrote in the terminal where you launched `./listen`
