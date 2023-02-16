pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";


contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    address[] authorizeCallers = new address[](0);
    address[] activatedAirlines = new address[](0);
    uint256 REGISTRATION_FEE = 10 ether;

    struct Airline {
        bool isActivated;
    }
    mapping(address => Airline) public airlines;

    
    struct Insuree {
        bytes32 flight;
        uint256 premium;
    }
    mapping(address => Insuree) public insurees;


    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
    }

    event Bought(uint );

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public
                            view
                            returns(bool)

    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    function authorizeCaller 
                            (
                                address _newCaller
                            )
                            external
    {
        authorizeCallers.push(_newCaller);
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *   이미 동의까지 다 된 상태고 등록만 하면 됨 
    */   
    function registerAirline
                            (
                                address _newAirline   
                            )
                            external
                            requireIsOperational
    {
        airlines[_newAirline] = Airline({isActivated: false});
        activatedAirlines.push(_newAirline);
    }


    function isAirline
                            (
                                address _newAirline    
                            )
                            external
                            view
                            returns(bool)
    {
        Airline memory existingAirline = airlines[_newAirline];
        if(existingAirline.isActivated == true){
            return true;
        } else {
            return false;
        }

    }

   /**
    * @dev Buy insurance for a flight
    * 보험 구매하기 
    */   
    function buy
                            (
                                address _insuree,
                                bytes32 _flight                             
                            )
                            external
                            payable
    {
        contractOwner.transfer(msg.value);
        
        insurees[_insuree] = Insuree({flight: _flight, premium: msg.value});
        
    }

    /**
     *  @dev Credits payouts to insurees
     * 구매자인지 확인하기 
    */
    function creditInsurees
                                (
                                    address _insuree,
                                    bytes32 flightKey

                                )
                                internal
                                view
                                returns(bool)
    {
        if(insurees[_insuree].premium != 0 && insurees[_insuree].flight == flightKey){
            return true;
        } else {
            return false;
        }
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     * 구매자에게 돌려주기 
    */
    function pay
                            (
                                address _insuree,
                                bytes32 flightKey
                            )
                            external
                            payable
    {
        require(creditInsurees(_insuree, flightKey));
        address insuree = msg.sender;
        uint256 _premium = insurees[msg.sender].premium;
        uint256 payout = _premium.mul(3).div(2);
        insuree.transfer(payout);
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *   10ether 보내서 activate 상태로 만들기 
    */   
    function fund
                            (   
                            )
                            public
                            payable
    {
        if(airlines[msg.sender].isActivated == false){
            require(msg.value >= REGISTRATION_FEE);
            address _receiver = contractOwner;
            _receiver.transfer(10 ether);
            airlines[msg.sender].isActivated = true;

        }
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund();
    }


}

