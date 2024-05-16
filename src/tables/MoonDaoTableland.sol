pragma solidity ^0.8.20;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {TablelandDeployments} from "@evm-tableland/contracts/utils/TablelandDeployments.sol";
import {SQLHelpers} from "@evm-tableland/contracts/utils/SQLHelpers.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract MoonDaoCitizenTableland is ERC721Holder, Ownable {
    uint256 private _tableId;
    string private _TABLE_PREFIX;

    constructor(string memory _table_prefix) Ownable(msg.sender) {
        _TABLE_PREFIX = _table_prefix;
        _tableId = TablelandDeployments.get().create(
            address(this),
            SQLHelpers.toCreateFromSchema(
                "id integer primary key,"
                "name text,"
                "description text,"
                "image text,"
                "location text,"
                "discord text,"
                "twitter text,"
                "website text,"
                "view text",
                _TABLE_PREFIX
            )
        );
    }

    // Let anyone insert into the table
    function insertIntoTable(uint256 id, string memory name, string memory description, string memory image, string memory location, string memory discord, string memory twitter, string memory website, string memory _view) external {
        string memory setters = string.concat(
            string.concat(
            Strings.toString(id),
            ",",
            SQLHelpers.quote(name),
            ",",
            SQLHelpers.quote(description),
            ",",
            SQLHelpers.quote(image)
            ),
            ",",
            SQLHelpers.quote(location),
            ",",
            SQLHelpers.quote(discord),
            ",",
            SQLHelpers.quote(twitter),
            ",",
            SQLHelpers.quote(website),
            ",",
            SQLHelpers.quote(_view)
        );

        TablelandDeployments.get().mutate(
            address(this), // Table owner, i.e., this contract
            _tableId,
            SQLHelpers.toInsert(
                _TABLE_PREFIX,
                _tableId,
                "id,name,description,image,location,discord,twitter,website,view",
                setters
            )
        );
    }

    function updateTable(uint256 id, string memory name, string memory description, string memory image, string memory location, string memory discord, string memory twitter,string memory website, string memory _view) external {
        // Set the values to update
        string memory setters = string.concat(
            "name=",
            SQLHelpers.quote(name),
            ",description=",
            SQLHelpers.quote(description),
            ",image=",
            SQLHelpers.quote(image),
            ",location=",
            SQLHelpers.quote(location),
            ",discord=",
            SQLHelpers.quote(discord),
            ",twitter=",
            SQLHelpers.quote(twitter),
            ",website=",
            SQLHelpers.quote(website),
            ",view=",
            SQLHelpers.quote(_view)
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
    function updateTableCol(uint256 id, string memory colName, string memory val) external {
        // Set the values to update
        string memory setters = string.concat(colName, SQLHelpers.quote(val));
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
    function deleteFromTable(uint256 id) external {
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