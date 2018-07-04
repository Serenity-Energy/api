require! {
    \./addresses.json : { Ethnamed }
    \./Ethnamed.abi.json : abi
    \superagent : { post, get }
    \solidity-sha3 : { sha3num }
    \./config.json : { url }
    \./get-verify-email-url.ls
}
get-contract-instance = (web3, abi, addr)->
    new web3.eth.Contract(abi, addr)
extract-signature = (signature)->
    sig = signature.slice 2
    r = \0x + sig.slice 0, 64
    s = \0x + sig.slice 64, 128
    v = \0x + sig.slice 128, 130
    { v, r, s }
get-domain = (name)->
    | name.index-of(\.) > -1 => name
    | _ => "#{name}.ethnamed.io"
verify-email = (emailkey, cb)->
    url = get-verify-email-url emailkey
    err, data <- get url .end
    return cb data.text if err?
    cb null, JSON.parse(data.text)
get-access-key = ({ name, record }, cb)->
    return cb "Name is required" if not name?
    return cb "Record is required" if not record?
    domain = get-domain name
    err, data <- post url .set(\name, domain).set(\record, record).end
    return cb data.text if err?
    cb null, JSON.parse(data.text)
builder-setup-record = (web3, contract)-> ({ amount-ethers, name, record, owner }, cb)->
    err, access-key <- get-access-key { name, record }
    return cb "Owner address is not defined" if not owner?
    return cb err if err?
    return cb "Access keys not found" if not access-key?
    { signature, record, name, length, block-expiry } = access-key
    { v, r, s } = extract-signature signature
    #console.log "\"#{length}\", \"#{name}\", \"#{record}\", \"#{block-expiry}\", \"#{owner}\", \"#{v}\", \"#{r}\", \"#{s}\""
    transaction =
        to: Ethnamed
        gas: 500000
        value: web3.utils.to-wei("#{amount-ethers}", \ether).to-string!
        data: contract.methods.set-or-update-record(length, name, record, block-expiry, owner, v, r, s).encodeABI!
        decoded-data: "setOrUpdateRecord(\"#{length}\", \"#{name}\", \"#{record}\", \"#{block-expiry}\", \"#{owner}\", \"#{v}\", \"#{r}\", \"#{s}\")"
    #console.log transaction
    web3.eth.send-transaction transaction, cb
builder-whois = (web3, contract)-> (record, cb)->
    hash = sha3num record
    contract.methods.whois hash .call cb
builder-verify-record = (web3, contract) -> (name, cb)->
    return cb err if err?
    contract.methods.resolve(get-domain(name)).call cb
builder-send-to = (web3, contract)-> ({ amount-ethers, name }, cb)->
    return cb "Amount ETH is required" if not amount-ethers?
    return cb "Name is required" if not name?
    transaction =
        to: Ethnamed
        gas: 500000
        value: web3.utils.to-wei("#{amount-ethers}", \ether).to-string!
        data: contract.methods.send-to(name).encodeABI!
        decoded-data: "sendTo(\"#{name}\")"
    web3.eth.send-transaction transaction, cb
module.exports = (web3)->
    contract = get-contract-instance web3, abi, Ethnamed
    setup-record = builder-setup-record web3, contract
    verify-record = builder-verify-record web3, contract
    whois = builder-whois web3, contract
    send-to = builder-send-to web3, contract
    { ...contract, setup-record, verify-record, whois, verify-email }