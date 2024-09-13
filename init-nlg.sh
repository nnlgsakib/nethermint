#!/bin/bash

# Set key parameters for the blockchain
MONIKER="nlg"
CHAIN_ID="nlg_19923-1"
KEY_NAME="nlg"
KEYRING_BACKEND="os"
TOKEN_DENOM="nlgton"
INITIAL_BALANCE="100000000000000000000000000000000${TOKEN_DENOM}" # 1 billion tokens for the genesis account
SELF_DELEGATION="10000000000000000${TOKEN_DENOM}"    # 1 million tokens for self-delegation
MIN_SELF_DELEGATION="1000"                 # Minimum self-delegation for the validator
COMMISSION_RATE="0.10"
COMMISSION_MAX_RATE="0.20"
COMMISSION_MAX_CHANGE_RATE="0.01"
GENTX_AMOUNT="1000000${TOKEN_DENOM}"        # Amount delegated in the gentx
BLOCK_GAS_LIMIT="2000000000000000"                  # Set a reasonable block gas limit

# Initialize the node with a moniker and chain ID
./nlg init $MONIKER --home node --chain-id $CHAIN_ID

# Add a key for the initial validator
./nlg keys add $KEY_NAME --home node --keyring-backend $KEYRING_BACKEND

# Add the genesis account with a large initial balance
./nlg add-genesis-account $(./nlg keys show $KEY_NAME -a --home node --keyring-backend $KEYRING_BACKEND) $INITIAL_BALANCE --home node

# Generate a genesis transaction for the validator
./nlg gentx $KEY_NAME $GENTX_AMOUNT \
  --home node \
  --chain-id $CHAIN_ID \
  --commission-rate "$COMMISSION_RATE" \
  --commission-max-rate "$COMMISSION_MAX_RATE" \
  --commission-max-change-rate "$COMMISSION_MAX_CHANGE_RATE" \
  --min-self-delegation "$MIN_SELF_DELEGATION" \
  --moniker "$MONIKER" \
  --details "Initial validator for nlg network" \
  --website "https://nlg.com" \
  --identity "" \
  --security-contact "security@nlg.com" \
  --pubkey $(./nlg tendermint show-validator --home node)

# Create the gentx directory if it doesn't exist
mkdir -p node/config/gentx

# Collect genesis transactions
./nlg collect-gentxs --home node

# Update the genesis.json file to use the correct token denom and block gas limit
for field in \
  'app_state["staking"]["params"]["bond_denom"]="'${TOKEN_DENOM}'"' \
  'app_state["crisis"]["constant_fee"]["denom"]="'${TOKEN_DENOM}'"' \
  'app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="'${TOKEN_DENOM}'"' \
  'app_state["mint"]["params"]["mint_denom"]="'${TOKEN_DENOM}'"'; do
  jq ".$field" $PWD/node/config/genesis.json > $PWD/node/config/tmp_genesis.json && mv $PWD/node/config/tmp_genesis.json $PWD/node/config/genesis.json
done

# Set the block gas limit in genesis.json
jq '.consensus_params["block"]["max_gas"]="'${BLOCK_GAS_LIMIT}'"' $PWD/node/config/genesis.json > $PWD/node/config/tmp_genesis.json && mv $PWD/node/config/tmp_genesis.json $PWD/node/config/genesis.json

# Validate the genesis file to ensure everything is correct
./nlg validate-genesis --home node

# Start the node with the necessary configuration
./nlg start --home node \
  --rpc.laddr tcp://0.0.0.0:26657 \
  --p2p.laddr tcp://0.0.0.0:26656 \
  --grpc.address 0.0.0.0:9090 \
  --grpc-web.enable \
  --json-rpc.address 0.0.0.0:8547 \
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
