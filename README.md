# FlyOnTheWall
A tool for open-sourcing decision making.

We can now use the basic flow on the smart contract:

* anyone can create posts
* anyone apply for posts
* post owner can score applications
* anyone can get winners

Also implemented:
* listing applications for post
* listing all existing posts
* owner of post can change state to closed or open


## Testing Values
```
1. create post:
choose_job, https://bit.ly/3LQwhWY, [remote, salary, culture], [1, 2, 3]


2. apply to post:
0, https://bit.ly/3r5EvRk


3. score application: 
0, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, [5, 5, 5]
```

## Contract Address:
https://goerli.etherscan.io/address/0x151e45c6905a393c28d807b1682f4889a1c7a3e1

## TODO
* Optimize the smart contract
* Build a web frontend for easier use of the smart contract
