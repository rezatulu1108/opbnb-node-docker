#!/bin/sh
set -eou
apk add wget
if [ "$NETWORK_NAME" == "testnet" ]; then
  if [ ! -f $BEDROCK_DATADIR/genesis.json ]; then
    wget -O $BEDROCK_DATADIR/genesis.json https://raw.githubusercontent.com/bnb-chain/opbnb/develop/assets/testnet/genesis.json
  else
     echo "genesis.json exists."
  fi
fi

if [ "$NETWORK_NAME" == "mainnet" ]; then
  if [ ! -f $BEDROCK_DATADIR/genesis.json ]; then
    wget -O $BEDROCK_DATADIR/genesis.json https://raw.githubusercontent.com/bnb-chain/opbnb/develop/assets/mainnet/genesis.json
  else
     echo "genesis.json exists."
  fi
fi

if [ ! -d $BEDROCK_DATADIR/geth ]; then
  exec geth --datadir $BEDROCK_DATADIR init $BEDROCK_DATADIR/genesis.json
else
   echo "$BEDROCK_DATADIR/geth exists."
fi

# Start op-geth.
exec geth \
  --datadir="$BEDROCK_DATADIR" \
  --verbosity=3 \
  --http \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=net,eth,engine \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8545 \
  --ws.origins="*" \
  --ws.api=eth,engine \
  --syncmode=full \
  --maxpeers=10 \
  --networkid=$CHAIN_ID \
  --miner.gaslimit=150000000 \
  --triesInMemory=32 \
  --txpool.globalslots=10000 \
  --txpool.globalqueue=5000 \
  --txpool.accountqueue=200 \
  --txpool.accountslots=200 \
  --cache 32000 \
  --cache.preimages \
  --allow-insecure-unlock \
  --authrpc.addr="0.0.0.0" \
  --authrpc.port="8551" \
  --authrpc.vhosts="*" \
  --authrpc.jwtsecret=./jwt.txt \
  --gcmode=archive \
  --metrics \
  --metrics.port 6060 \
  --metrics.addr 0.0.0.0 \
  --rollup.sequencerhttp=$L2_RPC
