pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";


contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    
    mapping(address => bool) authorizedContracts;

    address[] activatedAirlines = new address[](0);
    uint256 REGISTRATION_FEE = 10 ether;

    struct Airline {
        bool isActivated;
    }
    mapping(address => Airline) public airlines;

    
    struct Insuree {
        address airline;
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
                                    address firstAirline
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        airlines[firstAirline] = Airline({isActivated: true});
        activatedAirlines.push(firstAirline);
    }


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
                            external
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
                                address contractAddress
                            )
                            external
                            requireContractOwner
    {
        authorizedContracts[contractAddress] = true;
    }


    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *   ?????? ???????????? ??? ??? ????????? ????????? ?????? ??? 
    */   
    function registerAirline
                            (
                                address _newAirline   
                            )
                            external
                            //requireIsOperational
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
    * ?????? ???????????? 
    */   
    function buy
                            (
                                address _airline,
                                uint256 toPurchase                             
                            )
                            public
                            payable
    {
        _airline.transfer(toPurchase);
        
        insurees[msg.sender] = Insuree({airline: _airline, premium: msg.value});
        
    }

    /**
     *  @dev Credits payouts to insurees
     * ??????????????? ???????????? 
    */
    function creditInsurees
                                (
                                    address _insuree,
                                    address _airline

                                )
                                internal
                                view
                                returns(bool)
    {
        if(insurees[_insuree].premium != 0 && insurees[_insuree].airline == _airline){
            return true;
        } else {
            return false;
        }
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     * ??????????????? ???????????? 
    */
    function pay
                            (
                                address _insuree,
                                address _airline
                            )
                            external
                            payable
    {
        require(creditInsurees(_insuree, _airline) == true);
        address insuree = msg.sender;
        uint256 _premium = insurees[msg.sender].premium;
        uint256 payout = _premium.mul(3).div(2);
        insuree.transfer(payout);
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *   10ether ????????? activate ????????? ????????? 
    */   
    function fund
                            (
                            )
                            public
                            payable
    {
        require(msg.value >= REGISTRATION_FEE);
        if(airlines[msg.sender].isActivated == false){
            
            msg.sender.transfer(10 ether);
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



