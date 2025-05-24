# DOOR
DOOR: Docker - Ollama - Open WebUI - ROCm

## Requirements

**Hardware:**
- AMD GPU

**OS:**
- Linux - Tested with Arch Linux, kernel version 6.14.7-arch1-1

**Software**
- Docker or replacement - tested with [podman](https://podman.io/)
- Docker Compose or replacement - tested with [podman-compose](https://github.com/containers/podman-compose)
- [ROCm](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/)
- Optional: set up [overlayfs](https://docs.kernel.org/filesystems/overlayfs.html)

**.env configuration:**
```dotenv
OPENWEBUI_PORT=<port>
```

## Usage

Run `compose` in this project's main catalog as _rootful_:

```bash
sudo podman-compose up
```

OR

```bash
sudo docker compose up
```