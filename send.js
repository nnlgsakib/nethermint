const { ethers } = require('ethers');

// Set up your provider (replace with your node's JSON-RPC endpoint)
const provider = new ethers.providers.JsonRpcProvider('http://localhost:8547');

// Wallet private key (ensure this is a test account and keep your private key secure)
const privateKey = '6F2762ACDBFF669210389784C4BD6C875927AEF78E26E4248B35E7244B605805';
const wallet = new ethers.Wallet(privateKey, provider);

// The recipient address (replace with the recipient's address)
const recipient = '0x00002c7fb19cd479c66D5022E2BBaeE6aD650Eb5';

// Set up the transaction details
const tx = {
    to: recipient,                         // Recipient address
    value: ethers.utils.parseEther('10000'), // Sending 1.0 'nlgton' tokens (adjust as necessary)
    gasPrice: ethers.utils.parseUnits('1.0', 'gwei'), // Optional gas price
    gasLimit: 21000                        // Gas limit for basic ETH transfer
};

async function sendTransaction() {
    try {
        // Get sender's balance before sending the transaction
        const balanceBefore = await provider.getBalance(wallet.address);
        console.log('Balance before transaction:', ethers.utils.formatEther(balanceBefore), 'nlgton');

        // Sign and send the transaction
        const transactionResponse = await wallet.sendTransaction(tx);
        console.log('Transaction sent:', transactionResponse);

        // Wait for the transaction to be mined
        const receipt = await transactionResponse.wait();
        console.log('Transaction mined:', receipt);

        // Get sender's balance after the transaction
        const balanceAfter = await provider.getBalance(wallet.address);
        console.log('Balance after transaction:', ethers.utils.formatEther(balanceAfter), 'nlgton');
    } catch (error) {
        console.error('Error sending transaction:', error);
    }
}

// Call the function to send the transaction
sendTransaction();