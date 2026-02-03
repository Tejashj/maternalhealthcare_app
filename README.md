Maternal Health Monitoring App

The Maternal Health Monitoring App is a mobile-first solution designed to enhance prenatal care. It enables real-time monitoring of vital signs such as ECG and BPM, while ensuring that all medical records are stored securely on a tamper-proof blockchain ledger. Sensitive files like ultrasound scans are stored in Supabase Cloud Storage, with only access links stored on-chain for efficiency and privacy.

This system helps both patients (continuous monitoring from home) and doctors (secure access to verified health records between visits).

How to Run
1. Clone the Repository
git clone https://github.com/your-username/maternal-health-app.git
cd maternal-health-app

2. Install Dependencies
npm install


3. Configure Environment Variables

Create a .env file in the project root:

SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
ETHEREUM_NODE_URL=your_ethereum_node_url
PRIVATE_KEY=your_wallet_private_key

4. Start the Development Server
npm start


5. Build for Production
npm run build


Frontend: Flutter / React Native

Backend: Node.js / Express

Blockchain: Ethereum

Storage: Supabase
