
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
            simple_display([{label: 'First Airline', error: error, value: contract.airlines[0]}])
        });

        // Purchase insurance 
        DOM.elid('register-flight').addEventListener('click', () => {
            let flight = DOM.elid('flight-regis').value;
            let datetime = DOM.elid('datetime').value;

            if ((flight == null || flight == "") || (datetime == null || datetime == "")) {
              alert("Please Fill In All Required Fields");
              return false;
            }
                 
            contract.registerFlight(flight, datetime, (error, result) => {
                simple_display([{label: 'registered', error: error, value:result}])
                //display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        });


        // Purchase insurance 
        DOM.elid('purchase-insurance').addEventListener('click', () => {
            let insuree = DOM.elid('insuree').value;
            let airline = DOM.elid('airline-address').value;
            let ether = DOM.elid('to-buy').value;

            if ((insuree == null || insuree == "") || (airline == null || airline == "") || (ether == 0)) {
              alert("Please Fill In All Required Fields");
              return false;
            }
                 
            contract.purchaseInsurance(insuree, airline, ether, (error, result) => {
                one_display("Purchased");
                //display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        });


        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            // let address = DOM.elid('address').value;
            // let timestamp = DOM.elid('timestamp').value;
            if ((flight == null || flight == "")) {
              alert("Please Fill In All Required Fields");
              return false;
            }
                    // Write transaction           
            contract.fetchFlightStatus(flight, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        });
    });
    

})();

function one_display(title){
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h4(title));
    displayDiv.append(section);
}

function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);

}

function simple_display(results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);

}





