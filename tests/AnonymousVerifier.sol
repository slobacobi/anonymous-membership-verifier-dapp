// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AnonymousVerifier {
    
    // Vlasnik ugovora (administrator) koji jedini može da ažurira koren stabla
    address public admin;
    
    // Javni kriptografski koren (Merkle Root) skupa ovlašćenih korisnika
    bytes32 public merkleRoot;

    // Mapa koja prati iskorišćene jedinstvene oznake (Nullifiers) radi sprečavanja ponovne upotrebe
    // mapping(nullifier => da li je iskoriscen)
    mapping(bytes32 => bool) public nullifiers;

    // --- DOGAĐAJI (EVENTS) ---
    // Emituju se pri uspešnoj ili neuspešnoj verifikaciji, bez otkrivanja identiteta korisnika
    event VerificationSuccess(bytes32 indexed nullifier, string attribute);
    event VerificationFailed(string reason);
    event RootUpdated(bytes32 newRoot);

    // --- MODIFIKATORI ---
    // Ograničava izvršavanje funkcije samo na administratora (kao u profesorovom objašnjenju)
    modifier onlyAdmin() {
        require(msg.sender == admin, "Samo administrator moze izvrsiti ovu funkciju");
        _;
    }

    // --- KONSTRUKTOR ---
    // Izvršava se samo jednom pri pokretanju ugovora. Postavlja admina i početni Merkle Root
    constructor(bytes32 _initialRoot) {
        admin = msg.sender; // msg.sender je adresa koja radi deploy ugovora
        merkleRoot = _initialRoot;
    }

    /**
     * @dev Eksterna funkcija za administratora da ažurira Merkle Root kada se dodaju novi članovi
     */
    function updateMerkleRoot(bytes32 _newRoot) external onlyAdmin {
        merkleRoot = _newRoot;
        emit RootUpdated(_newRoot);
    }

    /**
     * @dev Glavna funkcija za anonimnu verifikaciju atributa
     * @param proof Niz hash-eva koji čine Merkle dokaz (putanju od lista do korena)
     * @param leaf Hash identiteta korisnika koji se proverava da li je u stablu
     * @param nullifier Jedinstvena oznaka (izvedena iz tajne) koja sprečava dvostruku verifikaciju
     * @param attribute Naziv atributa koji korisnik dokazuje (npr. "Punoletan")
     */
    function verifyAttribute(
        bytes32[] memory proof,
        bytes32 leaf,
        bytes32 nullifier,
        string memory attribute
    ) external {
        
        // 1. KORAK: Provera da li je ovaj nullifier već iskorišćen (Sprečavanje ponovne upotrebe)
        if (nullifiers[nullifier]) {
            emit VerificationFailed("Ovaj dokaz je vec jednom iskoriscen (Nullifier iskoriscen)!");
            require(!nullifiers[nullifier], "Dokaz je vec iskoriscen!");
        }

        // 2. KORAK: Kriptografska verifikacija Merkle dokaza
        // Krećemo od lista (leaf) i penjemo se uz stablo rekonstruišući koren
        bytes32 computedHash = leaf;
        
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            // Sortiramo hash-eve pre spajanja (standardna praksa da redosled levo/desno ne pravi problem)
            if (computedHash <= proofElement) {
                // keccak256 zamenjuje abi.encodePacked za dobijanje hash vrednosti spojenih podataka
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Proveravamo da li je izračunati koren jednak onom koji je admin sačuvao u ugovoru
        if (computedHash != merkleRoot) {
            emit VerificationFailed("Kriptografski dokaz nije validan! Niste clan skupa.");
            require(computedHash == merkleRoot, "Niste clan ovlascenog skupa!");
        }

        // 3. KORAK: Ako su provere prošle, trajno obeležavamo nullifier kao iskorišćen
        nullifiers[nullifier] = true;

        // 4. KORAK: Emitujemo uspešan događaj (Potpuno anonimno, nigde ne beležimo msg.sender!)
        emit VerificationSuccess(nullifier, attribute);
    }
}