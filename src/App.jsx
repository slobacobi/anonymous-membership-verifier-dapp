import { useState } from "react";
import { ethers } from "ethers";
import contractAbi from "./abi.json";

const CONTRACT_ADDRESS = "0x61DD50a7d440311BE7cA6C6FF4F6b28c2D10Be07";

function App() {
  const [account, setAccount] = useState("");
  const [status, setStatus] = useState("");
  const [loading, setLoading] = useState(false);

  // Generisanje listova
  const leafA = ethers.solidityPackedKeccak256(["string"], ["ClanA"]);
  const leafB = ethers.solidityPackedKeccak256(["string"], ["ClanB"]);

  // Dinamičko računanje korena (Root-a) na osnovu sortiranja
  const computedRoot = leafA.toLowerCase() <= leafB.toLowerCase()
    ? ethers.solidityPackedKeccak256(["bytes32", "bytes32"], [leafA, leafB])
    : ethers.solidityPackedKeccak256(["bytes32", "bytes32"], [leafB, leafA]);

  const connectWallet = async () => {
    if (!window.ethereum) {
      setStatus("Molimo instalirajte MetaMask!");
      return;
    }
    try {
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      setAccount(accounts[0]);
      setStatus("Novčanik uspešno povezan!");
    } catch (err) {
      setStatus("Greška pri povezivanju novčanika.");
    }
  };

  const verifyAsAuthorizedMember = async () => {
    if (!account) {
      setStatus("Prvo povežite novčanik!");
      return;
    }

    setLoading(true);
    setStatus("Priprema kriptografskih dokaza...");

    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi, signer);

      // Slanje ispravnog dokaza (susednog lista)
      const proof = [leafB]; 
      const leaf = leafA;
      
      const secret = "slobodanpetkovic123456";
      const nullifier = ethers.solidityPackedKeccak256(["string"], [secret]);
      
      const attribute = "Punoletan";

      setStatus("Potpišite transakciju u MetaMask-u...");

      const tx = await contract.verifyAttribute(proof, leaf, nullifier, attribute);
      
      setStatus("Transakcija poslata! Čeka se potvrda na Sepolia mreži...");
      await tx.wait();

      setStatus("Uspešno verifikovano! Nullifier je iskorišćen, anonimnost očuvana.");
    } catch (err) {
      console.error(err);
      if (err.message.includes("user rejected action")) {
        setStatus("Odbili ste transakciju u MetaMasku.");
      } else {
        setStatus("Verifikacija neuspešna! Proverite da li koren ugovora odgovara korenu aplikacije ili je nullifier iskorišćen.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: "40px", fontFamily: "Arial, sans-serif", textAlign: "center", maxWidth: "600px", margin: "auto" }}>
      <h2>Anonimni Verifikator Članstva</h2>

      {/* PRIVREMENI ISPIS KORENA ZA PROVERU SA REMIXOM
      <div style={{ backgroundColor: "#f0f0f0", padding: "10px", borderRadius: "5px", marginBottom: "20px", wordBreak: "break-all" }}>
        <p style={{ margin: 0, fontSize: "12px" }}><b>Očekivani Merkle Root ugovora:</b></p>
        <code style={{ fontSize: "11px", color: "#555" }}>{computedRoot}</code>
      </div>
      */}

      {account ? (
        <div style={{ backgroundColor: "#eef9ee", padding: "10px", borderRadius: "5px", marginBottom: "20px" }}>
          <p style={{ margin: 0, fontSize: "14px" }}><b>Povezan nalog:</b></p>
          <code style={{ fontSize: "12px" }}>{account}</code>
        </div>
      ) : (
        <button 
          onClick={connectWallet}
          style={{ padding: "10px 20px", fontSize: "16px", cursor: "pointer", backgroundColor: "#007bff", color: "white", border: "none", borderRadius: "5px" }}
        >
          Poveži MetaMask
        </button>
      )}

      <br />

      <button
        onClick={verifyAsAuthorizedMember}
        disabled={loading || !account}
        style={{
          padding: "15px 30px",
          fontSize: "16px",
          cursor: loading || !account ? "not-allowed" : "pointer",
          backgroundColor: loading || !account ? "#ccc" : "#28a745",
          color: "white",
          border: "none",
          borderRadius: "5px",
          marginTop: "10px"
        }}
      >
        {loading ? "Izvršavanje..." : "Dokaži da si Član i Verifikuj"}
      </button>

      <div style={{ marginTop: "30px", padding: "15px", border: "1px solid #ddd", borderRadius: "5px", backgroundColor: "#f9f9f9" }}>
        <h4>Status Aplikacije:</h4>
        <p style={{ fontWeight: "bold", color: status.includes("🎉") || status.includes("uspešno") ? "green" : status.includes("Greška") || status.includes("neuspešna") ? "red" : "black" }}>
          {status || "Čekanje na akciju korisnika..."}
        </p>
      </div>
    </div>
  );
}

export default App;