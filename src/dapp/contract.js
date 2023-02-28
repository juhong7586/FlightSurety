import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';


//계약에 대한 부분 
export default class Contract {
    constructor(network, callback) {
        //네트워크 및 기초 airlines, passengers 설정 
        let config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider(config.url));
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
        this.initialize(callback);
        this.owner = null;
        this.airlines = [];
        this.passengers = [];
        this.flights = [];
    }

    //시작할 때 어카운트 4개씩 넣기 
    initialize(callback) {
        this.web3.eth.getAccounts((error, accts) => {
           
            this.owner = accts[0];

            let counter = 1;
            
            while(this.airlines.length < 5) {
                this.airlines.push(accts[counter++]);
            }

            while(this.passengers.length < 5) {
                this.passengers.push(accts[counter++]);
            }

            callback();
        });
    }

    isOperational(callback) {
       let self = this;
       self.flightSuretyApp.methods
            .isOperational()
            .call({ from: self.owner}, callback);
    }


    registerFlight(flight, datetime, callback) {
        let self = this;
        let payload = {
            flight: flight,
            timestamp: datetime
        }
        self.flightSuretyApp.methods
            .registerFlight(payload.flight, payload.timestamp)
            .send({from: self.owner}, (error, result) => {
                let newFlight = {name: payload.flight, key: result}
                this.flights.push(newFlight)
                callback(error, newFlight.name);
            });
        
    }

    async purchaseInsurance(insuree, airline, ether, callback) {
        let self = this;
        let payload = {
            insuree: insuree,
            airline:airline,
            ether: ether
        }
        let exist = false;
        let flight_insure = null;
        for (let i = 0; i < this.airlines.length; i++){
            if (payload.airline == this.airlines[i]) {
                exist = true;
                flight_insure = this.airlines[i];
            }            
        }

        if (exist == false) {
            alert('No such airline available');
        } else {
            this.passengers.push(payload.insuree);
           
        }

        await self.flightSuretyApp.methods.purchase(payload.airline, payload.ether, {from: payload.insuree, value: payload.ether});
    } 


    //첫번째 airline과 들어온 flight 넣기 
    fetchFlightStatus(flight, callback) {
        let self = this;
        let payload = {
            airline: self.airlines[0],
            flight: flight,
            timestamp: Math.floor(Date.now() / 1000)
        } 
        self.flightSuretyApp.methods
            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
            .send({ from: self.owner}, (error, result) => {
                callback(error, payload);
            });
        self.flightSuretyApp.events   
            .FlightStatusInfo(function(err, data) {
                if (!err)
                    console.log(data);
            });
    }

    
}