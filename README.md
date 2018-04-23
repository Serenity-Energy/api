### Ethnamed Registry API


[Website](http://ethnamed.io) | [Collaborate](https://ide.c9.io/askucher/registrant-dapp) | [Discuss](https://t.me/ethnamed)

#### Use API

```
npm i ethnamed
```

```Javascript


var web3 = if window ? window.web3 : require('web3');

var ethnamed = require('ethnamed')(window.web3);

var showResult = function(err, result) {
    console.log(err, result);
}


// REGISTER NAME 
//please topup the account before because each address costs

var ethers = 0.01; // Please check the pricing on ethnamed.io

ethnamed.registerName(ethers, 'nickname', '0x123...', showResult);


// CHANGE ADDRESS
//Assign another address to nickname

ethnamed.changeAddress('nickname', '0x123...', showResult);


// TRANSFER OWNERSHIP
//Assign another owner

ethnamed.transferOwnership('nickname', '0x123...', showResult);

```


#### Start DAPP Server

![Demo](http://res.cloudinary.com/nixar-work/image/upload/v1521280043/Screen_Shot_2018-03-17_at_11.46.42.png)


Install
```
npm run setup
npm run compile
```

Start the Ganache blockchain
```
npm run blockchain
```

Deploy contracts 
```
npm run deploy
```

Start the DAPP
```
npm run start
```



-----------------

ethnamed.io