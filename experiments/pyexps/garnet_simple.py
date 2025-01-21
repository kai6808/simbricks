# Use I40e NICs, ns3 bridge network, and (unsynchronized) Qemu simulator.
# The benchmark is from Garnet, where the server runs with 256 MB index.
# The workflow is:
#   1. start the Garnet server on the first node
#   2. start the Garnet client on the second node
#   3. run the performance test benchmark
# Results of the benchmark are stored in the following path:
# <simbricks_experiment_dir>/out/garnet_simple/client/tmp/guest/garnet_results.txt

from simbricks.orchestration.experiments import Experiment
from simbricks.orchestration.nodeconfig import (
    GarnetI40eLinuxNode,
    GarnetServer,
    GarnetClient,
)
from simbricks.orchestration.simulators import QemuHost, I40eNIC, NS3BridgeNet

# create experiment
e = Experiment(name="garnet-simple")
e.checkpoint = True

# create network
network = NS3BridgeNet()
e.add_network(network)

# Create server
server_config = GarnetI40eLinuxNode()
server_config.ip = "10.0.0.1"
server_config.memory = 8192  # 8GB RAM
server_config.cores = 4  # 4 CPU cores
server_config.app = GarnetServer()
server = QemuHost(server_config)
server.name = "server"
e.add_host(server)

# Attach server's NIC
server_nic = I40eNIC()
e.add_nic(server_nic)
server.add_nic(server_nic)
server_nic.set_network(network)

# Create client
client_config = GarnetI40eLinuxNode()
client_config.ip = "10.0.0.2"
client_config.memory = 4096  # 4GB RAM
client_config.cores = 4  # 4 CPU cores
client_config.app = GarnetClient(server_ip="10.0.0.1")
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
eth_latency = 500 * 10**3  # 500 us
network.eth_latency = eth_latency
client_nic.eth_latency = eth_latency
server_nic.eth_latency = eth_latency

experiments = [e]
