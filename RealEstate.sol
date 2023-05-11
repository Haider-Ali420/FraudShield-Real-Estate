// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Property{

    address public currentInspector;
    uint256 inspectorId=1;

    mapping(uint256 => land_inspector)public inspectorMapping;
    
    mapping(address => land_details)public landMapping;
    mapping(uint256 => bool)public land_id_mapping;
    mapping (address => bool)public landVerification;
    mapping(address => bool)public saleMapping;
    
    mapping(address => user_details)public seller_mapping;
    mapping(address => bool)public seller_verification;
   
    mapping(uint256 => bool)public cnic_mapping;

    mapping(address => user_details)public buyer_mapping;
    mapping(address => bool)public buyer_verification; 

    // Define an event to be emitted when the inspector is changed
    event inspectorTransferred(address new_inspector,string name,uint256 age,string city);


    // Define an event to be emitted when a land is added
    event landAdded(uint256 land_id, string area, string _city,uint256 land_price,address propertyAdres, address _adres);
    // Define an event to be emitted when land is verified
    event landVerified(address propertyAdres);


    // Define an event to be emitted when a seller is added
    event sellerAdded(string Name,uint256 Age,string City,uint256 CNIC,string Email,address _adres);
    // Define an event to be emitted when seller is verified
    event sellerVerified(address seller_adres);
    // Define an event to be emitted when seller details are changed
    event sellerDetailsChanged(address seller_adres,uint256 age,string name,string city,string email);


    // Define an event to be emitted when a buyer is added    
    event buyerAdded(string Name,uint256 Age,string City,uint256 CNIC,string Email,address _adres);
    // Define an event to be emitted when buyer is verified
    event buyerVerified(address buyer_adres);
    // Define an event to be emitted when buyer details are changed
    event buyerDetailsChanged(address buyer_adres,uint256 age,string name,string city,string email);


    // Define an event to be emitted when land is bought
    event landBought(address buyer_adres,address seller_adres,address propertyAdres);
    // Define an event to be emitted when land is transferred
    event landTransferred(address propertyAdres,address _newOwner,address oldOwner);


    struct land_inspector{
        
        string name;
        uint256 age;
        string city;
    }

    struct land_details{
        
        uint256 land_id;
        string area;
        string _city; 
        uint256 land_price;
        address propertyAdres;  
        address user_id;
    }

    struct user_details{
        
        string name;
        uint256 age;
        string city;
        uint256 cnic;
        string email;
        address user_adres;
        uint256 payment;
    }
    
    constructor(string memory name,uint256 age,string memory city){
        
        land_inspector memory _inspector=land_inspector(name,age,city);
        inspectorMapping[inspectorId]=_inspector;
        currentInspector = msg.sender;

    }
     
    modifier Land_Inspector(){
        require(currentInspector == msg.sender,"Not land-inspector");
        _;
    }

    modifier InspectorTransferring(address new_inspector){
        
        require(currentInspector == msg.sender,"only land inspector can transfer ownership");
        require(currentInspector != new_inspector,"you are already the land_inspector");
        require(buyer_mapping[new_inspector].cnic == 0,"this address belongs to a buyer"); 
        require(seller_mapping[new_inspector].cnic == 0,"this address belongs to a seller"); 
        require(landMapping[new_inspector].land_id == 0,"this address belongs to a land");
        _;
    }

     modifier landAdding(uint256 land_id,uint256 land_price,address propertyAdres, address _adres){
        
        require(seller_verification[_adres] == true,"seller not verified yet");
        require(msg.sender == _adres,"Only seller can add land");
        require(buyer_mapping[propertyAdres].cnic == 0,"This property address belongs to the buyer");
        require(propertyAdres != currentInspector,"This property address belongs to the land_inspector"); 
        require(propertyAdres != _adres,"this property address belongs to seller"); 
        require(landMapping[propertyAdres].land_id == 0,"Already registered land");
        require(land_id_mapping[land_id] == false,"this id belongs to another land");
        require(land_price >= 1 ether,"land price must be equal or more than 1 ether");
        _;
    }

    modifier sellerAdding(uint256 CNIC,address _adres){
        
        require(msg.sender == _adres,"not the real user");
        require(buyer_mapping[_adres].cnic == 0,"This seller address belongs to the buyer");
        require(_adres != currentInspector,"This seller address belongs to the land_inspector"); 
        require(landMapping[_adres].land_id == 0,"This seller address is given to land");
        require(seller_mapping[_adres].cnic == 0,"Already added seller address");
        require(cnic_mapping[CNIC] == false,"already added cnic");
        _;
    } 
     
    modifier sellerOnly(address seller_adres){
        require(seller_verification[seller_adres] == true,"seller not verified yet");
        require(msg.sender == seller_adres,"not the seller");
        _;
    } 

    modifier buyerAdding(uint256 CNIC,address _adres){
        
        require(msg.sender == _adres,"not the real user"); 
        require(seller_mapping[_adres].cnic == 0,"This buyer address belongs to the seller");
        require(_adres != currentInspector,"This buyer address belongs to the land_inspector");
        require(landMapping[_adres].land_id == 0,"This buyer address is given to land");
        require(buyer_mapping[_adres].cnic == 0,"Already added buyer address");
        require(cnic_mapping[CNIC] == false,"already added buyer cnic"); 
        _;
    }


    modifier buyerOnly(address buyer_adres){
        
        require(buyer_verification[buyer_adres] == true,"buyer not verified yet");
        require(msg.sender == buyer_adres,"not the buyer");
        _;
    }

    modifier landBuying(address buyer_adres,address seller_adres,address propertyAdres){
       
        require(msg.sender == buyer_adres,"not the buyer");
        require(buyer_verification[buyer_adres] == true,"buyer not verified");
        require(landVerification[propertyAdres] == true,"property not verified yet");
        require(seller_verification[seller_adres] == true,"seller not verified");
        require(saleMapping[propertyAdres] == true,"this land is not avaliable for sale");  
        require(landMapping[propertyAdres].land_price == msg.value,"land price does not match");
        _;
    }


    /**
    * @dev transferInspector is used to transfer the ownership of the contract to new inspector.
    * Requirements :
    *  - This function can only be called by the present land inspector.
    *   @ pragma new_inspector  -  newInspector
    *   @ pragma name - name
    *   @ pragma age - age
    *   @ pragma city - city
    */
    
   
    function transferInspector(address new_inspector,string memory name,
        uint256 age,string memory city) public InspectorTransferring(new_inspector){
        
            land_inspector memory _inspector=land_inspector(name,age,city);
            currentInspector = new_inspector;
            inspectorMapping[inspectorId]=_inspector;
            inspectorId++;
            emit inspectorTransferred(new_inspector, name, age, city);
    }


    /**
    * @dev addLand is used to add land details by seller once the seller is verified.
    * Requirements :
    *  - This function can only be used by the seller whose address is entered in _adres .
    *   @ pragma land_id  -  land_id
    *   @ pragma area  -  the total area of land
    *   @ pragma _city  -  city where the land is present
    *   @ pragma propertyAdres  -   the address of land
    *   @ pragma  _adres  -  the address of seller
    */


    function addLand(uint256 land_id, string memory area, string memory _city,
        uint256 land_price,address propertyAdres, address _adres )public landAdding(land_id, land_price, propertyAdres, _adres){ 

            land_details memory _land=land_details(land_id, area, _city,land_price, propertyAdres,_adres);
            landMapping[propertyAdres]=_land;

            land_id_mapping[land_id] = true;

            emit landAdded(land_id, area, _city, land_price, propertyAdres, _adres);
    }


    /**
    * @dev landVerify is used to verify the land that the seller added.
    * Requirements :
    *  - This function can only be used land inspector.
    *   @ pragma propertyAdres  -  the address of land that is added
    */
 

    function landVerify(address propertyAdres)public Land_Inspector {
        
        require(landVerification[propertyAdres] == false,"already verified land");
        require(landMapping[propertyAdres].land_id !=0 ,"land does not exist");
        landVerification[propertyAdres] = true;
        saleMapping[propertyAdres] = true;

       emit landVerified(propertyAdres);
    }

    /**
    * @dev addSellers is used to add seller details.
    * Requirements :
    *  - This function can only be used by the seller who is adding his/her details.
    *   @ pragma Name  -  Name
    *   @ pragma Age  -  Age
    *   @ pragma City  -  City
    *   @ pragma CNIC  -  CNIC
    *   @ pragma Email  -  Email
    *   @ pragma _adres  -  _adres
    */


    function addSellers(string memory Name,uint256 Age,string memory City,
        uint256 CNIC,string memory Email,address _adres)public sellerAdding(CNIC, _adres){
           
            user_details memory new_seller=user_details(Name,Age,City,CNIC,Email,_adres,0);
            seller_mapping[_adres]=new_seller;
       
            cnic_mapping[CNIC] = true; 
            emit sellerAdded(Name, Age, City, CNIC, Email, _adres);    
    }

    /**
    * @dev sellersVerify is used to verify the seller that is added in seller_mapping.
    * Requirements :
    *  - This function can only be used land inspector.
    *   @ pragma seller_adres  -  the address of seller that is added
    */
    

    function sellersVerify(address seller_adres)public Land_Inspector{
        
        require(seller_verification[seller_adres] == false,"already verified seller");
        require(seller_mapping[seller_adres].cnic !=0,"seller does not exist");
       
        seller_verification[seller_adres] = true;
    
        emit sellerVerified(seller_adres);
    }


    /**
    * @dev changeSeller_details is used to change some details of already added seller.
    * Requirements :
    *  - This function can only be used by the seller whose address is added in seller_adres.
    *   @ pragma seller_adres  -  seller_adres
    *   @ pragma age  -  age
    *   @ pragma name  -  name
    *   @ pragma city  -  city
    *   @ pragma email  -  email
    */
   

    function changeSeller_details(address seller_adres,uint256 age,string memory name,
      string memory city,string memory email)public sellerOnly(seller_adres){ 
          
        user_details memory new_seller=user_details(name,age,city,seller_mapping[seller_adres].cnic,
        email,seller_mapping[seller_adres].user_adres,seller_mapping[seller_adres].payment);
        
        seller_mapping[seller_adres]=new_seller;
        
        seller_verification[seller_adres] = false;
        
        emit sellerDetailsChanged(seller_adres, age, name, city, email);

    } 


    /**
    * @dev addBuyers is used to add buyer details.
    * Requirements :
    *  - This function can only be used by the buyer who is adding his/her details.
    *   @ pragma Name  -  Name
    *   @ pragma Age  -  Age
    *   @ pragma City  -  City
    *   @ pragma CNIC  -  CNIC
    *   @ pragma Email  -  Email
    *   @ pragma _adres  -  _adres
    */

    
    function addBuyers(string memory Name,uint256 Age,string memory City,
        uint256 CNIC,string memory Email,address _adres)public buyerAdding(CNIC, _adres){
           
            user_details memory new_buyer=user_details(Name,Age,City,CNIC,Email,_adres,0);
            buyer_mapping[_adres]=new_buyer;

            cnic_mapping[CNIC]=true;

            emit buyerAdded(Name, Age, City, CNIC, Email, _adres); 
    }


    /**
    * @dev buyerVerify is used to verify the buyer that is added in buyer_mapping.
    * Requirements :
    *  - This function can only be used land inspector.
    *   @ pragma buyer_adres  -  the address of buyer that is added
    */
    
    
    function buyerVerify(address buyer_adres)public Land_Inspector{
       
        require(buyer_mapping[buyer_adres].cnic != 0,"buyer does not exist");
        require(buyer_verification[buyer_adres] == false,"already verified buyer");
        
        buyer_verification[buyer_adres] = true;
        
        emit buyerVerified(buyer_adres);
    }

    
    /**
    * @dev changeBuyer_details is used to change some details of already added buyer.
    * Requirements :
    *  - This function can only be used by the buyer whose address is added in buyer_adres.
    *   @ pragma buyer_adres  -  buyer_adres
    *   @ pragma age  -  age
    *   @ pragma name  -  name
    *   @ pragma city  -  city
    *   @ pragma email  -  email
    */

    
    function changeBuyer_details(address buyer_adres,uint256 age,string memory name,
       string memory city,string memory email)public buyerOnly(buyer_adres) {
        
        user_details memory new_buyer=user_details(name,age,city,buyer_mapping[buyer_adres].cnic,
        email,buyer_mapping[buyer_adres].user_adres,buyer_mapping[buyer_adres].payment);
        
        buyer_mapping[buyer_adres]=new_buyer;
        
        buyer_verification[buyer_adres] = false;
        
       emit buyerDetailsChanged(buyer_adres, age, name, city, email);
    }


    /**
    * @dev buyLand is used to buy the verified land .
    * Requirements :
    *  - This function can be used by buyer whose address is given in buyer_adres.
    *   @ pragma buyer_adres  -  buyer_adres
    *   @ pragma seller_adres  -  seller_adres
    *   @ pragma propertyAdres  -  propertyAdres
    */

    
    function buyLand(address buyer_adres,address payable seller_adres,address propertyAdres)public payable 
        landBuying(buyer_adres, seller_adres, propertyAdres){
        
            payable(seller_adres).transfer(msg.value);
            seller_mapping[seller_adres].payment+=msg.value;
            landMapping[propertyAdres].user_id=buyer_adres;
            saleMapping[propertyAdres]=false;  

            emit landBought(buyer_adres, seller_adres, propertyAdres);      
    }


    /**
    * @dev currentOwner is used to show the owner of land before it is bought by any buyer.
    * Requirements :
    *  - This function can be used by any user.
    *   @ pragma propertyAdres  -  propertyAdres
    */


    function currentOwner(address propertyAdres)public view returns (string memory, string memory, 
        address, uint256, string memory, string memory, uint256, address) {
            
        require(landMapping[propertyAdres].propertyAdres != address(0), "Land does not exist");
        require(saleMapping[propertyAdres] == true,"land is sold check new-owner function");
        require(landVerification[propertyAdres] == true, "Land is not verified yet");
  
        land_details memory land = landMapping[propertyAdres]; 
        user_details memory current_owner = seller_mapping[land.user_id];
        return (current_owner.name, current_owner.email, current_owner.user_adres,land.land_id,land.area,land._city,land.land_price,land.propertyAdres); 
    }


    /**
    * @dev newOwner is used to show the owner of land after it is bought by any buyer.
    * Requirements :
    *  - This function can be used by any user.
    *   @ pragma propertyAdres  -  propertyAdres
    */
    

    function newOwner(address propertyAdres)public view returns (string memory, string memory, 
        address, uint256, string memory, string memory, uint256, address) {
            
        require(landMapping[propertyAdres].propertyAdres != address(0), "Land does not exist");
        require(saleMapping[propertyAdres] == false,"land is not sold yet check current-owner function");
        require(landVerification[propertyAdres] == true, "Land is not verified yet");
        land_details memory land = landMapping[propertyAdres];

        user_details memory new_owner = buyer_mapping[land.user_id];
        return (new_owner.name, new_owner.email, new_owner.user_adres,land.land_id,land.area,land._city,land.land_price,land.propertyAdres); 
    }


    /**
    * @dev transferLand_ownership is used to transfer the ownership of land from one relative to another
                                        without paying the price of land like father transfer his land to the son.
    
    * Requirements :
    *  - This function can only be used by current owner of land.
    *   @ pragma propertyAdres  -  propertyAdres
     *   @ pragma _newOwner  -  the owner address at which the land is transferred like son
                                the _newOwner can only be the in form of buyer 
     
     *   @ pragma oldOwner  -  the current owner of land like father
    */

   
    function transferLand_ownership(address propertyAdres,address _newOwner,address oldOwner)public {
       
       require(msg.sender == oldOwner,"not the old owner");
       require(buyer_mapping[_newOwner].user_adres!=address(0),"new owner does not exist");
       require(landVerification[propertyAdres] == true,"land not verified yet");
       require(seller_verification[oldOwner] == true,"old owner not verified yet");
       require(buyer_verification[_newOwner] == true,"new owner not verified");
       
        landMapping[propertyAdres].user_id = _newOwner;
        emit landTransferred(propertyAdres, _newOwner, oldOwner);
    }
   
}