require! {
    \./addresses.json : { Ethnamed }
    \./Ethnamed.abi.json : abi
}
get-contract-instance = (abi, addr)-> (web3)->
    Contract = web3.eth.contract abi
    Contract.at addr

registry-contract = get-contract-instance abi, Ethnamed

builder = (contract, name)-> (ether, ...args, cb)->
    transaction =
        to: Ethnamed
        value: web3.to-wei(ether, \ether).to-string!
        data: contract.get-data.apply null, args
    web3.eth.send-transaction transaction, cb

module.exports = (web3)->
    contract = registry-contract web3
    
    register-name = builder contract, \registerName
    
    { ...contract, register-name }