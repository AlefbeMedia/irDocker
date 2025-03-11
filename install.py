import os
import subprocess
import threading
import time

def show_progress():
    spinstr = '|/-\\'
    idx = 0
    while True:
        print(f' [{spinstr[idx % len(spinstr)]}]', end='\r')
        idx += 1
        time.sleep(0.1)

def install_docker():
    subprocess.run('curl -fsSL https://get.docker.com | sh', shell=True, check=True)

def configure_docker():
    os.makedirs('/etc/docker', exist_ok=True)
    with open('/etc/docker/daemon.json', 'w') as f:
        f.write('{\n  "registry-mirrors": ["https://docker.iranserver.com"]\n}')
    subprocess.run(['systemctl', 'daemon-reload'], check=True)
    subprocess.run(['systemctl', 'restart', 'docker'], check=True)

if __name__ == "__main__":
    progress_thread = threading.Thread(target=show_progress)
    progress_thread.daemon = True
    progress_thread.start()
    
    install_docker()
    configure_docker()

    print("All tasks completed successfully.")
