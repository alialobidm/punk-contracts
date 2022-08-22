// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IFlexiPunkTLD.sol";

contract DeprecateTld is Ownable, ReentrancyGuard {
  bool public paused = true;
  uint256 public refundAmount;
  address public immutable deprecatedTld;
  mapping(string => bool) isNotRefundEligible; // mapping(domainName => bool)
  mapping(string => address) altTld; // mapping(tldName => tldAddress)

  // EVENTS
  event RefundClaimed(address indexed user, string indexed domainName);

  // CONSTRUCTOR
  constructor(
    uint256 _refundAmount,
    address _deprecatedTld,
    string memory _altTldName,
    address _altTldAddress
  ) {
    refundAmount = _refundAmount;
    deprecatedTld = _deprecatedTld;
    altTld[_altTldName] = _altTldAddress;
  }

  // WRITE
  
  /// @notice Refund a deprecated domain (if eligible) and mint a new one
  function refund(
    string memory _domainName,
    string memory _newDomainName,
    string memory _altTldName
  ) external nonReentrant returns(uint256 tokenId) {
    require(!paused, "Contract paused");

    IFlexiPunkTLD tldContract = IFlexiPunkTLD(deprecatedTld);

    // check if _msgSender() owns the domain name
    require(_msgSender() == tldContract.getDomainHolder(_domainName), "Transition: Sender is not domain holder.");

    // get domain ID
    (, uint256 _tokenId, , ) = tldContract.domains(_domainName);

    // transfer domain from _msgSender() to this contract address
    tldContract.transferFrom(_msgSender(), address(this), _tokenId);

    // if eligible, send refund
    if (!isNotRefundEligible[_domainName]) {
      (bool success, ) = _msgSender().call{value: refundAmount}("");
      require(success, "Failed to send refund to msg sender");
    }

    // mint a new domain
    IFlexiPunkTLD newTldContract = IFlexiPunkTLD(altTld[_altTldName]);
    tokenId = newTldContract.mint{value: newTldContract.price()}(_newDomainName, _msgSender(), address(0));

    emit RefundClaimed(_msgSender(), _domainName);
  }

  // OWNER

  /// @notice Add a domain name from non-eligible domains list
  function addNonEligibleDomains(string[] calldata _notEligibleDomains) external onlyOwner {
    for (uint256 i = 0; i < _notEligibleDomains.length;) {
      isNotRefundEligible[_notEligibleDomains[i]] = true;

      unchecked { ++i; }
    }
  }  
  
  /// @notice Remove a domain name from non-eligible domains list
  function removeNonEligibleDomains(string[] calldata _notEligibleDomains) external onlyOwner {
    for (uint256 i = 0; i < _notEligibleDomains.length;) {
      isNotRefundEligible[_notEligibleDomains[i]] = false;

      unchecked { ++i; }
    }
  }

  /// @notice Add alternative TLD to mint
  function addAltTld(string calldata _tldName, address _tldAddress) external onlyOwner {
    altTld[_tldName] = _tldAddress;
  }

  /// @notice Remove alternative TLD to mint
  function removeAltTld(string calldata _tldName) external onlyOwner {
    delete altTld[_tldName];
  }

  /// @notice Change refund amount
  function changeRefundAmount(uint256 _newRefundAmount) external onlyOwner {
    refundAmount = _newRefundAmount;
  }

  /// @notice Recover any ERC-20 token mistakenly sent to this contract address
  function recoverERC20(address tokenAddress_, uint256 tokenAmount_, address recipient_) external onlyOwner {
    IERC20(tokenAddress_).transfer(recipient_, tokenAmount_);
  }

  /// @notice Recover any ERC-721 token mistakenly sent to this contract address
  function recoverERC721(address tokenAddress_, uint256 tokenId_, address recipient_) external onlyOwner {
    IERC721(tokenAddress_).transferFrom(address(this), recipient_, tokenId_);
  }

  /// @notice Toggle the paused state of this contract
  function togglePaused() external onlyOwner {
    paused = !paused;
  }

  /// @notice Withdraw ETH from contract
  function withdraw() external onlyOwner {
    (bool success, ) = owner().call{value: address(this).balance}("");
    require(success, "Failed to withdraw ETH from contract");
  }

  // RECEIVE & FALLBACK
  receive() external payable {}
  fallback() external payable {}

}