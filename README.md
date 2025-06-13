# automatic-lua-loader
This is an installer script that Loads the PS5 UMTX Exploit and the elf_loader from the Lua savegame automatically whenever the game is ready. You can install it natively (eg. on a Raspberry Pi) or in a Docker container. You can find the Lua exploit right here: [Remote Lua Loader](https://github.com/shahrilnet/remote_lua_loader).

How it works:
1. Your device checks if port 9026 is open to determine whether the game is ready. 
2. It sends the UMTX exploit followed by the elf_loader.
3. (Optional) sends a Killgame Payload. The following games should be supported:
    - Raspberry Cube (CUSA16074)
    - Aibeya (CUSA17068)
    - Hamidashi Creative (CUSA27389)
    - Hamidashi Creative Demo (CUSA27390)
    - Aikagi Kimi to Issho ni Pack (CUSA16229)
    - Aikagi 2 (CUSA19556)
    - IxSHE Tell (CUSA17112)
    - Nora Princess and Stray Cat Heart HD (CUSA13303)
    - Jinki Resurrection (CUSA25179)
    - Jinki Resurrection Demo (CUSA25180)
    - Fuyu Kiss (CUSA29745)
4. (Optional) sends etaHEN or kstuff.
    - It will download the latest version of the selected payload (etaHEN.bin from [LM's GitHub releases](https://github.com/etaHEN/etaHEN/releases/latest/) or kstuff.elf from [Echo Stretch's GitHub releases](https://github.com/EchoStretch/kstuff/releases/latest/)) and send it automatically.
5. It waits until the ELF loader (port 9021) is closed to start the process all over again OR your server will shut down. 

## Configuration options
### Required:
1. `-ps5_ip=10.0.0.2`
- Define your PS5 IP.

### Optional:
2. `-killgame=on|off`<br/>
- default = off
- When enabled: The server automatically sends a Payload to the PS5 after the elfldr is loaded, which kills the game process. <br/>

3. `-continue=shutdown|ping`
- default = ping
- Here you can decide what your server will do after the exploit is loaded. You can choose between shutdown and ping. When ping is selected your server will wait until the elfldr isn't running anymore and then start the jailbreak process again. 

4. `-inject=none|etaHEN|kstuff`
- default = none
- automatically loads the selected payload


## Native installation
You can just copy and paste the following command into your terminal (eg., via SSH). You can also use this command to update the UMTX & elf_loader payloads. It should be compatible with all Debian-based OSs; it was tested on Ubuntu and Raspberry Pi OS. <br>
Here is the command syntax, [] = optional: 

`./install.sh -ps5_ip=YOURPS5IP [-killgame=on|off] [-continue=shutdown|ping] [-inject=none|etaHEN|kstuff]`

And here is an example install command: 
<br>

```sh
sudo apt update
sudo apt install -y bash git wget curl jq socat python3
wget https://raw.githubusercontent.com/BenNoxXD/automatic-lua-loader/refs/heads/main/install.sh
sudo chmod +x install.sh
sudo ./install.sh -ps5_ip=10.0.0.2 -killgame=on -continue=ping -inject=etaHEN
```

### Usage
If you are using a Raspberry Pi, it's recommended to connect it to one of the PS5's USB power ports. Now the Raspberry Pi will automatically turn on whenever your PS5 boots up. 
<br>

### Uninstall:
```sh
systemctl stop lualoader
systemctl disable lualoader
rm /etc/systemd/system/lualoader.service
rm -r /opt/automatic-lua-loader
```

## Docker installation
Make sure you have [Docker](https://docs.docker.com/engine/install/) installed. You can check it like this: `docker -v`.
Now you can download this Dockerfile:
<br>

```sh
wget https://raw.githubusercontent.com/BenNoxXD/automatic-lua-loader/refs/heads/main/Dockerfile
```

<br>

Then run the following commands to build the image and deploy the container.
<br>

```sh
docker build \
--build-arg ps5_ip=10.0.0.2 \
--build-arg killgame=on \
--build-arg continue=ping \
--build-arg inject=etaHEN \
-t automatic-lua-loader .

docker run -d -t --name PS5-Lua-Loader --restart always automatic-lua-loader
```