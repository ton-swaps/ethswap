pragma solidity ^0.5.0;

import './SafeMath.sol';
import './Interfaces.sol';

contract EthTokenToSmthSwaps {

  using SafeMath for uint;

  address public owner;
  uint256 SafeTime = 1 hours; // atomic swap timeOut

  struct Swap {
    address token;
    address payable targetWallet;
    bytes32 secret;
    bytes32 secretHash;
    uint256 createdAt;
    uint256 balance;
  }

  // ETH Owner => Smth Owner => Swap
  mapping(address => mapping(address => Swap)) public swaps;

  // ETH Owner => Smth Owner => secretHash => Swap
  // mapping(address => mapping(address => mapping(bytes32 => Swap))) public swaps;

  constructor () public {
    owner = msg.sender;
  }

  event CreateSwap(address token, address _buyer, address _seller, uint256 _value, bytes32 _secretHash, uint256 createdAt);

  // ETH Owner creates Swap with secretHash
  // ETH Owner make token deposit
  function createSwap(bytes32 _secretHash, address payable _participantAddress, uint256 _value, address _token) public {
    require(_value > 0);
    require(swaps[msg.sender][_participantAddress].balance == uint256(0));
    require(ERC20(_token).transferFrom(msg.sender, address(this), _value));

    swaps[msg.sender][_participantAddress] = Swap(
      _token,
      _participantAddress,
      bytes32(0),
      _secretHash,
      now,
      _value
    );

    emit CreateSwap(_token, _participantAddress, msg.sender, _value, _secretHash, now);
  }
  // ETH Owner creates Swap with secretHash and targetWallet
  // ETH Owner make token deposit
  function createSwapTarget(bytes32 _secretHash, address payable _participantAddress, address payable _targetWallet, uint256 _value, address _token) public {
    require(_value > 0);
    require(swaps[msg.sender][_participantAddress].balance == uint256(0));
    require(ERC20(_token).transferFrom(msg.sender, address(this), _value));

    swaps[msg.sender][_participantAddress] = Swap(
      _token,
      _targetWallet,
      bytes32(0),
      _secretHash,
      now,
      _value
    );

    emit CreateSwap(_token, _participantAddress, msg.sender, _value, _secretHash, now);
  }
  function getBalance(address _ownerAddress) public view returns (uint256) {
    return swaps[_ownerAddress][msg.sender].balance;
  }

  event Withdraw(address _buyer, address _seller, bytes32 _secretHash, uint256 withdrawnAt);
  // Get target wallet (buyer check)
  function getTargetWallet(address tokenOwnerAddress) public view returns (address) {
      return swaps[tokenOwnerAddress][msg.sender].targetWallet;
  }
  // Smth Owner withdraw money and adds secret key to swap
  // Smth Owner receive +1 reputation
  function withdraw(bytes32 _secret, address _ownerAddress) public {
    Swap memory swap = swaps[_ownerAddress][msg.sender];

    require(swap.secretHash == sha256(abi.encodePacked(_secret)));
    require(swap.balance > uint256(0));
    require(swap.createdAt.add(SafeTime) > now);

    ERC20(swap.token).transfer(swap.targetWallet, swap.balance);

    swaps[_ownerAddress][msg.sender].balance = 0;
    swaps[_ownerAddress][msg.sender].secret = _secret;

    emit Withdraw(msg.sender, _ownerAddress, swap.secretHash, now);
  }
  // Token Owner withdraw money when participan no money for gas and adds secret key to swap
  // Smth Owner receive +1 reputation... may be
  function withdrawNoMoney(bytes32 _secret, address participantAddress) public {
    Swap memory swap = swaps[msg.sender][participantAddress];

    require(swap.secretHash == sha256(abi.encodePacked(_secret)));
    require(swap.balance > uint256(0));
    require(swap.createdAt.add(SafeTime) > now);

    ERC20(swap.token).transfer(swap.targetWallet, swap.balance);

    swaps[msg.sender][participantAddress].balance = 0;
    swaps[msg.sender][participantAddress].secret = _secret;

    emit Withdraw(participantAddress, msg.sender, swap.secretHash, now);
  }

  // Smth Owner withdraw money and adds secret key to swap
  // Smth Owner receive +1 reputation
  function withdrawOther(bytes32 _secret, address _ownerAddress, address participantAddress) public {
    Swap memory swap = swaps[_ownerAddress][participantAddress];

    require(swap.secretHash == sha256(abi.encodePacked(_secret)));
    require(swap.balance > uint256(0));
    require(swap.createdAt.add(SafeTime) > now);

    ERC20(swap.token).transfer(swap.targetWallet, swap.balance);

    swaps[_ownerAddress][participantAddress].balance = 0;
    swaps[_ownerAddress][participantAddress].secret = _secret;

    emit Withdraw(participantAddress, _ownerAddress, swap.secretHash, now);
  }

  // ETH Owner receive secret
  function getSecret(address _participantAddress) public view returns (bytes32) {
    return swaps[msg.sender][_participantAddress].secret;
  }

  event Refund(address _buyer, address _seller, bytes32 _secretHash);

  // ETH Owner refund money
  // Smth Owner gets -1 reputation
  function refund(address _participantAddress) public {
    Swap memory swap = swaps[msg.sender][_participantAddress];

    require(swap.balance > uint256(0));
    require(swap.createdAt.add(SafeTime) < now);

    ERC20(swap.token).transfer(msg.sender, swap.balance);
    clean(msg.sender, _participantAddress);

    emit Refund(_participantAddress, msg.sender, swap.secretHash);
  }

  function clean(address _ownerAddress, address _participantAddress) internal {
    delete swaps[_ownerAddress][_participantAddress];
  }
}
