// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FYP_Contract is Ownable {
    struct Vendor {
        string name;
        string companyName;
        uint256 venderNumber;
        string venderEmail;
        string companyAddress;
        uint256 registerationdate;
        uint256 registerationtime;
        address vendorAddress;
        bool isRegistered;
    }

    struct Product {
        uint256 productId;
        string productName;
        string description;
        uint256 price;
        uint256 stock;
        string category;
        uint256 addedTime;
        bytes32 productCode; // <== unique identifier for tracking
    }

    uint256 public TotalVenders = 0;
    uint256 public TotalProducts = 0;

    // Vendor address => Vendor info
    mapping(address => Vendor) public vendors;

    // Product code => vendor address
    mapping(bytes32 => address) public productCodeToVendor;

    // Vendor address => array of products
    mapping(address => Product[]) public vendorProducts;

    // Counter for product IDs (global or per vendor)
    uint256 private nextProductId = 1;

    event VendorRegistered(
        address indexed vendorAddress,
        string name,
        string companyName,
        uint256 joiningDate
    );

    event ProductAdded(
        address indexed vendorAddress,
        uint256 productId,
        string productName,
        uint256 price
    );

    constructor() Ownable(msg.sender) {}

    function registerVendor(
        string memory _name,
        string memory _companyName,
        uint256 _number,
        string memory _email,
        string memory _VenderCompanyAddress
    ) public {
        require(!vendors[msg.sender].isRegistered, "Vendor already registered");
        require(bytes(_name).length > 0, "Name required");
        require(bytes(_companyName).length > 0, "Company name required");

        vendors[msg.sender] = Vendor({
            name: _name,
            companyName: _companyName,
            venderNumber: _number, // or increment a global counter if you want
            venderEmail: _email,
            companyAddress: _VenderCompanyAddress,
            registerationdate: block.timestamp, // current timestamp
            registerationtime: block.timestamp, // same as date, or remove one field from struct
            vendorAddress: msg.sender,
            isRegistered: true
        });
        TotalVenders++;

        emit VendorRegistered(msg.sender, _name, _companyName, block.timestamp);
    }

    function addProduct(
        string memory _productName,
        string memory _description,
        uint256 _price,
        uint256 _stock,
        string memory _category
    ) public {
        require(vendors[msg.sender].isRegistered, "Not a registered vendor");
        require(bytes(_productName).length > 0, "Product name required");
        require(_price > 0, "Price must be > 0");
        require(_stock >= 0, "Stock must be >= 0");

        uint256 productId = nextProductId;
        nextProductId++;
        TotalProducts++;

        bytes32 productCode = keccak256(
            abi.encodePacked(msg.sender, _productName, block.timestamp)
        );

        vendorProducts[msg.sender].push(
            Product({
                productId: productId,
                productName: _productName,
                description: _description,
                price: _price,
                stock: _stock,
                category: _category,
                addedTime: block.timestamp,
                productCode: productCode
            })
        );

        productCodeToVendor[productCode] = msg.sender;

        emit ProductAdded(msg.sender, productId, _productName, _price);
    }

    function getProductAndVendorByCode(bytes32 _code)
        public
        view
        returns (Product memory, Vendor memory)
    {
        address vendorAddr = productCodeToVendor[_code];
        require(vendorAddr != address(0), "Product code not found");

        Product[] memory products = vendorProducts[vendorAddr];
        for (uint256 i = 0; i < products.length; i++) {
            if (products[i].productCode == _code) {
                return (products[i], vendors[vendorAddr]);
            }
        }

        revert("Product not found for code");
    }

    function isVendorRegister(address _vendorAddress)
        public
        view
        returns (bool)
    {
        require(_vendorAddress != address(0), "Invalid vendor address");
        return vendors[_vendorAddress].isRegistered;
    }

   function getProductAndVendorByIndex(uint256 _index)
    public
    view
    returns (Product memory, Vendor memory)
{
    require(_index < vendorProducts[msg.sender].length, "Invalid product index");

    Product memory product = vendorProducts[msg.sender][_index];
    Vendor memory vendor = vendors[msg.sender];

    return (product, vendor);
}

}
