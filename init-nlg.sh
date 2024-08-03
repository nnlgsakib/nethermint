#!/bin/bash

# Initialize the node with a moniker and chain ID
nlg init nlg --home node --chain-id nlg_19923-1

# Add a key for the initial validator
nlg keys add nlg --home node 

# Add the genesis account with a large initial balance
nlg add-genesis-account $(nlg keys show nlg -a --home node --keyring-backend os) 51000000nlgton --home node

# Generate a genesis transaction for the validator
nlg gentx nlg 100nlgton \
  --home node \
  --chain-id nlg_19923-1 \
  --commission-rate "0.10" \
  --commission-max-rate "0.20" \
  --commission-max-change-rate "0.01" \
  --min-self-delegation "10" \
  --moniker "nlg" \
  --details "Initial validator for nlg network" \
  --website "https://nlg.com" \
  --identity "" \
  --security-contact "security@nlg.example.com" \
  --pubkey $(nlg tendermint show-validator --home node)

# Collect genesis transactions
nlg collect-gentxs --home node

# Update the genesis.json file to use nlgton
for field in \
  'app_state["staking"]["params"]["bond_denom"]="nlgton"' \
  'app_state["crisis"]["constant_fee"]["denom"]="nlgton"' \
  'app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="nlgton"' \
  'app_state["mint"]["params"]["mint_denom"]="nlgton"'; do
  jq ".$field" $PWD/node/config/genesis.json > $PWD/node/config/tmp_genesis.json && mv $PWD/node/config/tmp_genesis.json $PWD/node/config/genesis.json
done

# Validate the genesis file
nlg validate-genesis --home node

# Start the node with various configurations
nlg start --home node \
  --rpc.laddr tcp://0.0.0.0:26657 \
  --p2p.laddr tcp://0.0.0.0:26656 \
  --grpc.address 0.0.0.0:9090 \
  --grpc-web.enable \
  --json-rpc.address 0.0.0.0:8545 \
  --json-rpc.ws-address 0.0.0.0:8546 \
  --json-rpc.enable \
  --json-rpc.api eth,net,web3,debug \
  --json-rpc.block-range-cap 10000 \
  --json-rpc.txfee-cap 1 \
  --json-rpc.logs-cap 10000 \
  --json-rpc.gas-cap 25000000 \
  --evm.max-tx-gas-wanted 2000000 \
  --evm.tracer json \
   --api.enable true 
 --api.address 0.0.0.0:1317
