# golang 1.23 installation

wget https://go.dev/dl/go1.23.7.linux-amd64.tar.gz
sudo tar -xzvf go1.23.7.linux-amd64.tar.gz -C /usr/local
echo export PATH=$HOME/go/bin:/usr/local/go/bin:$PATH >> ~/.profile
source ~/.profile
go version
sudo rm -rf go1.23.7.linux-amd64.tar.gz


# Clone cri-dockerd repository

git clone https://github.com/Mirantis/cri-dockerd.git ~/cri-dockerd
cd ~/cri-dockerd

# Build and install cri-dockerd
mkdir -p bin
go build -o bin/cri-dockerd

# Move binary to system path
sudo install -m 0755 bin/cri-dockerd /usr/local/bin/

# Set up systemd service
sudo cp -a packaging/systemd/* /etc/systemd/system/
sudo sed -i 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable --now cri-docker.service