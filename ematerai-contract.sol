// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EStamp {
    // Struktur untuk menyimpan detail materai
    struct Stamp {
        uint256 id;
        string issuer;
        string description;
        uint256 value;
        address owner;
        bool isValid;
        bytes32 documentHash; // Hash dokumen yang diverifikasi
    }

    // Daftar alamat yang diizinkan untuk menerbitkan materai
    mapping(address => bool) public authorizedIssuers;
    mapping(uint256 => Stamp) public stamps;
    uint256 public stampCount;

    // Event untuk mencatat pembuatan dan transfer materai
    event StampCreated(uint256 id, string issuer, string description, uint256 value, address owner);
    event OwnershipTransferred(uint256 id, address previousOwner, address newOwner);
    event IssuerAuthorized(address issuer);
    event IssuerRevoked(address issuer);

    // Modifier untuk memeriksa apakah penerbit adalah yang terdaftar
    modifier onlyAuthorizedIssuer() {
        require(authorizedIssuers[msg.sender], "Not an authorized issuer");
        _;
    }

    // Fungsi untuk menambahkan penerbit yang diizinkan
    function authorizeIssuer(address _issuer) public {
        authorizedIssuers[_issuer] = true;
        emit IssuerAuthorized(_issuer);
    }

    // Fungsi untuk mencabut izin penerbit
    function revokeIssuer(address _issuer) public {
        authorizedIssuers[_issuer] = false;
        emit IssuerRevoked(_issuer);
    }

    // Fungsi untuk membuat materai baru
    function createStamp(string memory _issuer, string memory _description, uint256 _value, bytes32 _documentHash) public onlyAuthorizedIssuer {
        stampCount++;
        stamps[stampCount] = Stamp(stampCount, _issuer, _description, _value, msg.sender, true, _documentHash);
        emit StampCreated(stampCount, _issuer, _description, _value, msg.sender);
    }

    // Fungsi untuk memvalidasi materai
    function validateStamp(uint256 _id) public view returns (bool) {
        return stamps[_id].isValid;
    }

    // Fungsi untuk mentransfer kepemilikan materai
    function transferOwnership(uint256 _id, address _newOwner) public {
        require(stamps[_id].owner == msg.sender, "You are not the owner");
        require(_newOwner != address(0), "Invalid address");
        address previousOwner = stamps[_id].owner;
        stamps[_id].owner = _newOwner;
        emit OwnershipTransferred(_id, previousOwner, _newOwner);
    }

    // Fungsi untuk memverifikasi dokumen berdasarkan hash
    function verifyDocument(uint256 _id, bytes32 _documentHash) public view returns (bool) {
        return stamps[_id].documentHash == _documentHash;
    }
}
