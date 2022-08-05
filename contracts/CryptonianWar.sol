// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CryptonianWar is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155BurnableUpgradeable,
    ERC1155SupplyUpgradeable,
    IERC1155ReceiverUpgradeable
{
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _listId;
    // mapping(uint256 => mapping(address => uint256)) private _balances;

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant LISTER_ROLE = keccak256("LISTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address[] AddressList;

    mapping(address => uint256) WhiteList;

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event OneToManyBatchMint(
        address indexed operator,
        address indexed from,
        address[] to,
        uint256[] ids,
        uint256[] values
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(LISTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function initialize() public initializer {
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

    function mint(
        address[] memory _receiver,
        uint256[] memory amount,
        uint256[] memory ids
    ) public onlyRole(MINTER_ROLE) returns (bool status) {
        for (uint256 i = 0; i < _receiver.length; i++) {
            _mint(_receiver[i], ids[i], amount[i], "");
        }
    }

    function mintManyToMany(
        address[] memory _receiver,
        uint256[] memory amounts,
        uint256[] memory ids
    ) public onlyRole(MINTER_ROLE) {
        _mintBatch(msg.sender, ids, amounts, "");
        setApprovalForAll(address(this), true);
        // batch transafer nft  sc to receivers
        for (uint256 i = 0; i < _receiver.length; i++) {
            safeTransferFrom(msg.sender, _receiver[i], ids[i], amounts[i], "");
        }
    }

    function oneToManyMint(
        address[] memory _receiver,
        uint256[] memory amounts,
        uint256[] memory ids
    ) public onlyRole(MINTER_ROLE) {
        require(ids.length == _receiver.length, "Crytonian-War: ids and _receiver length mismatch");
        address operator = _msgSender();
        for (uint256 i = 0; i < _receiver.length; i++) {
            address to = _receiver[i];
            bytes memory data = '';
        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

            _balances[ids[i]][to] = 1;
            _afterTokenTransfer(operator, address(0), to, ids, amounts, data);
        }
        emit OneToManyBatchMint(operator, address(0), _receiver, ids, amounts);
    }

    function whiteList(address[] memory allowedList)
        public
        onlyRole(LISTER_ROLE)
    {
        for (uint256 i = 0; i < allowedList.length; i++) {
            if (WhiteList[allowedList[i]] == 0) {
                _listId.increment();
                WhiteList[allowedList[i]] = _listId.current();
            }
        }
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
        whenNotPaused
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC1155Upgradeable,
            AccessControlUpgradeable,
            IERC165Upgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override(IERC1155ReceiverUpgradeable) returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override(IERC1155ReceiverUpgradeable) returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }
}
