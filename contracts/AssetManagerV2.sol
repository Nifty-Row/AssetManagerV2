/// SPDX-License-Identifier: MIT-0
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./ShareContract.sol";
import "./library/AssetModelV2.sol";

contract AssetManagerV2 is ERC721URIStorage {
    event DEBUG(address str);
    event DEBUG(string str);

    mapping(uint256 => ShareContract) shares;

    ShareContract wallet;

    address owner;

    constructor() ERC721("NSE Art Exchange", "ARTX") {
        owner = msg.sender;
        wallet = new ShareContract(
            "Tether Token 1-1 with local currency",
            "WALLET",
            2**250,
            1,
            msg.sender
        );
        emit DEBUG("Wallet Address");
        emit DEBUG(address(wallet));
    }

    function mint(AssetModelV2.AssetRequest memory ar) external {
        AssetModelV2.validateAsset(ar);
        require(owner == msg.sender);
        _safeMint(msg.sender, ar.tokenId);
        // create an ERC20 Smart contract and assign the shares to issuer
        ShareContract shareContract = new ShareContract(
            ar.name,
            ar.symbol,
            ar.totalQuantity,
            ar.price,
            ar.issuer
        );
        shares[ar.tokenId] = shareContract;
    }

    function ownedShares(uint256 tokenId, address userAddress)
        external
        view
        returns (uint256)
    {
        ShareContract shareContract = shares[tokenId];
        return shareContract.allowance(userAddress, address(this));
    }

    function transferShares(
        uint256 tokenId,
        address recipient,
        uint256 amount
    ) external {
        ShareContract shareContract = shares[tokenId];
        shareContract.transferFrom(msg.sender, recipient, amount);
        // Allow this contract to spend on recipients behalf
        shareContract.allow(recipient, amount);
    }

    function transferTokenOwnership(uint256 tokenId, address recipient)
        external
    {
        ShareContract shareContract = shares[tokenId];
        uint256 sharesOwned = shareContract.allowance(
            msg.sender,
            address(this)
        );

        // first transfer the shares owned by the caller in tokenId
        shareContract.transferFrom(msg.sender, recipient, sharesOwned);
        shareContract.allow(recipient, sharesOwned);
        // then transfer ownership of the token
        safeTransferFrom(msg.sender, recipient, tokenId);
    }

    function walletBalance(address userAddress)
        external
        view
        returns (uint256)
    {
        return wallet.allowance(userAddress, address(this));
    }

    function fundWallet(address recipient, uint256 amount) external {
        require(owner == msg.sender);
        wallet.transferFrom(msg.sender, recipient, amount);
        // Allow this contract to spend on recipients behalf
        wallet.allow(recipient, amount);
    }

    /**
        Caller of the contract is the buyer.
        Buyer transfers amount * price to seller from wallet
        Seller transfers amount to buyer from shares
     */
    function buyShares(
        uint256 tokenId,
        address seller,
        uint256 amount,
        uint256 price
    ) external {
        address buyer = msg.sender;
        wallet.transferFrom(buyer, seller, amount * price);
        // Allow this contract to spend on seller's behalf
        wallet.allow(seller, amount * price);

        ShareContract shareContract = shares[tokenId];
        shareContract.transferFrom(seller, buyer, amount);
        // Allow this contract to spend on buyer's behalf
        shareContract.allow(buyer, amount);
    }

    function tokenShares(uint256 tokenId)
        external
        view
        returns (AssetModelV2.TokenShares memory)
    {
        address tokenOwner = ownerOf(tokenId);
        ShareContract shareContract = shares[tokenId];
        (
            address sharesContract,
            string memory name,
            string memory symbol,
            uint256 totalSupply,
            uint256 issuingPrice
        ) = shareContract.details();
        return
            AssetModelV2.TokenShares({
                tokenId: tokenId,
                owner: tokenOwner,
                sharesContract: sharesContract,
                name: name,
                symbol: symbol,
                totalSupply: totalSupply,
                issuingPrice: issuingPrice
            });
    }
}
