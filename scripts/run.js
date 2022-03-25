// Build a script to run our contract
// So, to test a smart contract we've got to do a bunch of stuff right. Like: compile, deploy, then execute.
// Our script will make it really easy to iterate on our contract really fast :).

const main = async () => {
    const [owner, randomPerson] = await hre.ethers.getSigners();
    // This will actually compile our contract and generate the necessary files we need to work with our contract under the artifacts directory.
    const waveContractFactory = await hre.ethers.getContractFactory(
        "WavePortal"
    );

    // Hardhat will create a local Ethereum network for us, but just for this contract. Then, after the script completes it'll destroy that local network. So, every time you run the contract, it'll be a fresh blockchain. What's the point? It's kinda like refreshing your local server every time so you always start from a clean slate which makes it easy to debug errors.
    // when we deploy our contract to the blockchain (which we do when we run waveContractFactory.deploy()) our functions become available to be called on the blockchain because we used that special public keyword on our function.

    const waveContract = await waveContractFactory.deploy({
        value: hre.ethers.utils.parseEther("0.1"),
    });
    await waveContract.deployed();
    console.log("Contract addy:", waveContract.address);
    // This will deploy our contract to the blockchain and wait for it to be mined.
    console.log("Contract deployed to:", waveContract.address);
    console.log("Contract deployed by:", owner.address);

    /*
     * Get Contract balance
     */
    let contractBalance = await hre.ethers.provider.getBalance(
        waveContract.address
    );
    console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
    );

    let waveTxn;

    await waveContract.getTotalWaves();
    waveTxn = await waveContract.wave("hi");
    await waveTxn.wait();

    await waveContract.getTotalWaves();
    waveTxn = await waveContract.connect(randomPerson).wave("hi randomPerson1");
    await waveTxn.wait();

    /*
     * Get Contract balance to see what happened!
     */
    contractBalance = await hre.ethers.provider.getBalance(
        waveContract.address
    );
    console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
    );

    await waveContract.getTotalWaves();
    waveTxn = await waveContract.connect(randomPerson).addFriend();
    await waveTxn.wait();
    waveTxn = await waveContract.connect(randomPerson).wave("hi randomPerson2");
    await waveTxn.wait();
    const allWaves = await waveContract.getAllWaves();
    console.log(allWaves);
};

// Well, every time you run a terminal command that starts with npx hardhat you are getting this hre object built on the fly using the hardhat.config.js specified in your code! This means you will never have to actually do some sort of import into your files like:
// const hre = require("hardhat")

const runMain = async () => {
    try {
        await main();
        process.exit(0); // exit Node process without error
    } catch (error) {
        console.log(error);
        process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
    }
    // Read more about Node exit ('process.exit(num)') status codes here: https://stackoverflow.com/a/47163396/7974948
};

runMain();
