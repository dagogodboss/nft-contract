// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CryptonianWar is Initializable, ERC1155Upgradeable, AccessControlUpgradeable, PausableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable {
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _listId;

    uint256 public collectibleId;
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant LISTER_ROLE = keccak256("LISTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address[] AddressList;

    mapping(address => uint256) WhiteList;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC1155_init("https://dagogo.ipfs.net");
        __AccessControl_init();
        __Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address _receiver, uint256 amount) public {
        uint256 cost = 0.05 ether;
        if(WhiteList[msg.sender] > 0){
            payable(msg.sender).transfer(cost.mul(amount));
           interMint(_receiver, amount);
        }else{
            payable(address(this)).transfer(cost.add(1).mul(amount));
            interMint(_receiver, amount);
        }
    }

    function whiteList(address[] memory allowedList) public onlyRole(LISTER_ROLE){
        for(uint i=0; i<allowedList.length; i++) {
            if(WhiteList[allowedList[i]]==0) { 
                _listId.increment();
                WhiteList[allowedList[i]] = _listId.current();
            }
        }
    }

     function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE)  {
        _setURI(newuri);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
    {
        _mintBatch(to, ids, amounts, data);
    }

    
    // The following functions are overrides required by Solidity.


    function interMint(address _receiver, uint256 amount) internal {
        _mint(_receiver, collectibleId, amount, "");
        collectibleId++;
    }
    function pause() public  onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public  onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    
    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}