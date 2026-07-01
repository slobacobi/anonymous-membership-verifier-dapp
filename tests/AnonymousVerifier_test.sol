// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol"; 
import "./AnonymousVerifier.sol";

contract AnonymousVerifierTest {
    AnonymousVerifier verifier;

    // Definišemo dva člana
    bytes32 leafA = keccak256(abi.encodePacked("ClanA"));
    bytes32 leafB = keccak256(abi.encodePacked("ClanB"));
    bytes32 computedRoot;

    bytes32 fakeLeaf = keccak256(abi.encodePacked("Haker"));

    function beforeEach() public {
        // Dinamički računamo tačan koren na isti način kako to radi ugovor
        if (leafA <= leafB) {
            computedRoot = keccak256(abi.encodePacked(leafA, leafB));
        } else {
            computedRoot = keccak256(abi.encodePacked(leafB, leafA));
        }
        
        // Pokrećemo ugovor sa dinamički izračunatim tačnim korenom
        verifier = new AnonymousVerifier(computedRoot);
    }

    /// @dev Test 1: Uspešna verifikacija validnog člana skupa
    function testValidProof() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leafB; // Par za leafA je leafB

        // Generišemo jedinstveni nullifier
        bytes32 uniqueNullifier = keccak256(abi.encodePacked("TajnaA"));

        // Ovo sada MORA da prođe jer se koreni 100% poklapaju
        verifier.verifyAttribute(proof, leafA, uniqueNullifier, "Punoletan");
        
        Assert.equal(verifier.nullifiers(uniqueNullifier), true, "Nullifier je trebalo da bude iskoriscen.");
    }

    /// @dev Test 2: Odbijanje nevalidnog dokaza (korisnik koji nije u stablu)
    function testInvalidProof() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leafB;

        bytes32 uniqueNullifier = keccak256(abi.encodePacked("TajnaHaker"));

        try verifier.verifyAttribute(proof, fakeLeaf, uniqueNullifier, "Punoletan") {
            Assert.ok(false, "Ugovor je trebalo da odbije nevalidan dokaz!");
        } catch {
            Assert.ok(true, "Ugovor je uspesno odbio nevalidan dokaz.");
        }
    }

    /// @dev Test 3: Pokušaj ponovne upotrebe istog dokaza (Nullifier zaštita)
    function testDoubleSpendingPrevention() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leafB;

        bytes32 uniqueNullifier = keccak256(abi.encodePacked("TajnaIsta"));

        // Prva verifikacija prolazi
        verifier.verifyAttribute(proof, leafA, uniqueNullifier, "Punoletan");

        // Druga verifikacija sa ISTIM nullifier-om mora da padne
        try verifier.verifyAttribute(proof, leafA, uniqueNullifier, "Punoletan") {
            Assert.ok(false, "Ugovor je trebalo da odbije ponovnu upotrebu istog nullifier-a!");
        } catch {
            Assert.ok(true, "Ugovor je uspesno sprecio ponovnu upotrebu koda.");
        }
    }
}