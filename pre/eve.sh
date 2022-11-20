echo "EVE"
NETWORK="beta"
echo "Creating Config File.."
echo "---" > config.yaml
if [ "$NETWORK" == "potato" ] || [ "$NETWORK" == "bcv1" ] ; then
NETDOM="devnet-0chain.net"
elif [ "$NETWORK" == "ex1" ] || [ "$NETWORK" == "as1" ] ; then
NETDOM="testnet-0chain.net"
else
NETDOM="0chain.net"
fi  
echo "block_worker: https://${NETWORK}.${NETDOM}/dns" >> config.yaml
echo "signature_scheme: bls0chain" >> config.yaml
echo "min_submit: 50" >> config.yaml
echo "min_confirmation: 50" >> config.yaml
echo "confirmation_chain_length: 3" >> config.yaml
echo "max_txn_query: 5" >> config.yaml
echo "query_sleep_time: 5" >> config.yaml
echo "Downloading CLI tools.."
wget https://github.com/0chain/zboxcli/releases/download/v1.3.11/zbox-linux.tar.gz
tar -xvf zbox-linux.tar.gz
rm zbox-linux.tar.gz
wget https://github.com/0chain/zwalletcli/releases/download/v1.1.7/zwallet-linux.tar.gz
tar -xvf zwallet-linux.tar.gz
rm zwallet-linux.tar.gz
echo "Creating Wallet.."
./zbox getbalance --silent --wallet eve.json --config config.yaml --configDir ./ --json
echo "Fauceting Tokens.."
i=1 ; while [ $i -le 5 ] ; do  ./zwallet faucet --methodName pour --input test --silent --wallet eve.json --config config.yaml --configDir ./ --tokens 9 ; ((i++)) ; done
echo "Creating Allocation.."
./zbox newallocation --size 10000000 --lock 5 --data 2 --parity 2 --silent --wallet eve.json --config config.yaml --configDir ./ > allocation_res.txt
ALLOC=$(cut -c 21-<<< $(cat allocation_res.txt))
rm allocation_res.txt
echo -n $ALLOC > allocation.txt
echo "Locking Tokens To Read Pool.."
./zbox rp-lock --tokens 5 --silent --wallet eve.json --config config.yaml --configDir ./
echo "Getting Balance.."
./zwallet getbalance --silent --wallet eve.json --config config.yaml --configDir ./
echo "Getting Wallet Info.."
./zbox getwallet --silent --wallet eve.json --config config.yaml --configDir ./ --json > getwallet.json
SHAREAUTHKEY=$(jq -r .encryption_public_key getwallet.json)
WALLETID=$(jq -r .client_id getwallet.json)
echo WALLETID: $WALLETID
echo SHAREAUTHKEY: $SHAREAUTHKEY
echo -e "\n Please enter adams' authticket: \n"
while : ; do
read -p "Authticket: " authticket
[[ -z $authticket ]] || break
done
AUTHTICKETJSON=$(echo $authticket | base64 --decode)
echo "AUTH: "$AUTHTICKETJSON
FILENAME=$(jq -r .file_name <<< $AUTHTICKETJSON)
echo "FILENAME: "$FILENAME
mkdir downloads
./zbox download --wallet eve.json --config config.yaml --localpath ./downloads/$FILENAME --authticket $authticket --configDir ./ --silent
sha256sum downloads/$FILENAME
