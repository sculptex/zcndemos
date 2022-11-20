echo "ADAM"
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
./zwallet getbalance --silent --wallet adam.json --config config.yaml --configDir ./ --json > getwallet.json
echo "Fauceting Tokens.."
i=1 ; while [ $i -le 5 ] ; do  ./zwallet faucet --methodName pour --input test --silent --wallet adam.json --config config.yaml --configDir ./ --tokens 9 ; ((i++)) ; done
echo "Creating Allocation.."
./zbox newallocation --size 10000000 --lock 5 --data 2 --parity 2 --silent --wallet adam.json --config config.yaml --configDir ./ > allocation_res.txt
ALLOC=$(cut -c 21-<<< $(cat allocation_res.txt))
#echo -n $ALLOC > allocation.txt
echo "Locking Tokens To Read Pool.."
./zbox rp-lock --tokens 5 --silent --wallet adam.json --config config.yaml --configDir ./
echo "Getting Balance.."
./zwallet getbalance --silent --wallet adam.json --config config.yaml --configDir ./
#echo "Getting Wallet Info.."
#./zbox getwallet --silent --wallet adam.json --config config.yaml --configDir ./ --json > getwallet.json
#SHAREAUTHKEY=$(jq -r .encryption_public_key getwallet.json)
#echo -n $SHAREAUTHKEY > shareauthkey.txt
filename="FALSE"
while [[ ! -f $FILENAME ]] ; do
read -p "Filename: " FILENAME
done
echo "Uploading Encrypted File.."
./zbox upload --wallet adam.json --config config.yaml --encrypt --allocation $ALLOC --localpath $FILENAME --remotepath /$FILENAME --configDir ./ --silent 
echo -e "\n Please enter eve's wallet details: \n"
while : ; do
read -p "Wallet ID: " eveid
[[ -z $eveid ]] || break
done
while : ; do
read -p "EncPubKey: " eveencpubkey
[[ -z $eveencpubkey ]] || break
done
echo "Generating Share.."
./zbox share --wallet adam.json --config config.yaml --clientid $eveid --encryptionpublickey $eveencpubkey --allocation $ALLOC --remotepath /$FILENAME --configDir ./ --silent > auth_res.txt
AUTH=$(cut -c 13-<<< $(cat auth_res.txt))
rm auth_res.txt
echo "AUTH: "$AUTH
echo -n $AUTH > authticket.txt
sha256sum $FILENAME
