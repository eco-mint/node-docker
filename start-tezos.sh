#!/bin/sh
# Starts the Tezos node client

# if we are on mainnet, use known ACL config. on other networks we are lenient.
init_node() {
	tezos-node identity generate 26
	if [[ $network == "mainnet" ]]; then
		rm -rf /home/tezos/.tezos-node/config.json
		mv /home/tezos/config.json /home/tezos/.tezos-node/config.json
		tezos-node config init --config-file=/home/tezos/.tezos-node/config.json \
			--rpc-addr="0.0.0.0:$rpcport" \
			--net-addr="0.0.0.0:$netport" \
			--connections=$connections \
			--network=$network \
			--history-mode=full
	else
		tezos-node config init "$@" \
			--rpc-addr="0.0.0.0:$rpcport" \
			--allow-all-rpc="0.0.0.0:$rpcport" \
			--net-addr="0.0.0.0:$netport" \
			--connections=$connections \
			--network=$network \
			--history-mode=full \
			--cors-origin='*' \
			--cors-header 'Origin, X-Requested-With, Content-Type, Accept, Range, GET, POST'
	fi

	if [ $? -ne 0 ]; then
		echo "Node failed to be configured; exiting."
		exit 1
	fi
}

start_node() {
	tezos-node run
    if [ $? -ne 0 ]; then
    	echo "Node failed to start; exiting."
    	exit 1
	fi
}

s3_sync() {
	# If the current1 key exists, node1 is the most current set of blockchain data
	echo "A 404 error below is expected and nothing to be concerned with."
	aws s3api head-object --request-payer requester --bucket $chainbucket --key current1
	if [ $? -eq 0 ]; then
		s3key=node1
	else
		s3key=node2
	fi
	aws s3 sync --request-payer requester --region $region s3://$chainbucket/$s3key /home/tezos/.tezos-node
}

# main

init_node
s3_sync
start_node