require! {
    \./addresses.json : { Ethnamed }
    \./Ethnamed.abi.json : abi
    \superagent : { post }
}
url = \http://209.126.69.9
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
    console.log transaction
    web3.eth.send-transaction transaction, cb
verify-version = (contract, cb)->
    version = \v0.001
    err, data <- contract.methods.version!.call
    return cb err if err?
    return cb "Expected version #{version}, actual is #{data}" if data isnt version
    return cb null
builder-verify-record = (web3, contract) -> (name, cb)->
    err <- verify-version contract
    return cb err if err?
    contract.methods.resolve(get-domain(name)).call cb
module.exports = (web3)->
    contract = get-contract-instance web3, abi, Ethnamed
    setup-record = builder-setup-record web3, contract
    verify-record = builder-verify-record web3, contract
    { ...contract, setup-record, verify-record }