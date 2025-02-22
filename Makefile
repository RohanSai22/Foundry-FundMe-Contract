-include .env

build:; forge build

deploySepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url ${SEP_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv