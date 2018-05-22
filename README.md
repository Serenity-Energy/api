### Ethnamed Registry API


[Website](http://ethnamed.io) | [Discuss](https://t.me/ethnamed)

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

// CHECK NAME

ethnamed.verifyRecord("yourname", showResult);  // yourname == yourname.ethnamed.io

// REGISTER NAME
// You can set of update record by yourself once you get the 

var request = {
    amountEthers: 0.01,                     //=> Please checkout the pricing table on ethnamed.io
    name: "yourname.ethnamed.io",           //=> It could be a different domain like microsoft.com, ethername.io, ...
    record: '0x123...'                      //=> Verification Record with Standard ETH_ADDRESS,BTC_ADDRESS,...
};

// 1. In case when you use custom domain please send this request only when you put the meta tag in to the head of your website `yourname.domain.io`
// <meta property='ethnamed' content='0x123...'>

// 2. In case you use nickname.ethnamed.io you can just do nothing for verification

ethnamed.setupRecord(request, showResult);


// TRANSFER OWNERSHIP
// Assign another owner when you sell the domain name

ethnamed.transferOwnership("yourname.ethnamed.io", '0x123...', showResult);

```

-----------------

ethnamed.io