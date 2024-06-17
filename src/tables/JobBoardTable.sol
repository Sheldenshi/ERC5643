pragma solidity ^0.8.20;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {TablelandDeployments} from "@evm-tableland/contracts/utils/TablelandDeployments.sol";
import {SQLHelpers} from "@evm-tableland/contracts/utils/SQLHelpers.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {MoonDAOEntity} from "../ERC5643.sol";


contract JobBoardTable is ERC721Holder, Ownable {
    uint256 private _tableId;
    string private _TABLE_PREFIX;
    MoonDAOEntity public _moonDaoEntity;
    uint256 public currId = 0;
    mapping(uint256 => uint256) public idToEntityId;

    constructor(string memory _table_prefix) Ownable(msg.sender) {
        _TABLE_PREFIX = _table_prefix;
        _tableId = TablelandDeployments.get().create(
            address(this),
            SQLHelpers.toCreateFromSchema(
                "id integer primary key,"
                "title text,"
                "description text,"
                "entityId integer,"
                "contactInfo text",
                _TABLE_PREFIX
            )
        );
    }

    function setMoonDaoEntity(address moonDaoEntity) external onlyOwner{
        _moonDaoEntity = MoonDAOEntity(moonDaoEntity);
    }

    // Let anyone insert into the table
    function insertIntoTable(string memory title, string memory description, uint256 entityId, string memory contactInfo) external {
        require (_moonDaoEntity.isManager(entityId, msg.sender) || owner() == msg.sender, "Only Admin can update");
        string memory setters = string.concat(
                Strings.toString(currId), // Convert to a string
                ",",
                SQLHelpers.quote(title), // Wrap strings in single quotes with the `quote` method
                ",",
                SQLHelpers.quote(description), // Wrap strings in single quotes with the `quote` method
                ",",
                Strings.toString(entityId),
                ",",
                SQLHelpers.quote(contactInfo) // Wrap strings in single quotes with the `quote` method
        );
        TablelandDeployments.get().mutate(
            address(this), // Table owner, i.e., this contract
            _tableId,
            SQLHelpers.toInsert(
                _TABLE_PREFIX,
                _tableId,
                "id,title,description,entityId,contactInfo",
                setters
            )
        );
        idToEntityId[currId] = entityId;
        currId += 1;
    }

    function updateTable(uint256 id, string memory title, string memory description, uint256 entityId, string memory contactInfo) external {
        
        require (_moonDaoEntity.isManager(entityId, msg.sender) || owner() == msg.sender, "Only Admin can update");
        require (idToEntityId[id] == entityId, "You can only update job post by your entity");

        // Set the values to update
        string memory setters = string.concat(
            "title=",
            SQLHelpers.quote(title),
            ",description=",
            SQLHelpers.quote(description),
            ",contactInfo=",
            SQLHelpers.quote(contactInfo)
        );
        // Specify filters for which row to update
        string memory filters = string.concat(
            "id=",
            Strings.toString(id)
        );
        // Mutate a row at `id` with a new `val`
        TablelandDeployments.get().mutate(
            address(this),
            _tableId,
            SQLHelpers.toUpdate(_TABLE_PREFIX, _tableId, setters, filters)
        );
    }

    // Update only the row that the caller inserted
    function updateTableCol(uint256 id, uint256 entityId, string memory colName, string memory val) external {
        require (Strings.equal(colName, "id"), "Cannot update id");
        require (Strings.equal(colName, "entityId"), "Cannot update entityId");
        require (_moonDaoEntity.isManager(entityId, msg.sender) || owner() == msg.sender, "Only Admin can update");

        // Set the values to update
        string memory setters = string.concat(colName, "=", SQLHelpers.quote(val));
        // Specify filters for which row to update
        string memory filters = string.concat(
            "id=",
            Strings.toString(id)
        );
        // Mutate a row at `id` with a new `val`
        TablelandDeployments.get().mutate(
            address(this),
            _tableId,
            SQLHelpers.toUpdate(_TABLE_PREFIX, _tableId, setters, filters)
        );
    }


    // Delete a row from the table by ID 
    function deleteFromTable(uint256 id, uint256 entityId) external {
        require (_moonDaoEntity.isManager(entityId, msg.sender) || owner() == msg.sender, "Only Admin can update");
        require (idToEntityId[id] == entityId, "You can only delete job post by your entity");

        // Specify filters for which row to delete
        string memory filters = string.concat(
            "id=",
            Strings.toString(id)
        );
        // Mutate a row at `id`
        TablelandDeployments.get().mutate(
            address(this),
            _tableId,
            SQLHelpers.toDelete(_TABLE_PREFIX, _tableId, filters)
        );
    }

    // Set the ACL controller to enable row-level writes with dynamic policies
    function setAccessControl(address controller) external onlyOwner{
        TablelandDeployments.get().setController(
            address(this), // Table owner, i.e., this contract
            _tableId,
            controller // Set the controller address—a separate controller contract
        );
    }

    // Return the table ID
    function getTableId() external view returns (uint256) {
        return _tableId;
    }

    // Return the table name
    function getTableName() external view returns (string memory) {
        return SQLHelpers.toNameFromId(_TABLE_PREFIX, _tableId);
    }
}