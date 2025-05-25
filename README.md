# DOOR
DOOR: Docker - Ollama - Open WebUI - ROCm

## Requirements

**Hardware:**
- AMD GPU

**OS:**
- Linux - Tested with Arch Linux, kernel version 6.14.7-arch1-1

**Software:**
- Docker or equivalent (e.g., podman)
- Docker Compose or equivalent (e.g., podman-compose)
- ROCm
- overlayfs (recommended for Docker volume issues)

**Note:** ROCm installation instructions can be found in the [Installation Guide](https://docs.amd.com/rocm/rocm-install-guide.html).

## Configuration

The compose file can be configured via `.env` file:

```dotenv
OPENWEBUI_PORT=<port>
CONTEXT_QUANT_TYPE=<f16|q8_0|q4_0>
```

## Usage without installation

Run `compose` as root.

### Start

```bash
sudo docker compose [-f <path-to-docker-compose.yaml>] [--env-file <path-to-dot.env>] up
```

### Stop

```bash
sudo docker compose [-f <path-to-docker-compose.yaml>] [--env-file <path-to-dot.env>] down
```

## Installation and Configuration

### Getting Started
1. **Customize configuration:**  
   Create `.env` file in this directory to set parameters (e.g., `OPENWEBUI_PORT`, `CONTEXT_QUANT_TYPE`).

2. **Run setup script:**  
   ```bash
   # Setup without specifying Docker runtime
   ./setup.sh

   # Setup with specified Docker runtime (e.g., podman-compose)
   ./setup.sh podman-compose
   ```

   This installs required dependencies, configures environment variables, and sets up the service.

3. **Verify installation:**
   ```bash
   # Verify service status
   sudo systemctl status door-llm

   # Check logs
   journalctl -u door-llm.service  | tail -f -n 50
   ```

## Troubleshooting

### Podman UID/GID Pool Exhaustion

This is a known Podman issue: [https://github.com/containers/podman/issues/12715](https://github.com/containers/podman/issues/12715)  

Add `subuid`/`subguid` pools and run `podman system migrate`.

### Permission Errors

Ensure you're running commands with `sudo` when necessary.

### Missing Dependencies

Verify ROCm and Docker/Podman are properly installed.

### Docker Volume Issues 

If using Docker, ensure `overlayfs` is enabled in your kernel.
