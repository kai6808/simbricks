# Use I40e NICs, ns3 bridge network, and (unsynchronized) Qemu simulator.

from simbricks.orchestration.experiments import Experiment
from simbricks.orchestration.nodeconfig import (
    I40eLinuxNode,
    NMServer,
    NMClient,
)
from simbricks.orchestration.simulators import QemuHost, I40eNIC, NS3BridgeNet

# create experiment
e = Experiment(name="network-measurement")
e.checkpoint = True

# create network
network = NS3BridgeNet()
network.sync_mode = 1
e.add_network(network)

# Create server
server_config = I40eLinuxNode()
server_config.ip = "10.0.0.1"
server_config.memory = 8192  # 8GB RAM
server_config.cores = 20  # 20 CPU cores
server_config.app = NMServer()
server = QemuHost(server_config)
server.name = "server"
e.add_host(server)

# Attach server's NIC
server_nic = I40eNIC()
server_nic.sync_mode = 1
e.add_nic(server_nic)
server.add_nic(server_nic)
server_nic.set_network(network)

# Create client
client_config = I40eLinuxNode()
client_config.ip = "10.0.0.2"
client_config.memory = 8192  # 8GB RAM
client_config.cores = 20  # 20 CPU cores
client_config.app = NMClient(server_ip="10.0.0.1")
client = QemuHost(client_config)
client.name = "client"
client.wait = True
e.add_host(client)

# Attach client's NIC
client_nic = I40eNIC()
e.add_nic(client_nic)
client.add_nic(client_nic)
client_nic.set_network(network)

# Set network latencies
eth_latency = 50 * 10**3  # 50 us
network.eth_latency = eth_latency
client_nic.eth_latency = eth_latency
server_nic.eth_latency = eth_latency

experiments = [e]
